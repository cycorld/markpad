#!/usr/bin/env bash
# Downloads pinned KaTeX and Mermaid builds into Assets/vendor (loaded lazily by the preview).
set -euo pipefail
cd "$(dirname "$0")/.."

KATEX_VERSION=0.18.7
MERMAID_VERSION=12.0.0
OUT=Assets/vendor
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

rm -rf "$OUT"
mkdir -p "$OUT/katex/fonts" "$OUT/mermaid"

curl -fsSL "https://registry.npmjs.org/katex/-/katex-$KATEX_VERSION.tgz" | tar -xz -C "$TMP"
cp "$TMP/package/dist/katex.min.js" "$TMP/package/dist/katex.min.css" "$OUT/katex/"
cp "$TMP/package/dist/fonts/"*.woff2 "$OUT/katex/fonts/"
cp "$TMP/package/LICENSE" "$OUT/katex/LICENSE"
rm -rf "$TMP/package"

curl -fsSL "https://registry.npmjs.org/mermaid/-/mermaid-$MERMAID_VERSION.tgz" | tar -xz -C "$TMP"
cp "$TMP/package/dist/mermaid.min.js" "$OUT/mermaid/"
cp "$TMP/package/LICENSE" "$OUT/mermaid/LICENSE"

echo "katex $KATEX_VERSION, mermaid $MERMAID_VERSION -> $OUT"
du -sh "$OUT"/*
