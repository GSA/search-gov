#!/usr/bin/env python3
"""Offline tests for the CodeDeploy asset hook. Run with python3 -m unittest.

The AWS executable and EC2 tag resolver are replaced in a temporary tree.
No live AWS calls or application dependencies are required.
"""

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


REPO = Path(__file__).resolve().parent.parent


class UploadAssetsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        script_dir = self.root / 'cicd-scripts'
        (script_dir / 'lib').mkdir(parents=True)
        shutil.copyfile(REPO / 'cicd-scripts/upload_assets_to_s3.sh',
                        script_dir / 'upload_assets_to_s3.sh')
        (script_dir / 'lib/tier_gate.sh').write_text('''resolve_deployment_tags() {
  if [ "${TEST_FAIL_TAGS:-0}" = 1 ]; then exit 1; fi
  ENVIRONMENT="$TEST_ENVIRONMENT"
  TERRAFORM_MODULE="$TEST_TIER"
  INSTANCE_NAME="$TEST_NAME"
  FLEET=""
  export ENVIRONMENT TERRAFORM_MODULE INSTANCE_NAME FLEET
}
''')
        self.hook = script_dir / 'upload_assets_to_s3.sh'
        self.app = self.root / 'app'
        self.assets = self.app / 'current/public/assets'
        self.packs = self.app / 'current/public/packs'
        self.assets.mkdir(parents=True)
        (self.packs / 'js').mkdir(parents=True)
        (self.packs / 'css').mkdir()
        (self.assets / 'application.css').write_text('body{}')
        (self.packs / 'js/application-abcd.js').write_text('application')
        (self.packs / 'css/application-1234.css').write_text('styles')
        self.manifest = self.packs / 'manifest.json'
        self.manifest.write_text('''{"application.js":"/packs/js/application-abcd.js",
"application.css":"/packs/css/application-1234.css",
"entrypoints":{"application":{}},
"js/other.js":"https://example.test/packs/js/other.js"}''')
        (self.app / 'shared').mkdir()
        (self.app / 'shared/.env').write_text('AWS_BUCKET=example-bucket\n')
        self.log = self.root / 'aws.log'
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        aws = self.bin / 'aws'
        aws.write_text('''#!/bin/sh
printf '%s\\n' "$*" >> "$TEST_AWS_LOG"
case "${TEST_AWS_FAILURE:-}:$1:$2" in
  sync:s3:sync) exit 1 ;;
  cp:s3:cp) exit 1 ;;
esac
if [ "${TEST_AWS_FAILURE:-}" = manifest ] && [ "$1 $2" = 's3 cp' ]; then
  case "$*" in *'/packs/manifest.json'*) exit 1 ;; esac
fi
exit 0
''')
        aws.chmod(0o755)

    def run_hook(self, environment='dev', tier='app', name='app-test-instance-1',
                 fail='', missing_env=False, fail_tags=False):
        self.log.write_text('')
        env = dict(os.environ, PATH=str(self.bin) + os.pathsep + os.environ['PATH'],
                   TEST_ENVIRONMENT=environment, TEST_TIER=tier, TEST_NAME=name,
                   TEST_FAIL_TAGS='1' if fail_tags else '0', TEST_AWS_FAILURE=fail,
                   TEST_AWS_LOG=str(self.log), SEARCHGOV_ROOT=str(self.app))
        if missing_env:
            (self.app / 'shared/.env').rename(self.app / 'shared/.env.saved')
        try:
            result = subprocess.run(['bash', str(self.hook)], env=env, text=True,
                                    capture_output=True, timeout=15)
        finally:
            if missing_env:
                (self.app / 'shared/.env.saved').rename(self.app / 'shared/.env')
        return result, self.log.read_text().splitlines()

    def test_skips_production_and_non_app_hosts_without_s3_or_config(self):
        self.assets.rename(self.assets.with_name('assets.saved'))
        self.packs.rename(self.packs.with_name('packs.saved'))
        for env, tier in [('production', 'app'), ('production', 'app-green'),
                          ('production', 'crawler-green'), ('dev', 'cron'),
                          ('staging', 'crawler-green'), ('staging', 'cron-green')]:
            with self.subTest(env=env, tier=tier):
                result, calls = self.run_hook(env, tier, name='', missing_env=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn('RESULT=SKIPPED no_S3_calls=true', result.stdout)
                self.assertEqual(calls, [])

    def test_missing_packs_fails_before_s3(self):
        self.packs.rename(self.packs.with_name('packs.saved'))
        result, calls = self.run_hook()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('reason=missing_asset_directory prefix=/packs', result.stderr)
        self.assertEqual(calls, [])

    def test_missing_assets_fails_before_s3(self):
        self.assets.rename(self.assets.with_name('assets.saved'))
        result, calls = self.run_hook('staging', 'app-green')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('reason=missing_asset_directory prefix=/assets', result.stderr)
        self.assertEqual(calls, [])

    def test_missing_both_directories_fails_before_s3(self):
        self.assets.rename(self.assets.with_name('assets.saved'))
        self.packs.rename(self.packs.with_name('packs.saved'))
        result, calls = self.run_hook()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('reason=missing_asset_directory prefix=/assets', result.stderr)
        self.assertEqual(calls, [])

    def test_unknown_tags_and_hostnames_fail_closed(self):
        for options in ({'fail_tags': True}, {'name': ''},
                        {'name': 'app-test-instance-unknown'}):
            with self.subTest(options=options):
                result, calls = self.run_hook(**options)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(calls, [])

    def test_only_designated_app_host_publishes_manifest_last(self):
        for environment, tier in [('dev', 'app'), ('staging', 'app-green')]:
            for number in (1, 2):
                with self.subTest(env=environment, host=number):
                    result, calls = self.run_hook(environment, tier,
                                                  name=f'app-test-instance-{number}')
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(sum('s3 sync' in call for call in calls), 2)
                    self.assertTrue(all('--delete' not in call for call in calls))
                    self.assertTrue(all('--size-only' not in call for call in calls))
                    self.assertIn('--exclude manifest.json', calls[0])
                    manifest_calls = [call for call in calls if '/packs/manifest.json' in call]
                    self.assertEqual(len(manifest_calls), 1 if number == 1 else 0)
                    if number == 1:
                        self.assertEqual(calls[-1], manifest_calls[0])
                        self.assertIn('no-cache, max-age=0, must-revalidate', calls[-1])
                    else:
                        self.assertIn('reason=not_designated_publisher', result.stdout)

    def test_stable_copy_failure_stops_before_manifest(self):
        result, calls = self.run_hook(fail='cp')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('reason=stable_asset_upload_failed', result.stderr)
        self.assertNotIn('MANIFEST_UPLOAD_STARTED', result.stdout)
        self.assertEqual(len([call for call in calls if '/packs/manifest.json' in call]), 0)

    def test_sync_failure_stops_before_manifest(self):
        result, calls = self.run_hook(fail='sync')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('reason=aws_sync_failed', result.stderr)
        self.assertEqual(len(calls), 1)

    def test_manifest_copy_failure_is_not_reported_as_success(self):
        result, calls = self.run_hook(fail='manifest')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('reason=pack_manifest_upload_failed', result.stderr)
        self.assertEqual(sum('/packs/manifest.json' in call for call in calls), 1)
        self.assertNotIn('RESULT=SUCCESS environment=dev', result.stdout)

    def test_same_sized_stable_file_is_not_excluded_by_size_only(self):
        # A changed CSS file may keep the same length. AWS sync must still
        # compare mtimes, and the explicit stable-name copy must run last.
        old_size = (self.assets / 'application.css').stat().st_size
        (self.assets / 'application.css').write_text('div{x}')
        self.assertEqual((self.assets / 'application.css').stat().st_size, old_size)
        result, calls = self.run_hook()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(all('--size-only' not in call for call in calls))
        self.assertTrue(any('application.css' in call and 's3 cp' in call
                            for call in calls))

    def test_missing_or_invalid_manifest_and_bundle_fail_before_s3(self):
        cases = (None, '{}', '{bad json}',
                 '{"application.js":"/packs/js/missing.js",'
                 '"application.css":"/packs/css/application-1234.css"}')
        for value in cases:
            with self.subTest(value=value):
                if value is None:
                    self.manifest.unlink(missing_ok=True)
                else:
                    self.manifest.write_text(value)
                result, calls = self.run_hook()
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(calls, [])

    def test_missing_configuration_fails_before_s3(self):
        result, calls = self.run_hook(missing_env=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('reason=missing_env_file', result.stderr)
        self.assertEqual(calls, [])

    def test_tier_gate_exposes_name_from_same_tag_lookup(self):
        tags = ('{"Tags":[{"Key":"terraform_module","Value":"app"},'
                '{"Key":"environment","Value":"dev"},'
                '{"Key":"Name","Value":"app-test-instance-1"}]}')
        script = ('source "$1"; get_instance_tags() { printf "%s\\n" "$TEST_TAGS"; }; '
                  'resolve_deployment_tags; printf "%s|%s|%s" '
                  '"$ENVIRONMENT" "$TERRAFORM_MODULE" "$INSTANCE_NAME"')
        result = subprocess.run(['bash', '-c', script, '--',
                                 str(REPO / 'cicd-scripts/lib/tier_gate.sh')],
                                env=dict(os.environ, TEST_TAGS=tags), text=True,
                                capture_output=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, 'dev|app|app-test-instance-1')
        self.assertIn('Name=key,Values=terraform_module,Fleet,environment,Name',
                      (REPO / 'cicd-scripts/lib/tier_gate.sh').read_text())


if __name__ == '__main__':
    unittest.main()