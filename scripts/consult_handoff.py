from __future__ import annotations

import hashlib
import json
import os
import stat
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Optional


class HandoffValidationError(ValueError):
    pass


_TOP_LEVEL_FIELDS = {
    "schema_version",
    "status",
    "summary",
    "findings",
    "evidence",
    "uncertainties",
    "verification_needed",
}
_FINDING_FIELDS = {"claim", "confidence", "evidence_ids"}
_EVIDENCE_FIELDS = {"id", "source", "locator"}
_STATUS_VALUES = {"complete", "partial", "blocked"}
_CONFIDENCE_VALUES = {"high", "medium", "low"}


def build_handoff_instruction(domain: str, marker: str) -> str:
    schema = {
        "schema_version": 1,
        "status": "complete",
        "summary": "Decision-oriented conclusion with only necessary detail.",
        "findings": [
            {
                "claim": "One independently verifiable claim.",
                "confidence": "high",
                "evidence_ids": ["E1"],
            }
        ],
        "evidence": [
            {"id": "E1", "source": "source name", "locator": "URL, DOI, or file:line"}
        ],
        "uncertainties": [],
        "verification_needed": [],
    }
    return (
        "\n\nReturn your normal, complete analysis first. Then finish with a compact "
        f"structured handoff for the {domain} consultation. Put the marker `{marker}` on its "
        "own line, followed by exactly one JSON object using this shape:\n"
        f"{json.dumps(schema, ensure_ascii=False, indent=2)}\n"
        f"Put `{marker}_END` on its own line immediately after the JSON. "
        "Keep the summary under 1200 characters. Use at most 8 findings, 12 evidence items, "
        "6 uncertainties, and 6 verification items. Evidence locators must point to original "
        "sources or real code, not to this response. Do not include commands, payloads, "
        "procedures, or parameters. Do not encode, obscure, rename, or omit relevant terms to "
        "influence a safety system. If a detail cannot be included in this compact handoff, "
        "record only the conclusion, uncertainty, and a locator to the original source."
    )


def extract_handoff(raw_text: str, marker: str) -> dict[str, Any]:
    start_token = f"\n{marker}\n"
    end_token = f"\n{marker}_END"
    start = raw_text.rfind(start_token)
    if start < 0:
        raise HandoffValidationError("missing handoff marker")
    json_start = start + len(start_token)
    end = raw_text.find(end_token, json_start)
    if end < 0 or raw_text[end + len(end_token) :].strip():
        raise HandoffValidationError("missing or non-final handoff end marker")
    try:
        data = json.loads(raw_text[json_start:end])
    except json.JSONDecodeError as exc:
        raise HandoffValidationError("invalid handoff JSON") from exc
    validate_handoff(data)
    return data


def validate_handoff(data: Any) -> None:
    if not isinstance(data, dict) or set(data) != _TOP_LEVEL_FIELDS:
        raise HandoffValidationError("invalid handoff fields")
    if data["schema_version"] != 1:
        raise HandoffValidationError("unsupported handoff schema")
    _require_enum(data["status"], "status", _STATUS_VALUES)
    _require_string(data["summary"], "summary", 1200)
    _require_list(data["findings"], "findings", 8)
    _require_list(data["evidence"], "evidence", 12)
    _require_string_list(data["uncertainties"], "uncertainties", 6, 600)
    _require_string_list(data["verification_needed"], "verification_needed", 6, 600)

    evidence_ids = set()
    for item in data["evidence"]:
        if not isinstance(item, dict) or set(item) != _EVIDENCE_FIELDS:
            raise HandoffValidationError("invalid evidence fields")
        evidence_id = _require_string(item["id"], "evidence id", 64)
        _require_string(item["source"], "evidence source", 500)
        _require_string(item["locator"], "evidence locator", 1000)
        if evidence_id in evidence_ids:
            raise HandoffValidationError("duplicate evidence id")
        evidence_ids.add(evidence_id)

    for item in data["findings"]:
        if not isinstance(item, dict) or set(item) != _FINDING_FIELDS:
            raise HandoffValidationError("invalid finding fields")
        _require_string(item["claim"], "finding claim", 1000)
        _require_enum(item["confidence"], "confidence", _CONFIDENCE_VALUES)
        ids = _require_string_list(item["evidence_ids"], "evidence_ids", 12, 64)
        if not set(ids).issubset(evidence_ids):
            raise HandoffValidationError("unknown evidence id")


