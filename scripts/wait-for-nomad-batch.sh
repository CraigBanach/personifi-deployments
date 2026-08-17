#!/bin/bash
set -euo pipefail

JOB_NAME="${1:?Nomad job name is required}"

for _ in $(seq 1 60); do
    allocation_state="$(nomad job allocs -json "$JOB_NAME" 2>/dev/null | python3 -c '
import json, sys
allocations = json.load(sys.stdin)
if not allocations:
    print("waiting")
elif any(a.get("ClientStatus") in ("failed", "lost") or any(t.get("Failed") for t in a.get("TaskStates", {}).values()) for a in allocations):
    print("failed")
elif all(a.get("ClientStatus") == "complete" and a.get("TaskStates") and all(t.get("State") == "dead" and not t.get("Failed") for t in a["TaskStates"].values()) for a in allocations):
    print("complete")
else:
    print("waiting")
' 2>/dev/null || echo waiting)"

    case "$allocation_state" in
        complete) exit 0 ;;
        failed) echo "ERROR: Batch job $JOB_NAME has a failed allocation" >&2; exit 1 ;;
    esac
    sleep 2
done

echo "ERROR: Timed out waiting for successful allocation for $JOB_NAME" >&2
exit 1
