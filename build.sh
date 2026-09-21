#!/usr/bin/env bash
# Builds dist/MarkPad.app as a universal (arm64 + x86_64) binary. Pass --install to copy it into /Applications.
set -euo pipefail
cd "$(dirname "$0")"

APP=MarkPad
OUT="dist/$APP.app"
ARCHS=(--arch arm64 --arch x86_64)

swift build -c release "${ARCHS[@]}"
BIN="$(swift build -c release "${ARCHS[@]}" --show-bin-path)/$APP"

[ -f Assets/AppIcon.icns ] || swift Scripts/make-icon.swift Assets/AppIcon.icns
[ -d Assets/vendor ] || ./Scripts/fetch-vendor.sh

rm -rf "$OUT"
mkdir -p "$OUT/Contents/MacOS" "$OUT/Contents/Resources"
cp "$BIN" "$OUT/Contents/MacOS/"
cp Info.plist "$OUT/Contents/"
cp Assets/AppIcon.icns "$OUT/Contents/Resources/"
cp -R Assets/vendor "$OUT/Contents/Resources/vendor"
codesign --force --sign - "$OUT"
echo "built $OUT"

if [ "${1:-}" = "--install" ]; then
    rm -rf "/Applications/$APP.app"
    cp -R "$OUT" /Applications/
    echo "installed /Applications/$APP.app"
fi
