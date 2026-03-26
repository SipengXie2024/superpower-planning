#!/usr/bin/env bash
# Release a new version: update JSONs, commit, tag, push, create GitHub Release
#
# Usage: release.sh <version> <changelog>
#   version  — semver string WITHOUT 'v' prefix (e.g., "1.11.0")
#   changelog — release notes content (multiline string)
#
# Requires: jq, gh (GitHub CLI)
#
# Steps:
#   1. Update version in plugin.json and marketplace.json
#   2. Commit with "chore: bump version to X.Y.Z"
#   3. Create git tag vX.Y.Z
#   4. Push commit and tag
#   5. Create GitHub Release with provided changelog

set -euo pipefail

VERSION="${1:?Usage: release.sh <version> <changelog>}"
CHANGELOG="${2:?Usage: release.sh <version> <changelog>}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PLUGIN_JSON="${PLUGIN_ROOT}/.claude-plugin/plugin.json"
MARKETPLACE_JSON="${PLUGIN_ROOT}/.claude-plugin/marketplace.json"

# Validate version format
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "Error: version must be semver (e.g., 1.11.0), got: $VERSION" >&2
    exit 1
fi

# Check required tools
for cmd in jq gh git; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is required but not found in PATH" >&2
        exit 1
    fi
done

echo "Releasing v${VERSION}..."

# Detect base branch
BASE_BRANCH=$("${SCRIPT_DIR}/detect-base-branch.sh" "$PLUGIN_ROOT")

# 1. Update plugin.json
TMPFILE=$(mktemp)
jq --arg v "$VERSION" '.version = $v' "$PLUGIN_JSON" > "$TMPFILE" && mv "$TMPFILE" "$PLUGIN_JSON"
echo "  Updated plugin.json"

# 2. Update marketplace.json
TMPFILE=$(mktemp)
jq --arg v "$VERSION" '.plugins[0].version = $v' "$MARKETPLACE_JSON" > "$TMPFILE" && mv "$TMPFILE" "$MARKETPLACE_JSON"
echo "  Updated marketplace.json"

# 3. Commit
git -C "$PLUGIN_ROOT" add "$PLUGIN_JSON" "$MARKETPLACE_JSON"
git -C "$PLUGIN_ROOT" commit -m "chore: bump version to ${VERSION}"
echo "  Committed version bump"

# 4. Tag and push
git -C "$PLUGIN_ROOT" tag "v${VERSION}"
git -C "$PLUGIN_ROOT" push origin "$BASE_BRANCH" --tags
echo "  Pushed commit and tag v${VERSION}"

# 5. Create GitHub Release
gh release create "v${VERSION}" --title "v${VERSION}" --notes "$CHANGELOG"
echo "  Created GitHub Release v${VERSION}"

echo ""
echo "Release v${VERSION} complete!"
