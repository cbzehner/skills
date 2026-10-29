"""Deterministic validation for the separately selected infrastructure skill pack.

Run with: python3 -m unittest discover -s tests -p 'test_infrastructure.py' -v
No model calls, external resources, or writes outside temporary directories.
"""
import json
import os
import re
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
NAMES = (
    "nix-infrastructure", "hetzner-operations", "linux-systemd",
    "podman-quadlet", "sre-incident-response",
)


class SkillStructure(unittest.TestCase):
    def test_separate_manifest(self):
        names = ROOT.joinpath("infrastructure-manifest.txt").read_text().splitlines()
        self.assertEqual(names, list(NAMES))
        workflow = set(ROOT.joinpath("manifest.txt").read_text().splitlines())
        self.assertFalse(workflow.intersection(NAMES))

    def test_structure_sources_probes_and_fingerprints(self):
        for name in NAMES:
            with self.subTest(skill=name):
                directory = ROOT / "skills" / name
                text = (directory / "SKILL.md").read_text()
                front, body = text.removeprefix("---\n").split("\n---\n", 1)
                self.assertIn(f"name: {name}\n", front)
                description = front.split("description: >-\n", 1)[1].split("\nlicense:", 1)[0]
                self.assertLess(len(" ".join(description.split())), 350)
                self.assertIn('version: "0.1.0"', front)
                self.assertIn('reviewed: "2026-10-28"', front)
                self.assertLess(len(text.split()), 1200)
                self.assertLess(len(text.splitlines()), 150)
                for heading in ("Inputs and result", "Workflow", "When NOT to use", "What to skip", "Handoffs", "Sources"):
                    self.assertIn(f"## {heading}", body)
                self.assertNotRegex(text, r"\b(?:TODO|FIXME|placeholder)\b")
                links = re.findall(r"\[[^\]]+\]\(([^)]+)\)", body)
                self.assertGreaterEqual(len(links), 2)
                self.assertTrue(all(link.startswith("https://") for link in links))
                fingerprints = (directory / "tests/fingerprints.txt").read_text().splitlines()
                self.assertGreaterEqual(len(fingerprints), 2)
                for fingerprint in fingerprints:
                    self.assertIn(fingerprint, body)
                # JSON is a YAML subset, keeping the stored probe panel dependency-free.
                probes = json.loads((directory / "tests/probes.yaml").read_text())["probes"]
                self.assertGreaterEqual(sum(p["expected_skills"] == [name] for p in probes), 6)
                self.assertGreaterEqual(sum(p["expected_skills"] != [name] for p in probes), 4)
                for probe in probes:
                    self.assertTrue(set(probe["expected_skills"]) <= set(NAMES))
                    self.assertNotIn(name, probe["prompt"])
                    if probe["expected_skills"] != [name]:
                        self.assertTrue(probe.get("note"))
                    self.assertNotRegex(probe["prompt"], r"cbzehner|/Users/|withinterfacelabs")

    def test_behavior_criteria_are_preregistered(self):
        cases = json.loads(ROOT.joinpath("tests/infrastructure-behavior.json").read_text())
        self.assertEqual(set(cases), set(NAMES))
        for name, case in cases.items():
            with self.subTest(skill=name):
                self.assertTrue(case["prompt"])
                self.assertEqual(len(case["criteria"]), 4)


