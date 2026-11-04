import copy
import importlib.util
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
        for field in ["Env", "Resources"]:
            self.assertEqual(task[field], backend[field])
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

    def prepare(self, current=None, allocations=None, api_error=False):
        requested = fixture()["Job"]
        requested["ID"] = "tcg-medusa-production-migrate"
        calls = []
        def output(command):
            if api_error: raise subprocess.CalledProcessError(1, command)
            if "status" in command: return json.dumps([{"ID": requested["ID"]}] if current else [])
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
