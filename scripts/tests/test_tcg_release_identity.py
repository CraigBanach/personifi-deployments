"""Render only the deployment template. Never invoke Nomad or read live secrets."""
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = (ROOT / "scripts/quick-deploy-tcg-medusa.sh").read_text()
TEMPLATE = (ROOT / "infra/jobs/tcg-medusa.nomad.template").read_text()


def render(backend, storefront):
    values = {
        "BACKEND_IMAGE": backend,
        "STOREFRONT_IMAGE": storefront,
        "BACKEND_DEPLOY_VERSION": backend.rsplit("@", 1)[1],
        "STOREFRONT_DEPLOY_VERSION": storefront.rsplit("@", 1)[1],
        "DEPLOYMENT_ENVIRONMENT": "production",
        "VAR_PATH": "tcg-store/medusa/production",
        "STATE_PATH": "/opt/tcg-medusa/production",
        "STOREFRONT_HOST": "freesplash.co.uk",
        "STOREFRONT_REDIRECT_HOST": "www.freesplash.co.uk",
        "API_HOST": "api.freesplash.co.uk",
    }
    result = TEMPLATE
    # Follow the real renderer's substitution wiring, not a separate token map.
    for token, variable in re.findall(r's\|([A-Z_]+_PLACEHOLDER)\|\$([A-Z_]+)\|g', SCRIPT):
        result = result.replace(token, values[variable])
    result = result.replace("PRODUCTION_DATA_MUTATION_PLACEHOLDER", "false")
    return "\n".join(line for line in result.splitlines() if "PRODUCTION_REDIRECT_" not in line)


class ReleaseIdentityTests(unittest.TestCase):
    backend = "ghcr.io/craigbanach/tcg-store-backend@sha256:" + "a" * 64
    storefront = "ghcr.io/craigbanach/tcg-store-storefront@sha256:" + "b" * 64

    def test_versions_derive_from_pinned_images_not_wall_clock(self):
        self.assertIn('BACKEND_DEPLOY_VERSION="${BACKEND_IMAGE##*@}"', SCRIPT)
        self.assertIn('STOREFRONT_DEPLOY_VERSION="${STOREFRONT_IMAGE##*@}"', SCRIPT)
        self.assertNotIn('DEPLOY_VERSION="$(date', SCRIPT)

    def test_noop_releases_render_identical_job_specs(self):
        first = render(self.backend, self.storefront)
        self.assertEqual(first, render(self.backend, self.storefront))
        self.assertNotIn("_PLACEHOLDER", first)
        self.assertIn('DEPLOY_VERSION = "sha256:' + "a" * 64 + '"', first)
        self.assertIn('DEPLOY_VERSION = "sha256:' + "b" * 64 + '"', first)

    def test_storefront_change_does_not_change_backend_config(self):
        before = render(self.backend, self.storefront).split('task "storefront"', 1)[0]
        after = render(self.backend, self.storefront.replace("b" * 64, "c" * 64)).split('task "storefront"', 1)[0]
        self.assertEqual(before, after)

    def test_backend_change_does_not_change_storefront_config(self):
        before = render(self.backend, self.storefront).split('task "storefront"', 1)[1]
        after = render(self.backend.replace("a" * 64, "c" * 64), self.storefront).split('task "storefront"', 1)[1]
        self.assertEqual(before, after)


if __name__ == "__main__":
    unittest.main()
