#!/usr/bin/env python3
"""Derive service and one-shot migration jobs from the same rendered Nomad job."""
import copy
import json
import re
import sys


MIGRATION_MEMORY_MB = 384
MIGRATION_MEMORY_MAX_MB = 1024


def jobs(document):
    service = copy.deepcopy(document.get("Job", document))
    groups = service["TaskGroups"]
    if len(groups) != 1 or groups[0]["Name"] != "tcg-medusa":
        raise ValueError("Expected the existing backend/Redis group; refusing state relocation")
    group = groups[0]
    tasks = {task["Name"]: task for task in group["Tasks"]}
    if set(tasks) != {"backend", "redis", "storefront"}:
        raise ValueError("Unexpected service tasks")
    backend, storefront = tasks["backend"], tasks["storefront"]
    image = backend["Config"]["image"]
    if not re.search(r"@sha256:[0-9a-f]{64}$", image):
        raise ValueError("Migration image must be digest-pinned")

    # Preserve the backend group name, Redis task, host network and persistent paths.
    frontend_group = copy.deepcopy(group)
    frontend_group["Name"] = "storefront"
    frontend_group["Tasks"] = [storefront]
    group["Tasks"] = [backend, tasks["redis"]]
    for target, port in [(group, "backend"), (frontend_group, "storefront")]:
        for network in target.get("Networks", []):
            for key in ["DynamicPorts", "ReservedPorts"]:
                if network.get(key):
                    network[key] = [p for p in network[key] if p["Label"] == port]
        target["Update"] = {
            "MaxParallel": 1, "HealthCheck": "checks", "MinHealthyTime": 10_000_000_000,
            "HealthyDeadline": 480_000_000_000, "ProgressDeadline": 720_000_000_000,
            "AutoRevert": False, "AutoPromote": False, "Canary": 0,
        }
    groups.append(frontend_group)
    backend.setdefault("Env", {})["MEDUSA_MIGRATIONS_MANAGED"] = "true"
    # Service probes must not render a price-bearing homepage every five seconds:
    # uncached catalog work can exceed the probe budget and flap healthy routing.
    # Public rollout verification still requires /gb, API health and both digests.
    for task, port, path in [(backend, "backend", "/health"), (storefront, "storefront", "/api/release")]:
        task["Services"] = [{
            "Name": f'{service["ID"]}-{port}', "Provider": "nomad", "PortLabel": port,
            "Checks": [{"Name": "http-ready", "Type": "http", "Path": path,
                        "Interval": 5_000_000_000, "Timeout": 3_000_000_000}],
        }]
        labels = task["Config"].setdefault("labels", [{}])
        # Nomad's HCL parser returns Docker map blocks as single-item lists.
        if isinstance(labels, list):
            if len(labels) != 1:
                raise ValueError("Expected one Docker labels block")
            labels = labels[0]
        name = f'tcg-medusa-{ "api" if port == "backend" else "storefront" }-production'
        labels[f"traefik.http.services.{name}.loadbalancer.healthcheck.path"] = path
        labels[f"traefik.http.services.{name}.loadbalancer.healthcheck.interval"] = "5s"
        labels[f"traefik.http.services.{name}.loadbalancer.healthcheck.timeout"] = "3s"

    migration = copy.deepcopy(service)
    migration["ID"] = migration["Name"] = f'{service["ID"]}-migrate'
    migration["Type"] = "batch"
    migration.pop("Update", None)
    migration.pop("Periodic", None)
    migration.pop("ParameterizedJob", None)
    batch_group = copy.deepcopy(group)
    batch_group["Name"] = "migration"
    batch_group.pop("Networks", None)
    batch_group.pop("Update", None)
    batch_group["Count"] = 1
    batch_group["RestartPolicy"] = {"Attempts": 0, "Mode": "fail"}
    batch_group["ReschedulePolicy"] = {"Attempts": 0, "Unlimited": False}
    task = copy.deepcopy(backend)
    task["Name"] = "migrate"
    # The node cannot reserve a second backend-sized task beside the live one
    # (4 Nov 2026: 1,536 MB never placed). Migrations reserve little and may
    # burst into free host memory; the cluster has memory oversubscription on.
    task["Resources"] = {**task.get("Resources", {}), "MemoryMB": MIGRATION_MEMORY_MB, "MemoryMaxMB": MIGRATION_MEMORY_MAX_MB}
    task.pop("Services", None)
    task.pop("Lifecycle", None)
    for template in task.get("Templates", []):
        # A reconciler retry may refresh variables while this batch is still
        # alive. Do not restart database work in response to template changes.
        template["ChangeMode"] = "noop"
    for key in ["ports", "labels", "volumes"]:
        task["Config"].pop(key, None)
    task["Config"]["command"] = "pnpm"
    task["Config"]["args"] = ["predeploy"]
    batch_group["Tasks"] = [task]
    migration["TaskGroups"] = [batch_group]
    return {"Job": service}, {"Job": migration}


if __name__ == "__main__":
    with open(sys.argv[1], encoding="utf-8") as source:
        service, migration = jobs(json.load(source))
    for filename, document in zip(sys.argv[2:], [service, migration]):
        with open(filename, "w", encoding="utf-8") as output:
            json.dump(document, output)
