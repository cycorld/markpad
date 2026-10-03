#!/usr/bin/env bash
# MarkPad one-line installer for macOS
# Usage: curl -fsSL https://raw.githubusercontent.com/cycorld/markpad/main/install.sh | bash
set -euo pipefail

REPO="cycorld/markpad"
APP_NAME="MarkPad"
INSTALL_DIR="/Applications"
TARGET_APP="$INSTALL_DIR/$APP_NAME.app"

# Ensure running on macOS
if [ "$(uname -s)" != "Darwin" ]; then
    echo "❌ Error: MarkPad is a native macOS application and requires macOS 14.0 or later." >&2
    exit 1
fi

echo "🔍 Finding latest MarkPad release..."
LATEST_JSON=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
TAG=$(echo "$LATEST_JSON" | grep -m1 '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')

if [ -z "$TAG" ]; then
    echo "❌ Error: Could not determine latest release tag." >&2
    exit 1
fi

ZIP_NAME="${APP_NAME}-${TAG}.zip"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$TAG/$ZIP_NAME"
CHECKSUM_URL="https://github.com/$REPO/releases/download/$TAG/SHA256SUMS.txt"

TMP_DIR=$(mktemp -d -t markpad-install-XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "⬇️  Downloading MarkPad $TAG..."
curl -fL --progress-bar "$DOWNLOAD_URL" -o "$TMP_DIR/$ZIP_NAME"

echo "🔐 Verifying checksum..."
if curl -fsSL "$CHECKSUM_URL" -o "$TMP_DIR/SHA256SUMS.txt" 2>/dev/null; then
    EXPECTED_SHA=$(grep "$ZIP_NAME" "$TMP_DIR/SHA256SUMS.txt" | awk '{print $1}')
    if [ -n "$EXPECTED_SHA" ]; then
        ACTUAL_SHA=$(shasum -a 256 "$TMP_DIR/$ZIP_NAME" | awk '{print $1}')
        if [ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]; then
            echo "❌ Error: Checksum verification failed!" >&2
            echo "Expected: $EXPECTED_SHA" >&2
            echo "Actual:   $ACTUAL_SHA" >&2
            exit 1
        fi
        echo "✅ Checksum verified: $ACTUAL_SHA"
    fi
fi

echo "📦 Extracting $APP_NAME.app..."
unzip -q -o "$TMP_DIR/$ZIP_NAME" -d "$TMP_DIR"

if [ ! -d "$TMP_DIR/$APP_NAME.app" ]; then
    echo "❌ Error: Extracted archive does not contain $APP_NAME.app" >&2
    exit 1
fi

# Strip quarantine attributes recursively
xattr -cr "$TMP_DIR/$APP_NAME.app" 2>/dev/null || true

echo "🚀 Installing to $TARGET_APP..."
if [ -d "$TARGET_APP" ]; then
    rm -rf "$TARGET_APP"
fi
mv "$TMP_DIR/$APP_NAME.app" "$TARGET_APP"

# Final quarantine clearance on installed app
xattr -cr "$TARGET_APP" 2>/dev/null || true

echo "🎉 MarkPad $TAG installed successfully in $TARGET_APP!"
echo ""
echo "Run it from Spotlight or Launchpad, or execute:"
echo "    open /Applications/MarkPad.app"
