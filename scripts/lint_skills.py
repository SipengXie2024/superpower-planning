#!/usr/bin/env python3
"""CI-grade structural linter for superpower-planning SKILL.md files.

Enforces the plugin's house conventions on every ``skills/*/SKILL.md`` and the
markdown beside it under ``references/``, ``templates/`` and ``assets/``:

 - frontmatter ``name`` equals the directory slug
 - ``description`` is 40..80 words, third person, contains a "Use when" clause
 - (em-dash is NOT checked here: that ban is superpower-writing's house style for
   reviewer-facing academic prose, which these engineering docs are not)
 - SKILL.md body LOC: warn above 500, error above 700 (push detail into references)
 - references/ is single level: a references file must not link to another
 - a long references file (over 100 lines) must carry a table of contents

The description parser tolerates YAML block scalars ("|" and ">") so multiline
frontmatter descriptions (polish) are read whole. It is a minimal
stdlib parser; it does NOT depend on pyyaml.

Ratchet model
-------------
The current tree already violates several of these rules (notably two oversize
SKILL.md files and many pre-existing em-dashes). Those known violations are
grandfathered in ``lint_skills_baseline.txt`` so the linter exits 0 on the
current tree, yet exits 1 the moment a NEW violation appears in a new or edited
file. Grandfathered findings are reprinted as TODO lines, not as gating errors.

Each error carries a stable key (``path::check::detail``) that omits line
numbers, so ordinary edits to a grandfathered file do not churn the baseline.

Exit codes
----------
 0  clean, or every error is grandfathered (only warnings remain)
 1  at least one NEW error (not in the baseline)
 2  baseline file is stale: it lists keys no longer produced (run --update-baseline)

Usage
-----
  python3 scripts/lint_skills.py                 # lint against the baseline
  python3 scripts/lint_skills.py --update-baseline   # regenerate the baseline
  python3 scripts/lint_skills.py --no-baseline   # ignore baseline (raw report)
  python3 scripts/lint_skills.py --strict         # treat warnings as errors too
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path

EM_DASH = "—"
# The em-dash ban is superpower-writing's house style for reviewer-facing academic
# prose. This plugin's skills are engineering-workflow docs with no such rule, so
# the check is off here; the structural checks below still apply.
CHECK_EM_DASH = False
# Accepted trigger-clause openers. "Use when" is the canonical form, but a
# description that says "Use on any bug" or "Use after a plan is done" states the
# same thing and should not be failed on wording alone.
TRIGGER_CLAUSE = re.compile(r"\buse (?:when|on|after|before|for|during|if)\b", re.IGNORECASE)

DESC_MIN_WORDS = 40
DESC_MAX_WORDS = 80
BODY_WARN_LINES = 500
BODY_ERROR_LINES = 700
REF_TOC_LINES = 100

FIRST_PERSON = re.compile(r"\b(I|my|mine|we|our|ours|us)\b", re.IGNORECASE)
NAME_RE = re.compile(r"[a-z0-9][a-z0-9\-]{0,62}[a-z0-9]")
# links / pointers from one file into a references file
REF_LINK = re.compile(r"\[[^\]]*\]\((?:\./|\.\./)?references/([A-Za-z0-9_\-./]+\.md)\)")
REF_POINTER = re.compile(r"(?:See|see|Ref|ref):\s+references/([A-Za-z0-9_\-./]+\.md)")
# a bare references/ path used as a markdown link target inside a references file.
# Allows / and ../ so cross-skill and _shared targets are caught too; the old
# pattern excluded any path separator and therefore matched nothing in practice.
REF_BARE = re.compile(r"\]\((?:\./|\.\./)*([A-Za-z0-9_\-/]+\.md)\)")
# An inline-code path counts as a nested reference only when a directive tells the
# model to go read it. A bare cross-mention ("the rules in `foo.md` differ") does
# not create a read chain and is not a violation.
REF_DIRECTIVE = re.compile(
    r"(?:see|read|follow|per|load|详见|见|参考|加载)[^.\n`]{0,40}"
    r"`((?:\.\./)*(?:[A-Za-z0-9_\-]+/)*[A-Za-z0-9_\-]+\.md)`",
    re.IGNORECASE,
)

BASELINE_HEADER = """\
# superpower-planning SKILL.md linter baseline (ratchet)
#
# Grandfathered violations: one stable error key per line.
# Format: <path>::<check>::<detail>
# Regenerate with:  python3 scripts/lint_skills.py --update-baseline
# Do NOT hand-add keys to silence new violations; fix the violation instead.
# Each entry is a TODO: the listed file should eventually be brought into spec
# (split oversize bodies into references/, strip em-dashes, tighten descriptions).
"""


@dataclass(frozen=True)
class Finding:
    path: str
    check: str
    detail: str
    message: str
    severity: str  # "error" | "warn"

    def key(self) -> str:
        return f"{self.path}::{self.check}::{self.detail}"


# --------------------------------------------------------------------------- #
# Tolerant stdlib frontmatter parser
# --------------------------------------------------------------------------- #
def split_frontmatter(text: str) -> tuple[str | None, str]:
    """Return (frontmatter_text, body). frontmatter_text is None if absent.

    Recognizes a leading ``---`` line and the next standalone ``---`` line.
    Tolerates a leading UTF-8 BOM and CRLF line endings.
    """
    if text.startswith("﻿"):
        text = text[1:]
    lines = text.splitlines(keepends=True)
    if not lines or lines[0].strip() != "---":
        return None, text
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            fm = "".join(lines[1:i])
            body = "".join(lines[i + 1 :])
            return fm, body
    return None, text


def extract_description(fm: str) -> str | None:
    """Pull the ``description`` value from frontmatter text.

    Handles three shapes:
      description: one-line scalar
      description: > / >-     (folded block scalar, joined with spaces)
      description: | / |-     (literal block scalar, newlines preserved)
    A block scalar's body is every following line more indented than the key,
    which is exactly what the YAML spec mandates and what polish use.
    """
    lines = fm.splitlines()
    for idx, line in enumerate(lines):
        m = re.match(r"^(\s*)description:\s*(.*?)\s*$", line)
        if not m:
            continue
        key_indent = len(m.group(1))
        inline = m.group(2)
        if inline and inline[0] in "|>":
            block: list[str] = []
            for nxt in lines[idx + 1 :]:
                if nxt.strip() == "":
                    block.append("")
                    continue
                indent = len(nxt) - len(nxt.lstrip())
                if indent <= key_indent:
                    break
                block.append(nxt.strip())
            folded = inline[0] == ">"
            joined = " ".join(b for b in block if b) if folded else "\n".join(block)
            return joined.strip()
        # plain inline scalar; strip surrounding quotes if present
        val = inline.strip()
        if len(val) >= 2 and val[0] == val[-1] and val[0] in "\"'":
            val = val[1:-1]
        return val.strip()
    return None


def extract_name(fm: str) -> str | None:
    for line in fm.splitlines():
        m = re.match(r"^name:\s*(.*?)\s*$", line)
        if m:
            val = m.group(1)
            if len(val) >= 2 and val[0] == val[-1] and val[0] in "\"'":
                val = val[1:-1]
            return val.strip()
    return None


# --------------------------------------------------------------------------- #
# Individual checks (each yields Finding objects)
# --------------------------------------------------------------------------- #
def check_name(path: str, slug: str, fm: str) -> list[Finding]:
    name = extract_name(fm)
    if name is None:
        return [Finding(path, "name", "missing", "frontmatter missing 'name'", "error")]
    out: list[Finding] = []
    if not NAME_RE.fullmatch(name):
        out.append(
            Finding(
                path,
                "name",
                "format",
                f"name {name!r} must be kebab-case, 2..64 chars from [a-z0-9-]",
                "error",
            )
        )
    if name != slug:
        out.append(
            Finding(
                path,
                "name",
                "slug-mismatch",
                f"frontmatter name {name!r} must equal directory slug {slug!r}",
                "error",
            )
        )
    return out


def check_description(path: str, fm: str) -> list[Finding]:
    desc = extract_description(fm)
    if desc is None:
        return [
            Finding(path, "description", "missing", "frontmatter missing 'description'", "error")
        ]
    flat = re.sub(r"\s+", " ", desc).strip()
    words = [w for w in flat.split(" ") if w]
    out: list[Finding] = []
    # An unquoted YAML scalar containing ": " parses as a nested mapping, so the
    # whole frontmatter fails to load in any real parser. The tolerant reader above
    # recovers the text anyway, which is exactly why this needs its own check.
    raw = re.search(r"^description:[ \t]*(.*)$", fm, re.M)
    if raw:
        val = raw.group(1).strip()
        if val and val[0] not in "\"'|>" and ": " in val:
            out.append(
                Finding(
                    path,
                    "description",
                    "yaml-colon",
                    "unquoted description contains ': ', which YAML reads as a nested mapping; quote the value or rewrite",
                    "error",
                )
            )
    if len(words) < DESC_MIN_WORDS:
        out.append(
            Finding(
                path,
                "description",
                "words-low",
                f"description has {len(words)} words; must be {DESC_MIN_WORDS}..{DESC_MAX_WORDS}",
                "error",
            )
        )
    elif len(words) > DESC_MAX_WORDS:
        out.append(
            Finding(
                path,
                "description",
                "words-high",
                f"description has {len(words)} words; must be {DESC_MIN_WORDS}..{DESC_MAX_WORDS}",
                "error",
            )
        )
    # Trigger examples are quoted user utterances (e.g. "review my paper"); the
    # user speaks in first person there. Strip quoted spans before the check so
    # only the skill's own (third-person) prose is scrutinized.
    flat_unquoted = re.sub(r'"[^"]*"', " ", flat)
    if FIRST_PERSON.search(flat_unquoted):
        out.append(
            Finding(
                path,
                "description",
                "person",
                "description uses a first-person pronoun; write it in third person",
                "error",
            )
        )
    if not TRIGGER_CLAUSE.search(flat):
        out.append(
            Finding(
                path,
                "description",
                "use-when",
                "description must contain a 'Use when ...' trigger clause",
                "error",
            )
        )
    if CHECK_EM_DASH and EM_DASH in desc:
        out.append(
            Finding(path, "description", "em-dash", "description contains an em-dash", "error")
        )
    return out


def check_body(path: str, body: str) -> list[Finding]:
    out: list[Finding] = []
    n = len(body.splitlines())
    if n > BODY_ERROR_LINES:
        out.append(
            Finding(
                path,
                "body-loc",
                "over-error",
                f"body is {n} lines; hard ceiling is {BODY_ERROR_LINES} (split into references/)",
                "error",
            )
        )
    elif n > BODY_WARN_LINES:
        out.append(
            Finding(
                path,
                "body-loc",
                "over-warn",
                f"body is {n} lines; ideal is <= {BODY_WARN_LINES} (consider splitting into references/)",
                "warn",
            )
        )
    if CHECK_EM_DASH and EM_DASH in body:
        out.append(
            Finding(
                path,
                "em-dash",
                "body",
                "SKILL.md body contains an em-dash; use a period or comma instead",
                "error",
            )
        )
    return out


def check_pointers(skill_dir: Path, path: str, body: str) -> list[Finding]:
    out: list[Finding] = []
    targets: set[str] = set()
    for m in REF_LINK.finditer(body):
        targets.add(m.group(1))
    for m in REF_POINTER.finditer(body):
        targets.add(m.group(1))
    for target in sorted(targets):
        if not (skill_dir / "references" / target).exists():
            out.append(
                Finding(
                    path,
                    "ref-pointer",
                    f"missing:{target}",
                    f"points to missing reference references/{target}",
                    "error",
                )
            )
    return out


def check_reference_file(ref_path: Path, path: str, skill_md: str = "") -> list[Finding]:
    try:
        text = ref_path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return [Finding(path, "encoding", "utf8", f"{path}: not valid UTF-8", "error")]
    out: list[Finding] = []

    if CHECK_EM_DASH and EM_DASH in text:
        out.append(
            Finding(path, "em-dash", "ref", f"{path}: references file contains an em-dash", "error")
        )

    # single-level references: this file must not link/point into references/
    nested: set[str] = set()
    for m in REF_LINK.finditer(text):
        nested.add(m.group(1))
    for m in REF_POINTER.finditer(text):
        nested.add(m.group(1))
    # bare same-dir .md links also count: references/ is meant to be a flat leaf.
    # SKILL.md is the parent, not a second hop, so pointing back at it is fine.
    here = ref_path.name
    # CONTEXT.md is the repo-root ubiquitous-language file, not a second reference hop.
    exempt = {here.lower(), "readme.md", "skill.md", "context.md"}
    for m in REF_BARE.finditer(text):
        tgt = m.group(1)
        if tgt.lower().rsplit("/", 1)[-1] not in exempt:
            nested.add(tgt)
    for m in REF_DIRECTIVE.finditer(text):
        tgt = m.group(1)
        if tgt.lower().rsplit("/", 1)[-1] not in exempt:
            nested.add(tgt)
    # Reachable in one hop either by name, or because SKILL.md routes the whole
    # directory the target sits in (drafting names section-standards/<slug>.md).
    # Only a NAMED SUBDIRECTORY under references/ counts as routed. Matching on
    # "references/" itself would exempt every file in every skill and silently
    # disable this check.
    parent = ref_path.parent.name
    routed = bool(skill_md) and parent != "references" and f"{parent}/" in skill_md
    nested = {t for t in nested if not routed and t.rsplit("/", 1)[-1] not in skill_md}
    for tgt in sorted(nested):
        out.append(
            Finding(
                path,
                "nested-ref",
                f"link:{tgt}",
                f"{path}: links to another references file ({tgt}); references/ must be single level",
                "error",
            )
        )

    lines = text.splitlines()
    if len(lines) > REF_TOC_LINES:
        head = "\n".join(lines[:25]).lower()
        has_toc = (
            "table of contents" in head
            or "## contents" in head
            or "# contents" in head
            or re.search(r"(?m)^\s*[-*]\s*\[[^\]]+\]\(#", head) is not None
            or "<!-- toc -->" in head
        )
        if not has_toc:
            out.append(
                Finding(
                    path,
                    "ref-toc",
                    "missing",
                    f"{path}: {len(lines)} lines but no table of contents in the first 25 lines",
                    "error",
                )
            )
    return out


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #
def lint_skill(skill_dir: Path, repo_root: Path) -> list[Finding]:
    skill_md = skill_dir / "SKILL.md"
    rel = skill_md.relative_to(repo_root).as_posix()
    dir_rel = skill_dir.relative_to(repo_root).as_posix()
    if not skill_md.exists():
        return [Finding(dir_rel, "skill-md", "missing", f"{dir_rel}: missing SKILL.md", "error")]
    try:
        text = skill_md.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return [Finding(rel, "encoding", "utf8", f"{rel}: not valid UTF-8", "error")]

    fm, body = split_frontmatter(text)
    if fm is None:
        return [Finding(rel, "frontmatter", "missing", f"{rel}: missing or unterminated YAML frontmatter", "error")]

    out: list[Finding] = []
    out += check_name(rel, skill_dir.name, fm)
    out += check_description(rel, fm)
    out += check_body(rel, body)
    out += check_pointers(skill_dir, rel, body)

    # templates/ and assets/ beside a skill are loaded at run time just like
    # references/, so they are held to the same structural rules.
    for sub in ("references", "templates", "assets"):
        ref_dir = skill_dir / sub
        if not ref_dir.is_dir():
            continue
        for ref_md in sorted(ref_dir.rglob("*.md")):
            out += check_reference_file(ref_md, ref_md.relative_to(repo_root).as_posix(), body)
    return out


def collect_findings(repo_root: Path) -> list[Finding]:
    skills_root = repo_root / "skills"
    if not skills_root.is_dir():
        return []
    findings: list[Finding] = []
    for skill_dir in sorted(p for p in skills_root.iterdir() if p.is_dir()):
        if skill_dir.name.startswith((".", "_")):
            continue  # shared-asset dirs (e.g. _shared/) hold no SKILL.md
        if not (skill_dir / "SKILL.md").exists() and not any(skill_dir.iterdir()):
            continue  # empty placeholder dir
        findings += lint_skill(skill_dir, repo_root)
    # Markdown outside a skill's own references/ is still loaded by skills at run
    # time (skills/_shared/core/house-style.md alone is read by five of them), so
    # it is held to the same em-dash and table-of-contents rules.
    for extra_root in (skills_root / "_shared", repo_root / "templates"):
        if not extra_root.is_dir():
            continue
        for md in sorted(extra_root.rglob("*.md")):
            findings += check_reference_file(md, md.relative_to(repo_root).as_posix())
    return findings


def git_tracked_skill_files(repo_root: Path) -> set[str] | None:
    """Return repo-relative posix paths of git-tracked files under skills/.

    Returns None if git is unavailable, so callers can fall back to "all files".
    Used ONLY when generating the baseline: the ratchet grandfathers the
    committed legacy tree and holds new (untracked) units to full spec.
    """
    import subprocess

    try:
        out = subprocess.run(
            ["git", "-C", str(repo_root), "ls-files", "skills/"],
            capture_output=True,
            text=True,
            check=True,
        )
    except (OSError, subprocess.CalledProcessError):
        return None
    return {line.strip() for line in out.stdout.splitlines() if line.strip()}


def read_baseline(path: Path) -> set[str]:
    if not path.exists():
        return set()
    keys: set[str] = set()
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            keys.add(line)
    return keys


def write_baseline(path: Path, keys: list[str]) -> None:
    body = BASELINE_HEADER + "\n" + "\n".join(sorted(keys)) + ("\n" if keys else "")
    path.write_text(body, encoding="utf-8")


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Lint superpower-planning SKILL.md files.")
    ap.add_argument("--update-baseline", action="store_true", help="regenerate the ratchet baseline (git-tracked files only by default)")
    ap.add_argument("--all", action="store_true", help="with --update-baseline: grandfather EVERY current error, including untracked files")
    ap.add_argument("--no-baseline", action="store_true", help="ignore the baseline; report every finding")
    ap.add_argument("--strict", action="store_true", help="treat warnings as gating errors too")
    args = ap.parse_args(argv)

    repo_root = Path(__file__).resolve().parent.parent
    baseline_path = repo_root / "scripts" / "lint_skills_baseline.txt"

    findings = collect_findings(repo_root)
    errors = [f for f in findings if f.severity == "error"]
    warns = [f for f in findings if f.severity == "warn"]

    if args.update_baseline:
        grandfatherable = errors
        excluded: list[Finding] = []
        if not args.all:
            tracked = git_tracked_skill_files(repo_root)
            if tracked is None:
                print("lint: git unavailable; cannot scope baseline to tracked files. Use --all to grandfather the whole tree.")
                return 2
            grandfatherable = [f for f in errors if f.path in tracked]
            excluded = [f for f in errors if f.path not in tracked]
        keys = sorted({f.key() for f in grandfatherable})
        write_baseline(baseline_path, keys)
        print(f"lint: wrote {len(keys)} grandfathered error key(s) to {baseline_path.relative_to(repo_root)}")
        for f in sorted(grandfatherable, key=lambda x: x.key()):
            print(f"  grandfathered: {f.message}")
        if excluded:
            print(f"lint: {len(excluded)} error(s) in untracked/new files were NOT grandfathered (they must be fixed to spec):")
            for f in sorted(excluded, key=lambda x: x.key()):
                print(f"  NOT-GRANDFATHERED  {f.message}")
        return 0

    baseline = set() if args.no_baseline else read_baseline(baseline_path)

    grandfathered = [f for f in errors if f.key() in baseline]
    new_errors = [f for f in errors if f.key() not in baseline]
    if args.strict:
        new_errors += warns
        warns = []

    # report. Checks against a SKILL.md body build their message without the path,
    # which makes several identical lines indistinguishable across skills, so the
    # path is prepended whenever the message does not already start with it.
    def labelled(f: Finding) -> str:
        return f.message if f.message.startswith(f.path) else f"{f.path}: {f.message}"

    if new_errors:
        print(f"lint: {len(new_errors)} NEW violation(s); fix before commit")
        for f in sorted(new_errors, key=lambda x: x.key()):
            print(f"  ERROR  {labelled(f)}")
    if warns:
        print(f"lint: {len(warns)} warning(s)")
        for f in sorted(warns, key=lambda x: x.key()):
            print(f"  WARN   {labelled(f)}")
    if grandfathered:
        print(f"lint: {len(grandfathered)} grandfathered violation(s) (TODO: bring into spec; tracked in {baseline_path.name})")
        for f in sorted(grandfathered, key=lambda x: x.key()):
            print(f"  TODO   {labelled(f)}")

    # stale-baseline detection: keys that no longer match any current error
    if not args.no_baseline:
        live = {f.key() for f in errors}
        stale = sorted(baseline - live)
        if stale:
            print(f"lint: {len(stale)} stale baseline key(s); these no longer fire, run --update-baseline to prune")
            for k in stale:
                print(f"  STALE  {k}")
            if not new_errors:
                return 2

    if new_errors:
        return 1

    total_skills = len(list((repo_root / "skills").glob("*/SKILL.md")))
    print(f"lint: clean: {total_skills} skill(s) checked, {len(grandfathered)} grandfathered, {len(warns)} warning(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
