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
mkdir -p "$OUT/Contents/MacOS" "$OUT/Contents/Resources" "$OUT/Contents/Frameworks"
cp "$BIN" "$OUT/Contents/MacOS/"
cp Info.plist "$OUT/Contents/"
cp Assets/AppIcon.icns "$OUT/Contents/Resources/"
cp -R Assets/vendor "$OUT/Contents/Resources/vendor"

# Copy all SPM resource bundles (*.bundle) into Contents/Resources/
find .build -type d -name "*.bundle" | while read -r bundle; do
    echo "Copying resource bundle $bundle -> $OUT/Contents/Resources/"
    cp -R "$bundle" "$OUT/Contents/Resources/"
done

for b in "$OUT/Contents/Resources/"*.bundle; do
    [ -d "$b" ] || continue
    codesign --force --sign - "$b" 2>/dev/null || true
done

# Copy Sparkle.framework if present in build artifacts
SPARKLE_FRAMEWORK=$(find .build -name "Sparkle.framework" -type d | head -n 1)
if [ -n "$SPARKLE_FRAMEWORK" ]; then
    cp -R "$SPARKLE_FRAMEWORK" "$OUT/Contents/Frameworks/"
    codesign --force --deep --sign - "$OUT/Contents/Frameworks/Sparkle.framework"
fi

install_name_tool -add_rpath @executable_path/../Frameworks "$OUT/Contents/MacOS/$APP" 2>/dev/null || true
codesign --force --deep --sign - "$OUT"
echo "built $OUT"

if [ "${1:-}" = "--install" ]; then
    rm -rf "/Applications/$APP.app"
    cp -R "$OUT" /Applications/
    echo "installed /Applications/$APP.app"
fi
