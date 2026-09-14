---
name: releasing
description: Bumps the version in .claude-plugin/plugin.json and .claude-plugin/marketplace.json, creates the git tag, and publishes a GitHub Release with a generated changelog. Use when cutting a release of a Claude Code plugin from its own repository, including "发版", "发布新版本", "打个 tag". Not for releasing library or application code such as cargo publish, npm publish, or PyPI.
---

# Releasing a New Version

## Overview

Bump versions, tag, and publish a GitHub Release with an auto-generated changelog. All version sources must stay in sync.

## Version Sources (must match)

| File | Field |
|------|-------|
| `.claude-plugin/plugin.json` | `version` |
| `.claude-plugin/marketplace.json` | `plugins[0].version` |
| Git tag | `vX.Y.Z` |

## Tool check (once, before Step 0)

Every step here runs through Bash: `python3` for the lint gate, `git` for history and tags, `gh`
(authenticated) and `jq` for the release script. Check that once, up front. If Bash is unavailable or
`git`/`gh` is missing or unauthenticated, say in one sentence that this release cannot be cut in this
session and that the user must run `scripts/release.sh "<version>" "<changelog>"` themselves, then
stop. Do not hand-edit the version fields, do not offer a changelog or draft release notes as a
stand-in for the published Release, and do not run part of the sequence and leave a commit untagged
or a tag unpushed. One sentence naming what is missing is the entire budget: never attempt a tool,
fail, attempt another, and narrate each failure.

## Steps

### 0. Pre-release gate

```bash
python3 scripts/lint_skills.py
```

A ratchet linter over every `skills/*/SKILL.md` and the `references/*.md` beside it. It checks the
frontmatter `name`, the description word count and trigger clause, body length, reference-file depth,
and tables of contents on long reference files. Prior violations are grandfathered in
`scripts/lint_skills_baseline.txt`, so it exits 0 on the baselined tree and exits 1 the moment a NEW
violation appears in a new or edited file. Do not silence a new error by regenerating the baseline;
fix the file. `--update-baseline` grandfathers git-tracked files only, so stage new files first or
they stay flagged.

### 1. Determine version bump

Check commits since last tag:
```bash
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

Apply semver: **patch** for fixes, **minor** for features, **major** for breaking changes.

### 2. Generate changelog

Group commits by type when there are enough to justify it:
- **Features** (`feat:`)
- **Fixes** (`fix:`)
- **Refactors** (`refactor:`)
- **Other** (everything else)

For small releases (< 5 commits), a flat list is fine.

### 3. Confirm before publishing

The script pushes to origin and creates a **public** GitHub Release — irreversible. First show the user the final version number and the full changelog text, and get explicit approval before running it. Do not invoke the script autonomously.

### 4. Execute release

After approval, run the release script:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/release.sh "<version>" "<changelog>"
```

This handles all mechanical steps: update both JSONs → commit → tag → push → create GitHub Release.

## Recovery

| Condition | Handling |
|-----------|----------|
| `git describe` fails (no prior tag) | First release — pick an initial version (e.g. `0.1.0`); changelog from full `git log --oneline` |
| `gh` not authenticated | Stop; ask the user to run `gh auth login` before retrying |
| Script fails mid-run | Inspect what completed (`git tag`, `gh release list`); finish remaining steps manually, don't re-run the whole script |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| marketplace.json version not updated | Always update both JSON files together |
| Tag created before commit pushed | Push commit first, then tag, or use `--tags` |
| Changelog missing commits | Use `prev_tag..HEAD`, not `prev_tag..new_tag` before tagging |