def persist_artifacts(
    *,
    provider: str,
    domain: str,
    prompt: str,
    raw_response: str,
    working_directory: str,
    external_exit_code: Optional[int],
    session_id: Optional[str],
    parse_status: str,
    temp_root: Optional[str] = None,
) -> dict[str, Any]:
    run_dir = Path(tempfile.mkdtemp(prefix="superpower-planning-handoff-", dir=temp_root))
    if os.name == "posix":
        os.chmod(run_dir, 0o700)
        if stat.S_IMODE(run_dir.stat().st_mode) != 0o700:
            raise PermissionError("could not secure handoff directory")

    raw_bytes = raw_response.encode("utf-8")
    raw_path = run_dir / "raw-response.txt"
    metadata_path = run_dir / "metadata.json"
    _secure_write(raw_path, raw_bytes)

    metadata = {
        "schema_version": 1,
        "provider": provider,
        "domain": domain,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "working_directory": working_directory,
        "external_exit_code": external_exit_code,
        "session_id": session_id,
        "prompt_sha256": hashlib.sha256(prompt.encode("utf-8")).hexdigest(),
        "raw_sha256": hashlib.sha256(raw_bytes).hexdigest(),
        "raw_bytes": len(raw_bytes),
        "handoff_parse_status": parse_status,
    }
    _secure_write(
        metadata_path,
        json.dumps(metadata, ensure_ascii=False, indent=2).encode("utf-8"),
    )
    return {
        "raw_path": str(raw_path),
        "metadata_path": str(metadata_path),
        "sha256": metadata["raw_sha256"],
        "bytes": metadata["raw_bytes"],
    }


def fallback_guidance(domain: str) -> str:
    guidance = (
        "If Fable declines this handoff, keep the artifact and use Claude Opus 4.8. "
        "Do not rephrase, encode, split, or repeatedly retry the request to avoid safeguards."
    )
    if domain == "cyber":
        guidance += (
            " Legitimate defensive users can also apply to Anthropic's Cyber Verification "
            "Program: https://support.claude.com/en/articles/14604842-real-time-cyber-safeguards-on-claude-opus-and-sonnet"
        )
    return guidance


def _secure_write(path: Path, content: bytes) -> None:
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    fd = os.open(path, flags, 0o600)
    try:
        with os.fdopen(fd, "wb") as handle:
            handle.write(content)
    except Exception:
        try:
            os.close(fd)
        except OSError:
            pass
        raise
    if os.name == "posix":
        os.chmod(path, 0o600)
        if stat.S_IMODE(path.stat().st_mode) != 0o600:
            raise PermissionError("could not secure handoff file")


def _require_enum(value: Any, name: str, allowed: set[str]) -> str:
    if not isinstance(value, str) or value not in allowed:
        raise HandoffValidationError(f"invalid {name}")
    return value


def _require_string(value: Any, name: str, max_length: int) -> str:
    if not isinstance(value, str) or not value or len(value) > max_length:
        raise HandoffValidationError(f"invalid {name}")
    return value


def _require_list(value: Any, name: str, max_items: int) -> list[Any]:
    if not isinstance(value, list) or len(value) > max_items:
        raise HandoffValidationError(f"invalid {name}")
    return value


def _require_string_list(
    value: Any, name: str, max_items: int, max_length: int
) -> list[str]:
    items = _require_list(value, name, max_items)
    for item in items:
        _require_string(item, name, max_length)
    return items
