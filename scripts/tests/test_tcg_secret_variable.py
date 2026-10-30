import importlib.util
import json
from pathlib import Path
from types import SimpleNamespace
import unittest
from unittest.mock import Mock

spec = importlib.util.spec_from_file_location('update_secrets', Path(__file__).parents[1] / 'update-tcg-secret-variable.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class SecretVariableTest(unittest.TestCase):
    def runner(self, items, write_code=0):
        return Mock(side_effect=[
            SimpleNamespace(returncode=0, stdout=json.dumps({'Items': items, 'ModifyIndex': 123, 'Namespace': 'default'})),
            SimpleNamespace(returncode=write_code, stdout='', stderr='must not be exposed'),
        ])

    def test_preserves_separately_installed_keys_and_uses_cas(self):
        runner = self.runner({'brevo_api_key': 'fixture-only', 'other_service_key': 'keep', 'jwt_secret': 'old'})
        module.update('tcg-store/medusa/production/secrets', {'Items': {'jwt_secret': 'new'}}, runner)
        command = runner.call_args.args[0]
        self.assertIn('-check-index=123', command)
        self.assertIn('-out=none', command)
        self.assertNotIn('-force', command)
        self.assertEqual(json.loads(runner.call_args.kwargs['input'])['Items'],
                         {'brevo_api_key': 'fixture-only', 'other_service_key': 'keep', 'jwt_secret': 'new'})

    def test_unchanged_values_do_not_write(self):
        runner = self.runner({'jwt_secret': 'same', 'brevo_api_key': 'keep'})
        module.update('scope/secrets', {'Items': {'jwt_secret': 'same'}}, runner)
        self.assertEqual(runner.call_count, 1)

    def test_cas_failure_is_not_forced_or_retried(self):
        runner = self.runner({'jwt_secret': 'old'}, write_code=1)
        with self.assertRaisesRegex(RuntimeError, 'CAS update failed'):
            module.update('scope/secrets', {'Items': {'jwt_secret': 'new'}}, runner)
        self.assertEqual(runner.call_count, 2)

    def test_unreadable_variable_is_not_overwritten(self):
        runner = Mock(return_value=SimpleNamespace(returncode=1))
        with self.assertRaisesRegex(RuntimeError, 'no write attempted'):
            module.update('scope/secrets', {'Items': {'jwt_secret': 'new'}}, runner)
        self.assertEqual(runner.call_count, 1)


if __name__ == '__main__':
    unittest.main()
