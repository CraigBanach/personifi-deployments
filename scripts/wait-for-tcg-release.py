#!/usr/bin/env python3
"""Verify public identity and availability; never roll back database changes."""
import json
import re
import sys
import time
import urllib.request


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def ready(backend, storefront, opener):
    for url, digest in [
        ("https://api.freesplash.co.uk/release", backend),
        ("https://freesplash.co.uk/api/release", storefront),
        ("https://api.freesplash.co.uk/health", None),
        ("https://freesplash.co.uk/gb", None),
    ]:
        request = urllib.request.Request(url, headers={"Cache-Control": "no-cache, no-store"})
        with opener.open(request, timeout=10) as response:
            if response.status != 200:
                return False
            if digest and json.load(response).get("image_digest") != digest:
                return False
    return True


if __name__ == "__main__":
    backend, storefront = sys.argv[1:]
    if not all(re.fullmatch(r"sha256:[0-9a-f]{64}", d) for d in [backend, storefront]):
        sys.exit("ERROR: Expected immutable image digests")
    deadline, consecutive = time.monotonic() + 900, 0
    opener = urllib.request.build_opener(NoRedirect)
    while time.monotonic() < deadline:
        try:
            consecutive = consecutive + 1 if ready(backend, storefront, opener) else 0
        except Exception:
            consecutive = 0
        if consecutive >= 3:
            print("Intended backend/storefront images are healthy and serving traffic")
            sys.exit(0)
        time.sleep(5)
    sys.exit("ERROR: Release readiness timed out; inspect Nomad. Database rollback was not attempted.")