class Installer(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="infrastructure-installer-")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.repo = self.base / "repo"
        self.home = self.base / "home"
        self.repo.mkdir()
        self.home.mkdir()
        shutil.copyfile(ROOT / "install.sh", self.repo / "install.sh")
        shutil.copyfile(ROOT / "infrastructure-manifest.txt", self.repo / "infrastructure-manifest.txt")
        (self.repo / "manifest.txt").write_text("workflow-example\n")
        for name in (*NAMES, "workflow-example"):
            source = self.repo / "skills" / name
            source.mkdir(parents=True)
            (source / "SKILL.md").write_text(f"# {name}\n")

    def run_installer(self, *args):
        return subprocess.run(
            [os.environ.get("INSTALLER_BASH", "bash"), str(self.repo / "install.sh"), *args],
            env={**os.environ, "HOME": str(self.home)}, cwd=self.base,
            text=True, capture_output=True, timeout=10,
        )

    def assert_installed_names(self, destination, names):
        self.assertEqual({p.name for p in destination.iterdir()}, set(names))
        for name in names:
            self.assertEqual((destination / name).resolve(), (self.repo / "skills" / name).resolve())

    def test_selected_pack_only_and_idempotence(self):
        run = self.run_installer("agents", "--manifest", "infrastructure-manifest.txt")
        self.assertEqual(run.returncode, 0, run.stderr)
        destination = self.home / ".agents/skills"
        self.assert_installed_names(destination, NAMES)
        before = {p.name: p.lstat().st_mtime_ns for p in destination.iterdir()}
        run = self.run_installer("agents", "--manifest", "infrastructure-manifest.txt")
        self.assertEqual(run.returncode, 0, run.stderr)
        self.assertEqual(before, {p.name: p.lstat().st_mtime_ns for p in destination.iterdir()})
        self.assertFalse((self.home / ".claude").exists())
        self.assertFalse((self.home / ".codex").exists())

    def test_default_manifest_and_explicit_names_preserved(self):
        run = self.run_installer("codex")
        self.assertEqual(run.returncode, 0, run.stderr)
        self.assert_installed_names(self.home / ".codex/skills", ["workflow-example"])
        run = self.run_installer("claude", "nix-infrastructure")
        self.assertEqual(run.returncode, 0, run.stderr)
        self.assert_installed_names(self.home / ".claude/skills", ["nix-infrastructure"])

    def test_absolute_manifest_comments_and_final_line(self):
        manifest = self.base / "selection.txt"
        manifest.write_text("# selected\n\nnix-infrastructure\nlinux-systemd")
        run = self.run_installer("agents", "--manifest", str(manifest))
        self.assertEqual(run.returncode, 0, run.stderr)
        self.assert_installed_names(self.home / ".agents/skills", ["nix-infrastructure", "linux-systemd"])

    def test_invalid_arguments_make_no_links(self):
        for arguments in (
            ("--manifest",), ("--manifest", "--copy"), ("--unknown",),
            ("--manifest", "infrastructure-manifest.txt", "nix-infrastructure"),
            ("../outside",), ("--manifest", "missing.txt"),
        ):
            with self.subTest(arguments=arguments):
                run = self.run_installer("agents", *arguments)
                self.assertNotEqual(run.returncode, 0)
                self.assertFalse((self.home / ".agents").exists())

    def test_incomplete_manifest_fails_before_any_links(self):
        manifest = self.repo / "infrastructure-manifest.txt"
        for invalid in ("missing-example", "../outside"):
            with self.subTest(invalid=invalid):
                manifest.write_text(f"nix-infrastructure\n{invalid}\n")
                run = self.run_installer("agents", "--manifest", "infrastructure-manifest.txt")
                self.assertNotEqual(run.returncode, 0)
                self.assertFalse((self.home / ".agents").exists())

    def test_empty_manifest_is_no_op(self):
        (self.repo / "empty.txt").write_text("# intentionally empty\n\n")
        run = self.run_installer("agents", "--manifest", "empty.txt")
        self.assertEqual(run.returncode, 0, run.stderr)
        self.assertFalse((self.home / ".agents").exists())

    def test_existing_directory_preserved_without_force(self):
        target = self.home / ".agents/skills/nix-infrastructure"
        target.mkdir(parents=True)
        (target / "local.txt").write_text("preserve me")
        run = self.run_installer("agents", "nix-infrastructure")
        self.assertEqual(run.returncode, 0, run.stderr)
        self.assertFalse(target.is_symlink())
        self.assertEqual((target / "local.txt").read_text(), "preserve me")
        self.assertIn("skip", run.stderr)

    def test_copy_and_force_remain_explicit(self):
        target = self.home / ".agents/skills/nix-infrastructure"
        target.mkdir(parents=True)
        (target / "local.txt").write_text("replace only with force")
        run = self.run_installer("agents", "nix-infrastructure", "--force", "--copy")
        self.assertEqual(run.returncode, 0, run.stderr)
        self.assertFalse(target.is_symlink())
        self.assertEqual((target / "SKILL.md").read_text(), "# nix-infrastructure\n")
        self.assertFalse((target / "local.txt").exists())

    def test_help_includes_manifest_option(self):
        run = self.run_installer("--help")
        self.assertEqual(run.returncode, 0, run.stderr)
        self.assertIn("--manifest", run.stdout)
        self.assertFalse(list(self.home.iterdir()))


if __name__ == "__main__":
    unittest.main()
