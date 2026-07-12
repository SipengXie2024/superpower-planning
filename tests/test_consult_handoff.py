import json
import os
import stat
import tempfile
import unittest
from pathlib import Path

from scripts.consult_handoff import (
    HandoffValidationError,
    build_handoff_instruction,
    extract_handoff,
    fallback_guidance,
    persist_artifacts,
)


class ConsultHandoffTest(unittest.TestCase):
    def valid_handoff(self):
        return {
            "schema_version": 1,
            "status": "complete",
            "summary": "The evidence supports the stated conclusion.",
            "findings": [
                {
                    "claim": "The implementation preserves the required boundary.",
                    "confidence": "high",
                    "evidence_ids": ["E1"],
                }
            ],
            "evidence": [
                {
                    "id": "E1",
                    "source": "src/example.py",
                    "locator": "src/example.py:10",
                }
            ],
            "uncertainties": [],
            "verification_needed": ["Run the focused unit test."],
        }

    def response(self, marker, handoff=None, prefix="private-canary-7f41"):
        payload = handoff if handoff is not None else self.valid_handoff()
        return f"{prefix}\n{marker}\n{json.dumps(payload)}\n{marker}_END"

    def test_extracts_valid_marked_handoff(self):
        marker = "CONSULT_HANDOFF_TEST"

        result = extract_handoff(self.response(marker), marker)

        self.assertEqual(result, self.valid_handoff())

    def test_instruction_names_marker_and_forbids_operational_fields(self):
        marker = "CONSULT_HANDOFF_TEST"

        instruction = build_handoff_instruction("cyber", marker)

        self.assertIn(marker, instruction)
        self.assertIn('"schema_version": 1', instruction)
        self.assertIn("Do not include commands, payloads, procedures, or parameters", instruction)
        self.assertIn("cyber", instruction)

    def test_rejects_missing_marker(self):
        with self.assertRaises(HandoffValidationError):
            extract_handoff(json.dumps(self.valid_handoff()), "CONSULT_HANDOFF_TEST")

    def test_rejects_unknown_top_level_field(self):
        handoff = self.valid_handoff()
        handoff["commands"] = ["not allowed"]

        with self.assertRaises(HandoffValidationError):
            extract_handoff(self.response("CONSULT_HANDOFF_TEST", handoff), "CONSULT_HANDOFF_TEST")

    def test_rejects_invalid_confidence(self):
        handoff = self.valid_handoff()
        handoff["findings"][0]["confidence"] = "certain"

        with self.assertRaises(HandoffValidationError):
            extract_handoff(self.response("CONSULT_HANDOFF_TEST", handoff), "CONSULT_HANDOFF_TEST")

    def test_rejects_wrong_typed_enum_field(self):
        handoff = self.valid_handoff()
        handoff["status"] = ["complete"]

        with self.assertRaises(HandoffValidationError):
            extract_handoff(self.response("CONSULT_HANDOFF_TEST", handoff), "CONSULT_HANDOFF_TEST")

    def test_accepts_finding_without_evidence(self):
        handoff = self.valid_handoff()
        handoff["findings"][0]["evidence_ids"] = []

        result = extract_handoff(self.response("CONSULT_HANDOFF_TEST", handoff), "CONSULT_HANDOFF_TEST")

        self.assertEqual(result["findings"][0]["evidence_ids"], [])

    def test_rejects_oversized_summary(self):
        handoff = self.valid_handoff()
        handoff["summary"] = "x" * 1201

        with self.assertRaises(HandoffValidationError):
            extract_handoff(self.response("CONSULT_HANDOFF_TEST", handoff), "CONSULT_HANDOFF_TEST")

    def test_rejects_excess_findings(self):
        handoff = self.valid_handoff()
        handoff["findings"] = handoff["findings"] * 9

        with self.assertRaises(HandoffValidationError):
            extract_handoff(self.response("CONSULT_HANDOFF_TEST", handoff), "CONSULT_HANDOFF_TEST")

    def test_persists_exact_raw_response_with_private_permissions(self):
        raw = "private-canary-7f41\ncomplete response"
        with tempfile.TemporaryDirectory() as temp_root:
            artifact = persist_artifacts(
                provider="hermes",
                domain="bio",
                prompt="summarize the paper",
                raw_response=raw,
                working_directory="/workspace",
                external_exit_code=0,
                session_id=None,
                parse_status="valid",
                temp_root=temp_root,
            )

            raw_path = Path(artifact["raw_path"])
            metadata_path = Path(artifact["metadata_path"])
            self.assertEqual(raw_path.read_text(encoding="utf-8"), raw)
            self.assertEqual(artifact["bytes"], len(raw.encode("utf-8")))
            self.assertEqual(len(artifact["sha256"]), 64)
            if os.name == "posix":
                self.assertEqual(stat.S_IMODE(raw_path.parent.stat().st_mode), 0o700)
                self.assertEqual(stat.S_IMODE(raw_path.stat().st_mode), 0o600)
                self.assertEqual(stat.S_IMODE(metadata_path.stat().st_mode), 0o600)

            metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
            self.assertEqual(metadata["provider"], "hermes")
            self.assertEqual(metadata["domain"], "bio")
            self.assertEqual(metadata["raw_sha256"], artifact["sha256"])
            self.assertNotIn(raw, json.dumps(artifact))
            self.assertNotIn("summarize the paper", metadata_path.read_text(encoding="utf-8"))

    def test_fallback_guidance_adds_cvp_only_for_cyber(self):
        cyber = fallback_guidance("cyber")
        bio = fallback_guidance("bio")

        self.assertIn("Opus 4.8", cyber)
        self.assertIn("Cyber Verification Program", cyber)
        self.assertIn("Opus 4.8", bio)
        self.assertNotIn("Cyber Verification Program", bio)
        self.assertIn("do not rephrase", cyber.lower())


if __name__ == "__main__":
    unittest.main()
