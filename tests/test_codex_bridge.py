import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


BRIDGE_PATH = (
    Path(__file__).parents[1]
    / "skills"
    / "collaborating-with-codex"
    / "scripts"
    / "codex_bridge.py"
)
SPEC = importlib.util.spec_from_file_location("codex_bridge", BRIDGE_PATH)
codex_bridge = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(codex_bridge)
AUDIT_REQUIRED = codex_bridge.AUDIT_REQUIRED
build_codex_result = codex_bridge.build_codex_result
parse_codex_lines = codex_bridge.parse_codex_lines


class CodexBridgeTest(unittest.TestCase):
    def lines(self, answer):
        return [
            json.dumps({"type": "thread.started", "thread_id": "thread-123"}),
            json.dumps({"type": "item.completed", "item": {"type": "agent_message", "text": answer}}),
            json.dumps({"type": "turn.completed"}),
        ]

    def handoff(self):
        return {
            "schema_version": 1,
            "status": "complete",
            "summary": "The design keeps raw output outside the main context.",
            "findings": [
                {
                    "claim": "Consult output is isolated before bridge stdout.",
                    "confidence": "high",
                    "evidence_ids": ["E1"],
                }
            ],
            "evidence": [
                {
                    "id": "E1",
                    "source": "codex_bridge.py",
                    "locator": "skills/collaborating-with-codex/scripts/codex_bridge.py:1",
                }
            ],
            "uncertainties": [],
            "verification_needed": ["Run bridge unit tests."],
        }

    def test_direct_mode_preserves_existing_result_contract(self):
        parsed = parse_codex_lines(self.lines("full answer"))

        result = build_codex_result(
            parsed,
            prompt="analyze",
            working_directory="/workspace",
            consult_handoff=False,
            domain="general",
            marker=None,
            return_all_messages=True,
        )

        self.assertTrue(result["success"])
        self.assertEqual(result["SESSION_ID"], "thread-123")
        self.assertEqual(result["agent_messages"], "full answer")
        self.assertIn("all_messages", result)
        self.assertEqual(result["AUDIT_REQUIRED"], AUDIT_REQUIRED)

    def test_consult_mode_returns_handoff_without_raw_text(self):
        marker = "CONSULT_HANDOFF_TEST"
        canary = "private-canary-codex-921"
        answer = f"{canary}\n{marker}\n{json.dumps(self.handoff())}\n{marker}_END"
        parsed = parse_codex_lines(self.lines(answer))
        with tempfile.TemporaryDirectory() as temp_root:
            result = build_codex_result(
                parsed,
                prompt="review",
                working_directory="/workspace",
                consult_handoff=True,
                domain="cyber",
                marker=marker,
                return_all_messages=False,
                temp_root=temp_root,
            )

            serialized = json.dumps(result)
            self.assertTrue(result["success"])
            self.assertEqual(result["handoff_status"], "valid")
            self.assertEqual(result["handoff"], self.handoff())
            self.assertNotIn("agent_messages", result)
            self.assertNotIn("all_messages", result)
            self.assertNotIn(canary, serialized)
            self.assertEqual(
                Path(result["artifact"]["raw_path"]).read_text(encoding="utf-8"), answer
            )
            self.assertIn("Cyber Verification Program", result["FALLBACK_GUIDANCE"])

    def test_invalid_consult_format_fails_closed(self):
        canary = "private-canary-codex-invalid-144"
        parsed = parse_codex_lines(self.lines(canary))
        with tempfile.TemporaryDirectory() as temp_root:
            result = build_codex_result(
                parsed,
                prompt="review",
                working_directory="/workspace",
                consult_handoff=True,
                domain="bio",
                marker="CONSULT_HANDOFF_TEST",
                return_all_messages=False,
                temp_root=temp_root,
            )

            serialized = json.dumps(result)
            self.assertFalse(result["success"])
            self.assertEqual(result["error_code"], "invalid_handoff_format")
            self.assertEqual(result["handoff_status"], "invalid_format")
            self.assertNotIn(canary, serialized)
            self.assertNotIn("agent_messages", result)
            self.assertEqual(
                Path(result["artifact"]["raw_path"]).read_text(encoding="utf-8"), canary
            )

    def test_consult_mode_rejects_all_messages(self):
        parsed = parse_codex_lines(self.lines("answer"))

        with self.assertRaises(ValueError):
            build_codex_result(
                parsed,
                prompt="review",
                working_directory="/workspace",
                consult_handoff=True,
                domain="general",
                marker="CONSULT_HANDOFF_TEST",
                return_all_messages=True,
            )

    def test_non_json_noise_lines_are_ignored_not_damage(self):
        parsed = parse_codex_lines(
            ["Reading additional input from stdin..."] + self.lines("answer")
        )

        self.assertFalse(parsed["had_parse_error"])
        self.assertFalse(parsed["public_error_codes"])
        self.assertEqual(parsed["agent_messages"], "answer")
        self.assertNotIn("Reading additional input", json.dumps(parsed["public_error_codes"]))

    def test_blank_lines_do_not_damage_event_stream(self):
        parsed = parse_codex_lines(["", "   "] + self.lines("answer"))

        self.assertFalse(parsed["had_parse_error"])
        self.assertEqual(parsed["agent_messages"], "answer")

    def test_non_object_json_events_are_treated_as_damage(self):
        parsed = parse_codex_lines(["42", "null", "[]"] + self.lines("answer"))

        self.assertEqual(parsed["agent_messages"], "answer")
        self.assertTrue(parsed["had_parse_error"] or parsed["public_error_codes"])

    def test_consult_mode_fails_closed_on_damaged_event_stream(self):
        marker = "CONSULT_HANDOFF_TEST"
        answer = f"analysis\n{marker}\n{json.dumps(self.handoff())}\n{marker}_END"
        damage = json.dumps({"type": "turn.failed", "error": {"message": "boom"}})
        parsed = parse_codex_lines(self.lines(answer) + [damage])
        with tempfile.TemporaryDirectory() as temp_root:
            result = build_codex_result(
                parsed,
                prompt="review",
                working_directory="/workspace",
                consult_handoff=True,
                domain="general",
                marker=marker,
                return_all_messages=False,
                temp_root=temp_root,
            )

        self.assertFalse(result["success"])
        self.assertEqual(result["error_code"], "damaged_event_stream")
        self.assertNotIn("handoff", result)
        self.assertNotIn("not-json-secret", json.dumps(result))

    def test_direct_mode_fails_closed_when_error_precedes_answer(self):
        lines = [
            json.dumps({"type": "thread.started", "thread_id": "thread-123"}),
            json.dumps({"type": "turn.failed", "error": {"message": "boom"}}),
            json.dumps({"type": "item.completed", "item": {"type": "agent_message", "text": "partial"}}),
        ]
        parsed = parse_codex_lines(lines)

        result = build_codex_result(
            parsed,
            prompt="fix",
            working_directory="/workspace",
            consult_handoff=False,
            domain="general",
            marker=None,
            return_all_messages=False,
        )

        self.assertFalse(result["success"])


if __name__ == "__main__":
    unittest.main()
