"""Offline CodeDeploy asset-hook regression tests. Run with python3 -m unittest.

Uses an isolated release and fake AWS CLI; no cloud access or app dependencies.
"""

import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path


HOOK = Path(__file__).resolve().parents[2] / "cicd-scripts/upload_assets_to_s3.sh"
FAKE_AWS = r'''#!/usr/bin/env python3
import json
import os
import shutil
import sys
from pathlib import Path

args = sys.argv[1:]
log = Path(os.environ["TEST_AWS_LOG"])
with log.open("a") as output:
    output.write(json.dumps(args) + "\n")
if args[:2] == ["s3", "sync"]:
    if os.environ.get("TEST_FAIL") == "sync":
        sys.exit(1)
    source = Path(args[2])
    destination = Path(os.environ["TEST_BUCKET"]) / args[3].split("/", 3)[-1]
    excluded = [args[index + 1] for index, arg in enumerate(args[:-1]) if arg == "--exclude"]
    for file in source.rglob("*"):
        if not file.is_file() or file.name in excluded:
            continue
        target = destination / file.relative_to(source)
        if not target.exists() or file.stat().st_size != target.stat().st_size or (
            "--size-only" not in args and file.stat().st_mtime > target.stat().st_mtime
        ):
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(file, target)
elif args[:2] == ["s3", "cp"]:
    if os.environ.get("TEST_FAIL") == "manifest" and args[2].endswith("manifest.json"):
        sys.exit(1)
    target = Path(os.environ["TEST_BUCKET"]) / args[3].split("/", 3)[-1]
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(args[2], target)
'''


class UploadAssetsTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="asset-upload-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        scripts = self.root / "cicd-scripts"
        (scripts / "lib").mkdir(parents=True)
        (scripts / "upload_assets_to_s3.sh").write_bytes(HOOK.read_bytes())
        (scripts / "lib/tier_gate.sh").write_text(
            'resolve_deployment_tags() { ENVIRONMENT=staging; '
            'TERRAFORM_MODULE="$TEST_TIER"; FLEET=; export ENVIRONMENT TERRAFORM_MODULE FLEET; }\n'
        )
        self.hook = scripts / "upload_assets_to_s3.sh"
        bin_dir = self.root / "bin"
        bin_dir.mkdir()
        (bin_dir / "aws").write_text(FAKE_AWS)
        (bin_dir / "aws").chmod(0o755)
        self.bin_dir = bin_dir
        self.release = self.root / "release/current/public"
        (self.release / "assets").mkdir(parents=True)
        (self.release / "packs").mkdir()
        (self.release / "assets/application-abc.css").write_text("old!")
        self.manifest = self.release / "packs/manifest.json"
        self.manifest.write_text('{"asset":"old"}')
        shared = self.root / "release/shared"
        shared.mkdir()
        (shared / ".env").write_text("AWS_BUCKET=test-bucket\n")
        self.bucket = self.root / "bucket"
        self.log = self.root / "aws-calls.jsonl"

    def run_hook(self, tier="app-green", failure=""):
        self.log.write_text("")
        env = dict(os.environ, PATH=str(self.bin_dir) + os.pathsep + os.environ["PATH"],
                   SEARCHGOV_ROOT=str(self.root / "release"), TEST_TIER=tier,
                   TEST_BUCKET=str(self.bucket), TEST_AWS_LOG=str(self.log), TEST_FAIL=failure)
        result = subprocess.run(["bash", str(self.hook)], env=env, capture_output=True, text=True)
        calls = [json.loads(line) for line in self.log.read_text().splitlines()]
        return result, calls

    def test_equal_sized_changes_upload_and_manifest_is_published_last(self):
        result, calls = self.run_hook()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.bucket / "packs/manifest.json").read_text(), '{"asset":"old"}')

        self.manifest.write_text('{"asset":"new"}')
        older = (self.bucket / "packs/manifest.json").stat().st_mtime - 10
        os.utime(self.manifest, (older, older))
        asset = self.release / "assets/application-abc.css"
        asset.write_text("new!")
        newer = (self.bucket / "assets/application-abc.css").stat().st_mtime + 10
        os.utime(asset, (newer, newer))
        result, calls = self.run_hook()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.bucket / "assets/application-abc.css").read_text(), "new!")
        self.assertEqual((self.bucket / "packs/manifest.json").read_text(), '{"asset":"new"}')
        syncs = [call for call in calls if call[:2] == ["s3", "sync"]]
        self.assertEqual(len(syncs), 2)
        self.assertTrue(all("--size-only" not in call and "--delete" not in call and
                            "manifest.json" in call and "manifest.json.br" in call for call in syncs))
        self.assertEqual(calls[-1][:2], ["s3", "cp"])
        self.assertEqual(calls[-1][3], "s3://test-bucket/packs/manifest.json")
        self.assertEqual(calls[-1][calls[-1].index("--cache-control") + 1],
                         "no-cache, max-age=0, must-revalidate")
        self.assertIn("MANIFEST_UPLOAD_RESULT=SUCCESS", result.stdout)

    def test_failed_manifest_upload_fails_hook(self):
        result, calls = self.run_hook(failure="manifest")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("reason=pack_manifest_upload_failed", result.stderr)
        self.assertNotIn("[CODEDEPLOY][UPLOAD_ASSETS] RESULT=SUCCESS", result.stdout)
        self.assertEqual(calls[-1][:2], ["s3", "cp"])

    def test_missing_manifest_fails_without_claiming_success(self):
        self.manifest.unlink()
        result, calls = self.run_hook()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("reason=missing_pack_manifest", result.stderr)
        self.assertEqual(calls, [])

    def test_non_app_tier_does_not_call_aws(self):
        result, calls = self.run_hook(tier="crawler-green")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, [])
        self.assertIn("RESULT=SKIPPED no_S3_calls=true", result.stdout)

    def test_failed_bundle_sync_never_publishes_manifest(self):
        result, calls = self.run_hook(failure="sync")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("reason=aws_sync_failed", result.stderr)
        self.assertFalse(any(call[:2] == ["s3", "cp"] for call in calls))


if __name__ == "__main__":
    unittest.main()