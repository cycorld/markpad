# Security Policy

MarkPad is a local, offline document editor. It makes no network requests at runtime; the preview's JavaScript, KaTeX, Mermaid and highlight.js are bundled inside the app. The one thing worth knowing: the preview can load images (and only images, fonts, scripts and styles it references itself) from any absolute path the app can read, via its internal `markpad://` URL scheme, so a malicious markdown file could reference local files by path. The preview cannot exfiltrate them anywhere.

## Reporting a vulnerability

Please use GitHub's private vulnerability reporting for this repository
(**Security → Report a vulnerability**) rather than a public issue.
Include a minimal markdown file that demonstrates the problem if you can.

You should hear back within a week. Fixes ship as a new release; supported version is always the latest release.
