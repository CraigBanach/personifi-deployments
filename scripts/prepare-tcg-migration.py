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
# Nomad CLI versions expose either Job stubs (ID) or detailed job status
# objects (Summary.JobID). Validate the whole listing before treating absence
# as permission to submit; malformed/ambiguous responses must fail closed.
if not isinstance(all_jobs, list):
    sys.exit("ERROR: Invalid Nomad job listing; refusing migration submission")
job_ids = set()
for job in all_jobs:
    if not isinstance(job, dict):
        sys.exit("ERROR: Invalid Nomad job listing; refusing migration submission")
    summary = job.get("Summary")
    summary_id = summary.get("JobID") if isinstance(summary, dict) else None
    direct_id = job.get("ID")
    identity = direct_id if direct_id is not None else summary_id
    if not isinstance(identity, str) or not identity or (direct_id is not None and summary_id is not None and direct_id != summary_id):
        sys.exit("ERROR: Missing or conflicting Nomad job identity; refusing migration submission")
    job_ids.add(identity)
if name in job_ids:
    current = json.loads(subprocess.check_output(["nomad", "job", "inspect", "-json", name]))
    current = current.get("Job", current)
    old_image = current["TaskGroups"][0]["Tasks"][0]["Config"]["image"]
    new_image = requested["TaskGroups"][0]["Tasks"][0]["Config"]["image"]
    # Never placed (still pending, no allocation ever made): nothing touched the
    # database, so a request the cluster cannot place may be replaced.
    if current.get("Status") == "pending":
        never_placed = json.loads(subprocess.check_output(["nomad", "job", "allocs", "-json", name]))
        old_task, new_task = current["TaskGroups"][0]["Tasks"][0], requested["TaskGroups"][0]["Tasks"][0]
        if not never_placed and (old_image != new_image or old_task.get("Resources") != new_task.get("Resources")):
            subprocess.run(["nomad", "job", "stop", "-purge", name], check=True)
            subprocess.run(["nomad", "job", "run", "-json", requested_file], check=True)
            sys.exit(0)
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
