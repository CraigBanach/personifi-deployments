#!/usr/bin/env python3
"""Never replace a live or failed migration automatically on a retry."""
import json
import subprocess
import sys

name, requested_file = sys.argv[1:]
with open(requested_file, encoding="utf-8") as source:
    requested = json.load(source)["Job"]
# Listing first distinguishes absence from an authentication/network failure.
all_jobs = json.loads(subprocess.check_output(["nomad", "job", "status", "-json"]))
if any(job["ID"] == name for job in all_jobs):
    current = json.loads(subprocess.check_output(["nomad", "job", "inspect", "-json", name]))
    current = current.get("Job", current)
    old_image = current["TaskGroups"][0]["Tasks"][0]["Config"]["image"]
    new_image = requested["TaskGroups"][0]["Tasks"][0]["Config"]["image"]
    if old_image == new_image:
        # The bounded waiter checks completion/failure; do not erase evidence or
        # restart a timed-out or failed migration with uncertain database effects.
        sys.exit(0)
    allocations = json.loads(subprocess.check_output(["nomad", "job", "allocs", "-json", name]))
    if not allocations:
        sys.exit("ERROR: Previous migration has no completion evidence; refusing replacement")
    if any(a.get("ClientStatus") not in ("complete", "failed", "lost") for a in allocations):
        sys.exit("ERROR: Previous migration is still active; refusing replacement")
    if any(a.get("ClientStatus") != "complete" or not a.get("TaskStates") or any(t.get("State") != "dead" or t.get("Failed") for t in a["TaskStates"].values()) for a in allocations):
        sys.exit("ERROR: Previous migration failed; review database effects and purge the batch explicitly before retrying")
    subprocess.run(["nomad", "job", "stop", "-purge", name], check=True)
subprocess.run(["nomad", "job", "run", "-json", requested_file], check=True)
