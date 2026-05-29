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
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "Error: must be run from within a git repository" >&2
    exit 1
}
PLUGIN_JSON="${REPO_ROOT}/.claude-plugin/plugin.json"
MARKETPLACE_JSON="${REPO_ROOT}/.claude-plugin/marketplace.json"

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

# Pre-flight guards — run before any file mutation so a failed check leaves no half-done state

# Tag must not already exist (otherwise the bump commit lands but tagging fails mid-run)
if git -C "$REPO_ROOT" rev-parse -q --verify "refs/tags/v${VERSION}" >/dev/null; then
    echo "Error: tag v${VERSION} already exists" >&2
    exit 1
fi

# Must be on the branch we push to (we commit to HEAD but push BASE_BRANCH)
BASE_BRANCH=$("${SCRIPT_DIR}/detect-base-branch.sh" "$REPO_ROOT")
CURRENT_BRANCH=$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "$BASE_BRANCH" ]; then
    echo "Error: on branch '$CURRENT_BRANCH' but release pushes '$BASE_BRANCH'." >&2
    echo "Checkout $BASE_BRANCH (or merge there) before releasing." >&2
    exit 1
fi

# Working tree must be clean — this script commits only the version bump, so any
# other uncommitted change would be silently left out of the tagged release.
if ! git -C "$REPO_ROOT" diff --quiet --ignore-submodules HEAD; then
    echo "Error: working tree has uncommitted changes." >&2
    echo "Commit or stash them first; release.sh only commits the version bump." >&2
    exit 1
fi

echo "Releasing v${VERSION}..."

# 1. Update plugin.json
TMPFILE=$(mktemp)
jq --arg v "$VERSION" '.version = $v' "$PLUGIN_JSON" > "$TMPFILE" && mv "$TMPFILE" "$PLUGIN_JSON"
echo "  Updated plugin.json"

# 2. Update marketplace.json
TMPFILE=$(mktemp)
jq --arg v "$VERSION" '.plugins[0].version = $v' "$MARKETPLACE_JSON" > "$TMPFILE" && mv "$TMPFILE" "$MARKETPLACE_JSON"
echo "  Updated marketplace.json"

# 3. Commit
git -C "$REPO_ROOT" add "$PLUGIN_JSON" "$MARKETPLACE_JSON"
git -C "$REPO_ROOT" commit -m "chore: bump version to ${VERSION}"
echo "  Committed version bump"

# 4. Tag and push
git -C "$REPO_ROOT" tag "v${VERSION}"
git -C "$REPO_ROOT" push origin "$BASE_BRANCH" --tags
echo "  Pushed commit and tag v${VERSION}"

# 5. Create GitHub Release
gh release create "v${VERSION}" --title "v${VERSION}" --notes "$CHANGELOG"
echo "  Created GitHub Release v${VERSION}"

echo ""
echo "Release v${VERSION} complete!"
