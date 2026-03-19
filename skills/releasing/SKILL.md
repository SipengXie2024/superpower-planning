---
name: releasing
description: Use when publishing a new version — bumping version numbers, creating git tags, and publishing GitHub Releases with changelogs.
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

### 3. Execute release

Once version and changelog are determined, run the release script:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/release.sh "<version>" "<changelog>"
```

This handles all mechanical steps: update both JSONs → commit → tag → push → create GitHub Release.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| marketplace.json version not updated | Always update both JSON files together |
| Tag created before commit pushed | Push commit first, then tag, or use `--tags` |
| Changelog missing commits | Use `prev_tag..HEAD`, not `prev_tag..new_tag` before tagging |
