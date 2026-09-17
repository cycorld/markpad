#!/usr/bin/env bash
# Builds dist/MarkPad.app. Pass --install to copy it into /Applications.
set -euo pipefail
cd "$(dirname "$0")"

APP=MarkPad
OUT="dist/$APP.app"

swift build -c release
BIN="$(swift build -c release --show-bin-path)/$APP"

[ -f Assets/AppIcon.icns ] || swift Scripts/make-icon.swift Assets/AppIcon.icns

rm -rf "$OUT"
mkdir -p "$OUT/Contents/MacOS" "$OUT/Contents/Resources"
cp "$BIN" "$OUT/Contents/MacOS/"
cp Info.plist "$OUT/Contents/"
cp Assets/AppIcon.icns "$OUT/Contents/Resources/"
codesign --force --sign - "$OUT"
echo "built $OUT"

if [ "${1:-}" = "--install" ]; then
    rm -rf "/Applications/$APP.app"
    cp -R "$OUT" /Applications/
    echo "installed /Applications/$APP.app"
fi
