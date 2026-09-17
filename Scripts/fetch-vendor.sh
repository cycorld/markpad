#!/usr/bin/env bash
# Downloads pinned KaTeX, Mermaid and highlight.js builds into Assets/vendor (loaded lazily by the preview).
set -euo pipefail
cd "$(dirname "$0")/.."

KATEX_VERSION=0.18.7
MERMAID_VERSION=12.0.0
HLJS_VERSION=11.12.0
OUT=Assets/vendor
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

rm -rf "$OUT"
mkdir -p "$OUT/katex/fonts" "$OUT/mermaid" "$OUT/highlight"

curl -fsSL "https://registry.npmjs.org/katex/-/katex-$KATEX_VERSION.tgz" | tar -xz -C "$TMP"
cp "$TMP/package/dist/katex.min.js" "$TMP/package/dist/katex.min.css" "$OUT/katex/"
cp "$TMP/package/dist/fonts/"*.woff2 "$OUT/katex/fonts/"
cp "$TMP/package/LICENSE" "$OUT/katex/LICENSE"
rm -rf "$TMP/package"

curl -fsSL "https://registry.npmjs.org/mermaid/-/mermaid-$MERMAID_VERSION.tgz" | tar -xz -C "$TMP"
cp "$TMP/package/dist/mermaid.min.js" "$OUT/mermaid/"
cp "$TMP/package/LICENSE" "$OUT/mermaid/LICENSE"
rm -rf "$TMP/package"

curl -fsSL "https://registry.npmjs.org/@highlightjs/cdn-assets/-/cdn-assets-$HLJS_VERSION.tgz" | tar -xz -C "$TMP"
cp "$TMP/package/highlight.min.js" "$OUT/highlight/"
cp -R "$TMP/package/languages" "$OUT/highlight/languages"
cp "$TMP/package/styles/github.min.css" "$TMP/package/styles/github-dark.min.css" "$OUT/highlight/"
cp "$TMP/package/LICENSE" "$OUT/highlight/LICENSE"

echo "katex $KATEX_VERSION, mermaid $MERMAID_VERSION, highlight.js $HLJS_VERSION -> $OUT"
du -sh "$OUT"/*
