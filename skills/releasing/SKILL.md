---
name: releasing
description: Use when publishing a new version of the plugin.
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

## Steps

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
