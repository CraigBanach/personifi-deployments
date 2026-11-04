#!/usr/bin/env python3
"""Offline validation of both derived jobs using the real Nomad HCL parser."""
import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("managed", root / "scripts/tcg-managed-rollout.py")
managed = importlib.util.module_from_spec(spec)
spec.loader.exec_module(managed)
text = (root / "infra/jobs/tcg-medusa.nomad.template").read_text()
replacements = {
    "DEPLOYMENT_ENVIRONMENT_PLACEHOLDER": "production",
    "BACKEND_IMAGE_PLACEHOLDER": "registry/backend@sha256:" + "a" * 64,
    "STOREFRONT_IMAGE_PLACEHOLDER": "registry/storefront@sha256:" + "b" * 64,
    "BACKEND_DEPLOY_VERSION_PLACEHOLDER": "sha256:" + "a" * 64,
    "STOREFRONT_DEPLOY_VERSION_PLACEHOLDER": "sha256:" + "b" * 64,
    "TCG_MEDUSA_STATE_PATH_PLACEHOLDER": "/opt/tcg-medusa/production",
    "TCG_MEDUSA_VAR_PATH_PLACEHOLDER": "tcg-store/medusa/production",
    "PRODUCTION_DATA_MUTATION_PLACEHOLDER": "false",
    "STOREFRONT_REDIRECT_HOST_PLACEHOLDER": "www.freesplash.co.uk",
    "STOREFRONT_HOST_PLACEHOLDER": "freesplash.co.uk",
    "API_HOST_PLACEHOLDER": "api.freesplash.co.uk",
}
for key, value in replacements.items(): text = text.replace(key, value)
if "PLACEHOLDER" in text: raise ValueError("Unresolved template placeholder")
with tempfile.TemporaryDirectory() as directory:
    template = Path(directory) / "service.nomad"
    template.write_text(text)
    original = json.loads(subprocess.check_output(["nomad", "job", "run", "-output", str(template)]))
    for name, document in zip(["service", "migration"], managed.jobs(original)):
        path = Path(directory) / f"{name}.json"
        path.write_text(json.dumps(document))
        subprocess.run(["nomad", "job", "validate", "-json", str(path)], check=True)
