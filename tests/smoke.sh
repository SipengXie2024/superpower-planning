#!/usr/bin/env bash
# End-to-end smoke test for superpower-planning.
# Exercises: dir init against the shipped templates, the three unique-filename
# call shapes, catchup's exit reporting, manifest and component presence, linter.
#
# Section 2 asserts the generated file matches its template byte for byte, which
# catches the script emitting anything other than the template: an earlier
# init-planning-dir.sh carried an inline heredoc fallback that had drifted to four
# columns while the template had seven, and nothing caught it. Note the limit,
# since the wording invites more credit than it earns: both sides of that diff
# come from the same template, so editing the template alone can never fail this.
# It guards the script, not the template's contents.
# Section 3 asserts the script now fails loudly when a template is absent, which
# is what replaced that fallback.

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"
TEMPLATES="$PLUGIN_ROOT/skills/planning-foundation/templates"
cd "$WORK"

pass() { echo "  PASS: $1"; }
fail() { echo "  FAIL: $1" >&2; exit 1; }

echo "== 1. init-planning-dir =="
bash "$PLUGIN_ROOT/scripts/init-planning-dir.sh" >/dev/null
[[ -f .planning/progress.md ]] && pass "progress.md" || fail "progress.md missing"
[[ -f .planning/findings.md ]] && pass "findings.md" || fail "findings.md missing"

echo "== 2. init emits the templates, not a copy of its own =="
DATE="$(date +%Y-%m-%d)"
for f in progress findings; do
  if diff -q <(sed "s|\[DATE\]|$DATE|g" "$TEMPLATES/$f.md") ".planning/$f.md" >/dev/null; then
    pass "$f.md matches templates/$f.md"
  else
    fail "$f.md was not produced from templates/$f.md"
  fi
done

echo "== 3. init fails loudly when a template is absent =="
FAKE="$(mktemp -d)"
cp -r "$PLUGIN_ROOT/scripts" "$FAKE/scripts"
mkdir -p "$FAKE/skills/planning-foundation/templates"
cp "$TEMPLATES/findings.md" "$FAKE/skills/planning-foundation/templates/"
mkdir -p "$WORK/probe"
# set +e around the probe: the whole point is that this call fails, and under
# set -e a non-zero subshell would abort the test before the assertion runs.
set +e
(cd "$WORK/probe" && bash "$FAKE/scripts/init-planning-dir.sh" >/dev/null 2>"$WORK/probe.err")
PROBE_RC=$?
set -e
rm -rf "$FAKE"
if [[ $PROBE_RC -ne 0 ]] && grep -q "template not found" "$WORK/probe.err"; then
  pass "missing template exits $PROBE_RC and names the path"
else
  fail "missing template should exit non-zero with 'template not found' (rc=$PROBE_RC)"
fi

echo "== 4. unique-filename.sh call shapes =="
U="$PLUGIN_ROOT/scripts/unique-filename.sh"
# Callers pass "" to get a directory name. A ${3:-.md} default would substitute
# .md for that empty string too, which created every archive dir as <date>-<x>.md.
[[ "$(bash "$U" . probe "")"     == "./$DATE-probe"     ]] && pass 'empty ext gives no extension'  || fail 'empty ext should give no extension'
[[ "$(bash "$U" . probe)"        == "./$DATE-probe.md"  ]] && pass 'omitted ext defaults to .md'   || fail 'omitted ext should default to .md'
[[ "$(bash "$U" . probe .txt)"   == "./$DATE-probe.txt" ]] && pass 'explicit ext honoured'         || fail 'explicit ext should be honoured'

echo "== 5. session-catchup.py reports why it exits =="
OUT="$(cd "$WORK" && python3 "$PLUGIN_ROOT/scripts/session-catchup.py" 2>&1 || true)"
# This runs as step 1 of /catchup, where a silent exit 0 is indistinguishable
# from a broken script.
[[ -n "$OUT" ]] && pass "prints a reason instead of exiting silently" || fail "exited with no output"
grep -q "superpower-planning" <<<"$OUT" && pass "reason is attributed to the plugin" || fail "output does not name the plugin"

echo "== 6. plugin manifest sanity =="
python3 -c "import json; json.load(open('$PLUGIN_ROOT/.claude-plugin/plugin.json'))"      && pass "plugin.json valid"
python3 -c "import json; json.load(open('$PLUGIN_ROOT/.claude-plugin/marketplace.json'))" && pass "marketplace.json valid"

echo "== 7. skill + command presence =="
for name in archiving brainstorming debugging domain-glossary perf-optimization \
            planning-foundation releasing spec-interview stashing tdd wait-what; do
  [[ -f "$PLUGIN_ROOT/skills/$name/SKILL.md" ]] && pass "skills/$name/SKILL.md" || fail "missing skills/$name/SKILL.md"
done
for cmd in archive brainstorm catchup resume-stash stash; do
  [[ -f "$PLUGIN_ROOT/commands/$cmd.md" ]] && pass "commands/$cmd.md" || fail "missing commands/$cmd.md"
done

echo "== 8. every SKILL.md frontmatter parses as YAML =="
python3 - "$PLUGIN_ROOT" <<'PY'
import pathlib, re, sys, yaml
root = pathlib.Path(sys.argv[1])
for f in sorted((root / "skills").glob("*/SKILL.md")):
    m = re.match(r"^---\n(.*?)\n---\n", f.read_text(encoding="utf-8"), re.S)
    if not m:
        sys.exit(f"  FAIL: {f} has no frontmatter")
    try:
        fm = yaml.safe_load(m.group(1))
    except Exception as e:
        sys.exit(f"  FAIL: {f} frontmatter is not valid YAML: {e}")
    if not fm.get("description"):
        sys.exit(f"  FAIL: {f} has no description")
    print(f"  PASS: {f.parent.name} frontmatter")
PY

echo "== 9. skill linter (ratchet) =="
python3 "$PLUGIN_ROOT/scripts/lint_skills.py" && pass "lint_skills.py clean (no new violations)" \
  || fail "lint_skills.py reported new violations"

echo
echo "ALL SMOKE TESTS PASSED"
