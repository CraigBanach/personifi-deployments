#!/usr/bin/env python3
"""Merge deployment settings without discarding separately installed secrets."""
import json
import subprocess
import sys


def update(path, planned, run=subprocess.run):
    result = run(['nomad', 'var', 'get', '-out=json', path], capture_output=True, text=True)
    if result.returncode:
        # Never treat an ACL/network failure as an absent variable.
        raise RuntimeError('Cannot read current secrets; no write attempted')
    current = json.loads(result.stdout)
    items = dict(current['Items'])
    items.update(planned['Items'])
    if items == current['Items']:
        return
    payload = {'Path': path, 'Namespace': current.get('Namespace', 'default'), 'Items': items}
    result = run(['nomad', 'var', 'put', '-check-index=' + str(current['ModifyIndex']),
                  '-in=json', '-out=none', '-'], input=json.dumps(payload), capture_output=True, text=True)
    if result.returncode:
        # Do not print Nomad's output, which can contain variable values.
        raise RuntimeError('Secrets CAS update failed; retry deployment after checking concurrent changes')


if __name__ == '__main__':
    try:
        with open(sys.argv[2], encoding='utf-8') as planned_file:
            update(sys.argv[1], json.load(planned_file))
    except Exception:
        sys.exit('Secret update failed safely; no force overwrite or secret output')
