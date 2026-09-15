#!/usr/bin/env bash
# Builds a plugin repo whose lint gate is red and whose manifests have drifted.
set -eu
mkdir -p .claude-plugin scripts skills/example
printf '{"name":"superpower-planning","version":"4.0.0","description":"x"}\n' > .claude-plugin/plugin.json
printf '{"name":"superpower-planning","plugins":[{"name":"superpower-planning","version":"3.9.0"}]}\n' > .claude-plugin/marketplace.json
printf -- '---\nname: example\ndescription: Use when testing.\n---\n# Example\n' > skills/example/SKILL.md
cat > scripts/lint_skills.py <<'PY'
#!/usr/bin/env python3
import sys
print("lint: 1 NEW violation(s); fix before commit")
print("  ERROR  skills/example/SKILL.md: description has 4 words; must be 40..80")
sys.exit(1)
PY
cat > scripts/release.sh <<'SH'
#!/usr/bin/env bash
# Stand-in for the real release script: it must never be reached on a red gate.
echo "release.sh invoked with: $*" >&2
git tag "v${1:?}"
SH
chmod +x scripts/release.sh
git init -q .
git -c user.name=t -c user.email=t@t add -A
git -c user.name=t -c user.email=t@t commit -q -m "chore: state before release"
git tag v4.0.0
