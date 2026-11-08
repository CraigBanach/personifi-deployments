import copy
import importlib.util
import io
import json
from pathlib import Path
import runpy
import subprocess
import tempfile
import unittest
from unittest.mock import patch

SCRIPTS = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("managed", SCRIPTS / "tcg-managed-rollout.py")
managed = importlib.util.module_from_spec(spec)
spec.loader.exec_module(managed)
ready_spec = importlib.util.spec_from_file_location("readiness", SCRIPTS / "wait-for-tcg-release.py")
readiness = importlib.util.module_from_spec(ready_spec)
ready_spec.loader.exec_module(readiness)


def fixture():
    return {"Job": {"ID": "tcg-medusa-production", "Name": "tcg-medusa-production", "Type": "service", "TaskGroups": [{
        "Name": "tcg-medusa", "Count": 1,
        "Networks": [{"DynamicPorts": [{"Label": "backend", "To": 9000}, {"Label": "storefront", "To": 8000}]}],
        "Tasks": [{"Name": name, "Driver": "docker", "Env": {"DEPLOY_VERSION": "sha256:" + "a" * 64},
                   "Config": {"image": "registry/" + name + "@sha256:" + "a" * 64,
                              "ports": [name], "labels": [{"traefik.enable": "true"}],
                              "volumes": ["/persistent/" + name + ":/data"],
                              "auth": {"username": "${DOCKER_USERNAME}", "password": "${DOCKER_PASSWORD}"}},
                   "Templates": [{"DestPath": "local/secrets.env", "EmbeddedTmpl": "private", "Envvars": True}],
                   "Resources": {"CPU": 500, "MemoryMB": 1536}} for name in ["backend", "redis", "storefront"]],
    }]}}


