import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


BRIDGE_PATH = (
    Path(__file__).parents[1]
    / "skills"
    / "collaborating-with-hermes"
    / "scripts"
    / "hermes_bridge.py"
)


def load_bridge():
    spec = importlib.util.spec_from_file_location("hermes_bridge", BRIDGE_PATH)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class HermesBridgeTest(unittest.TestCase):
    def handoff(self):
        return {
            "schema_version": 1,
            "status": "complete",
            "summary": "The consultation found one verifiable design constraint.",
            "findings": [
                {
                    "claim": "The wrapper uses cwd instead of shell command concatenation.",
                    "confidence": "high",
                    "evidence_ids": ["E1"],
                }
            ],
            "evidence": [
                {
                    "id": "E1",
                    "source": "hermes_bridge.py",
                    "locator": "skills/collaborating-with-hermes/scripts/hermes_bridge.py:1",
                }
            ],
            "uncertainties": [],
            "verification_needed": ["Run the bridge unit test."],
        }

    def test_build_command_uses_fixed_oneshot_and_whitelisted_flags(self):
        bridge = load_bridge()

        command = bridge.build_command(
            "analyze this",
            worktree=True,
            ignore_rules=True,
            toolsets="web,terminal",
            skills="research",
        )

        self.assertEqual(command[:3], ["hermes", "--cli", "-z"])
        self.assertEqual(command[3], "analyze this")
        self.assertIn("--worktree", command)
        self.assertIn("--ignore-rules", command)
        self.assertIn("-t", command)
        self.assertIn("--skills", command)
        self.assertNotIn("cd", command)

    def test_direct_mode_returns_full_answer(self):
        bridge = load_bridge()

        result = bridge.build_hermes_result(
            prompt="implement",
            working_directory="/workspace",
            stdout="full answer",
            stderr="",
            exit_code=0,
            consult_handoff=False,
            domain="general",
            marker=None,
        )

        self.assertTrue(result["success"])
        self.assertEqual(result["agent_messages"], "full answer")
        self.assertIn("AUDIT_REQUIRED", result)

    def test_consult_mode_returns_handoff_without_raw_text(self):
        bridge = load_bridge()
        marker = "CONSULT_HANDOFF_TEST"
        canary = "private-canary-hermes-632"
        raw = f"{canary}\n{marker}\n{json.dumps(self.handoff())}\n{marker}_END"
        with tempfile.TemporaryDirectory() as temp_root:
            result = bridge.build_hermes_result(
                prompt="review",
                working_directory="/workspace",
                stdout=raw,
                stderr="",
                exit_code=0,
                consult_handoff=True,
                domain="bio",
                marker=marker,
                temp_root=temp_root,
            )

            serialized = json.dumps(result)
            self.assertTrue(result["success"])
            self.assertEqual(result["handoff"], self.handoff())
            self.assertNotIn("agent_messages", result)
            self.assertNotIn(canary, serialized)
            self.assertEqual(
                Path(result["artifact"]["raw_path"]).read_text(encoding="utf-8"), raw
            )

    def test_invalid_consult_format_does_not_expose_answer(self):
        bridge = load_bridge()
        canary = "private-canary-hermes-invalid-519"
        with tempfile.TemporaryDirectory() as temp_root:
            result = bridge.build_hermes_result(
                prompt="review",
                working_directory="/workspace",
                stdout=canary,
                stderr="secret stderr details",
                exit_code=0,
                consult_handoff=True,
                domain="cyber",
                marker="CONSULT_HANDOFF_TEST",
                temp_root=temp_root,
            )

            serialized = json.dumps(result)
            self.assertFalse(result["success"])
            self.assertEqual(result["error_code"], "invalid_handoff_format")
            self.assertNotIn(canary, serialized)
            self.assertNotIn("secret stderr details", serialized)
            self.assertIn("Cyber Verification Program", result["FALLBACK_GUIDANCE"])

    def test_process_failure_does_not_leak_valid_looking_handoff(self):
        bridge = load_bridge()
        marker = "CONSULT_HANDOFF_TEST"
        raw = f"analysis\n{marker}\n{json.dumps(self.handoff())}\n{marker}_END"
        with tempfile.TemporaryDirectory() as temp_root:
            result = bridge.build_hermes_result(
                prompt="review",
                working_directory="/workspace",
                stdout=raw,
                stderr="",
                exit_code=1,
                consult_handoff=True,
                domain="general",
                marker=marker,
                temp_root=temp_root,
            )

        self.assertFalse(result["success"])
        self.assertEqual(result["error_code"], "hermes_process_failed")
        self.assertNotIn("handoff", result)

    def test_nonzero_exit_uses_stable_error_without_stderr(self):
        bridge = load_bridge()

        result = bridge.build_hermes_result(
            prompt="review",
            working_directory="/workspace",
            stdout="",
            stderr="credential secret appeared here",
            exit_code=2,
            consult_handoff=False,
            domain="general",
            marker=None,
        )

        self.assertFalse(result["success"])
        self.assertEqual(result["error_code"], "hermes_process_failed")
        self.assertNotIn("credential secret", json.dumps(result))


if __name__ == "__main__":
    unittest.main()
