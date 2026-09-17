# Contributing to MarkPad

Thanks for helping. MarkPad is deliberately small — a native editor pane, a `WKWebView` preview, and as little in between as possible. Contributions that keep it that way are the easiest to merge.

## Before you start

- **Bugs**: open an issue with the markdown that misbehaves (a minimal snippet is ideal), what you expected, and your macOS / MarkPad version.
- **Features**: open an issue first so we can agree on scope. Things that fit: rendering fidelity, editor ergonomics, performance. Things that probably don't: cloud sync, accounts, plugins, anything that needs a server.
- Small fixes (typos, obvious bugs) can go straight to a pull request.

## Development

```bash
git clone git@github.com:cycorld/markpad.git
cd markpad
swift test              # unit tests (renderer, math protection)
./build.sh              # dist/MarkPad.app
./build.sh --install    # copy into /Applications
```

Requirements: Xcode 16 or newer (Swift 5.9 toolchain), macOS 14 or newer. The first build downloads pinned KaTeX / Mermaid / highlight.js builds into `Assets/vendor/` (git-ignored) and generates the app icon.

There is no Xcode project; the package is plain SwiftPM. `swift build` gives a bare executable, `build.sh` wraps it into an `.app` with `Info.plist`, icon and vendor assets, and ad-hoc signs it.

## Pull requests

1. Branch from `main`. Keep one change per PR.
2. Add or update tests in `Tests/MarkPadTests` when you touch `HTMLRenderer`, `MathProtector` or `MarkdownRenderer`. UI changes: describe how you verified them (a screenshot helps).
3. `swift test` must pass. CI runs it on every PR.
4. Match the surrounding style: 4-space indent, no trailing whitespace, `// MARK:` sections, doc comments on types. No `force unwrap` in app code outside scripts.
5. Vendor libraries are pinned in `Scripts/fetch-vendor.sh`. Bump versions there and in `THIRD_PARTY.md` together.
6. Commit messages: short imperative subject, body explains *why* when it isn't obvious.

## Project layout

See the "Layout" section of the README. The renderer pipeline is `MarkdownRenderer` → `MathProtector.extract` → `HTMLRenderer` → `MathProtector.restore`; the preview's JavaScript (`PreviewTemplate.swift`) then lazy-loads KaTeX, Mermaid and highlight.js only for documents that need them.

## License

By contributing you agree that your contributions are licensed under the MIT License (see `LICENSE`). `Sources/MarkPad/HTMLRenderer.swift` is derived from swift-markdown and keeps its Apache-2.0 header — preserve it when editing that file.