class ManagedRolloutTests(unittest.TestCase):
    def test_groups_are_independent_and_redis_state_is_unchanged(self):
        original = fixture()
        before = copy.deepcopy(original)
        service, migration = managed.jobs(original)
        self.assertEqual(original, before)
        backend, storefront = service["Job"]["TaskGroups"]
        self.assertEqual(backend["Name"], "tcg-medusa")
        self.assertEqual([t["Name"] for t in backend["Tasks"]], ["backend", "redis"])
        self.assertEqual(backend["Tasks"][1], original["Job"]["TaskGroups"][0]["Tasks"][1])
        self.assertEqual(storefront["Name"], "storefront")
        self.assertEqual(storefront["Networks"][0]["DynamicPorts"], [{"Label": "storefront", "To": 8000}])
        self.assertEqual(backend["Networks"][0]["DynamicPorts"], [{"Label": "backend", "To": 9000}])
        self.assertFalse(backend["Update"]["AutoRevert"])
        for group in [backend, storefront]:
            self.assertEqual(group["Tasks"][0]["Services"][0]["Checks"][0]["Type"], "http")

    def test_migration_uses_same_image_auth_environment_and_templates_without_services(self):
        original = fixture()
        service, migration = managed.jobs(original)
        job = migration["Job"]
        group = job["TaskGroups"][0]
        task = group["Tasks"][0]
        backend = service["Job"]["TaskGroups"][0]["Tasks"][0]
        self.assertEqual(job["Type"], "batch")
        self.assertEqual(len(group["Tasks"]), 1)
        self.assertEqual(group["RestartPolicy"]["Attempts"], 0)
        self.assertEqual(group["ReschedulePolicy"]["Attempts"], 0)
        self.assertEqual(task["Env"], backend["Env"])
        # Reserves little and may burst (memory oversubscription on).
        self.assertEqual(task["Resources"], {**backend["Resources"], "MemoryMB": 384, "MemoryMaxMB": 1024})
        expected_templates = copy.deepcopy(backend["Templates"])
        for template in expected_templates: template["ChangeMode"] = "noop"
        self.assertEqual(task["Templates"], expected_templates)
        for field in ["image", "auth"]:
            self.assertEqual(task["Config"][field], backend["Config"][field])
        for field in ["ports", "labels", "volumes"]:
            self.assertNotIn(field, task["Config"])
        self.assertNotIn("Services", task)
        self.assertEqual(task["Config"]["command"], "pnpm")
        self.assertEqual(task["Config"]["args"], ["predeploy"])

    def test_only_storefront_probes_use_lightweight_uncached_release_endpoint(self):
        original = fixture()
        service, _ = managed.jobs(original)
        backend = service["Job"]["TaskGroups"][0]["Tasks"][0]
        storefront = service["Job"]["TaskGroups"][1]["Tasks"][0]
        for task, route, name in [(backend, "/health", "api"), (storefront, "/api/release", "storefront")]:
            self.assertEqual(task["Services"][0]["Checks"], [{
                "Name": "http-ready", "Type": "http", "Path": route,
                "Interval": 5_000_000_000, "Timeout": 3_000_000_000,
            }])
            labels = task["Config"]["labels"][0]
            prefix = f"traefik.http.services.tcg-medusa-{name}-production.loadbalancer.healthcheck"
            self.assertEqual(labels[prefix + ".path"], route)
            self.assertEqual(labels[prefix + ".interval"], "5s")
            self.assertEqual(labels[prefix + ".timeout"], "3s")
            before = next(t for t in original["Job"]["TaskGroups"][0]["Tasks"] if t["Name"] == task["Name"])
            for field in ["Resources", "Templates"]:
                self.assertEqual(task[field], before[field])

    def test_public_rollout_still_requires_homepage_api_health_and_exact_digests(self):
        backend = "sha256:" + "a" * 64
        storefront = "sha256:" + "b" * 64
        urls = ["https://api.freesplash.co.uk/release", "https://freesplash.co.uk/api/release",
                "https://api.freesplash.co.uk/health", "https://freesplash.co.uk/gb"]
        class Response(io.BytesIO):
            def __init__(self, digest, status=200):
                super().__init__(json.dumps({"image_digest": digest}).encode())
                self.status = status
        class Opener:
            def __init__(self, failed_url=None, wrong_digest=False):
                self.calls = []
                self.failed_url, self.wrong_digest = failed_url, wrong_digest
            def open(self, request, timeout):
                self.calls.append((request.full_url, timeout))
                digest = backend if request.full_url == urls[0] else storefront
                return Response("sha256:" + "c" * 64 if self.wrong_digest else digest,
                                503 if request.full_url == self.failed_url else 200)
        opener = Opener()
        self.assertTrue(readiness.ready(backend, storefront, opener))
        self.assertEqual(opener.calls, [(url, 10) for url in urls])
        for url in urls:
            self.assertFalse(readiness.ready(backend, storefront, Opener(failed_url=url)))
        self.assertFalse(readiness.ready(backend, storefront, Opener(wrong_digest=True)))

    def test_frontend_change_does_not_change_backend_group(self):
        first = fixture()
        second = copy.deepcopy(first)
        second["Job"]["TaskGroups"][0]["Tasks"][2]["Config"]["image"] = "registry/storefront@sha256:" + "b" * 64
        a, _ = managed.jobs(first)
        b, _ = managed.jobs(second)
        self.assertEqual(a["Job"]["TaskGroups"][0], b["Job"]["TaskGroups"][0])

    def test_unexpected_shape_and_mutable_images_fail_closed(self):
        for mode in ["group", "tasks", "image"]:
            doc = fixture()
            group = doc["Job"]["TaskGroups"][0]
            if mode == "group": group["Name"] = "unexpected"
            if mode == "tasks": group["Tasks"].pop()
            if mode == "image": group["Tasks"][0]["Config"]["image"] = "registry/backend:latest"
            with self.assertRaises(ValueError): managed.jobs(doc)

    def prepare(self, current=None, allocations=None, api_error=False, listed_jobs=None):
        requested = fixture()["Job"]
        requested["ID"] = "tcg-medusa-production-migrate"
        calls = []
        def output(command):
            if api_error: raise subprocess.CalledProcessError(1, command)
            if "status" in command:
                return json.dumps(listed_jobs if listed_jobs is not None else ([{"ID": requested["ID"]}] if current else []))
            if "inspect" in command: return json.dumps(current)
            if "allocs" in command: return json.dumps(allocations or [])
            raise AssertionError(command)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "requested.json"
            path.write_text(json.dumps({"Job": requested}))
            with patch("sys.argv", ["prepare", requested["ID"], str(path)]), patch("subprocess.check_output", side_effect=output), patch("subprocess.run", side_effect=lambda command, **kw: calls.append(command)):
                try:
                    runpy.run_path(str(SCRIPTS / "prepare-tcg-migration.py"), run_name="__main__")
                except SystemExit as error:
                    if error.code != 0: raise
        return calls

    def test_new_migration_is_submitted_once_and_same_image_is_never_restarted(self):
        self.assertEqual(len(self.prepare()), 1)
        self.assertEqual(self.prepare(fixture()["Job"]), [])

    def test_detailed_nomad_status_uses_summary_job_identity(self):
        listing = [{"Summary": {"JobID": "tcg-medusa-production-migrate"}, "Allocations": []}]
        self.assertEqual(self.prepare(fixture()["Job"], listed_jobs=listing), [])
        service_only = [{"Summary": {"JobID": "tcg-medusa-production"}, "Allocations": []}]
        self.assertEqual(len(self.prepare(listed_jobs=service_only)), 1)
        current = fixture()["Job"]
        current["TaskGroups"][0]["Tasks"][0]["Config"]["image"] = "registry/old@sha256:" + "c" * 64
        with self.assertRaises(SystemExit):
            self.prepare(current, [{"ClientStatus": "failed"}], listed_jobs=listing)

    def test_never_placed_migration_is_replaced_only_when_the_request_differs(self):
        listing = [{"ID": "tcg-medusa-production-migrate"}]
        # The helper requests fixture()["Job"]; the stuck job asked for more memory.
        stuck = fixture()["Job"]
        stuck["Status"] = "pending"
        stuck["TaskGroups"][0]["Tasks"][0]["Resources"]["MemoryMB"] = 4096
        calls = self.prepare(stuck, [], listed_jobs=listing)
        self.assertEqual([c[:3] for c in calls], [["nomad", "job", "stop"], ["nomad", "job", "run"]])
        same = fixture()["Job"]
        same["Status"] = "pending"
        self.assertEqual(self.prepare(same, [], listed_jobs=listing), [])
        # Placed once (an allocation exists): never replaced by this rule.
        with self.assertRaises(SystemExit):
            self.prepare({**stuck, "TaskGroups": [{**stuck["TaskGroups"][0], "Tasks": [{**stuck["TaskGroups"][0]["Tasks"][0], "Config": {**stuck["TaskGroups"][0]["Tasks"][0]["Config"], "image": "registry/old@sha256:" + "c" * 64}}]}]},
                         [{"ClientStatus": "running"}], listed_jobs=listing)

    def test_invalid_or_conflicting_listing_is_not_migration_absence(self):
        for listing in [[{}], [None], [{"Summary": {}}], [{"ID": "one", "Summary": {"JobID": "two"}}], [{"ID": 42}]]:
            with self.subTest(listing=listing), self.assertRaises(SystemExit):
                self.prepare(listed_jobs=listing)

    def test_live_or_failed_previous_image_and_api_failure_cannot_be_replaced(self):
        current = fixture()["Job"]
        current["TaskGroups"][0]["Tasks"][0]["Config"]["image"] = "registry/old@sha256:" + "c" * 64
        for state in ["running", "pending", "failed", "lost"]:
            with self.assertRaises(SystemExit): self.prepare(current, [{"ClientStatus": state}])
        with self.assertRaises(subprocess.CalledProcessError): self.prepare(api_error=True)
        with self.assertRaises(SystemExit): self.prepare(current, [])
        calls = self.prepare(current, [{"ClientStatus": "complete", "TaskStates": {"migrate": {"State": "dead", "Failed": False}}}])
        self.assertEqual(len(calls), 2)


if __name__ == "__main__":
    unittest.main()
