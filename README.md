# MarkPad

A small native markdown editor for macOS: edit on the left, live preview on the right. SwiftUI + `NSTextView` + `WKWebView`, no Electron.

macOS용 간편 마크다운 에디터. 왼쪽 편집, 오른쪽 실시간 미리보기.

![MarkPad](docs/screenshot.png)

## Features

- **Editor** — `NSTextView`: monospaced, smart quotes/dashes/autocorrect off, find bar (⌘F), undo
- **Preview** — `WKWebView` with GitHub-flavoured styling, follows system dark mode, keeps scroll position while typing
- **Markdown** — Apple [swift-markdown](https://github.com/swiftlang/swift-markdown) (CommonMark + GFM tables, strikethrough, task lists)
- **Math** — `$inline$` and `$$display$$` via KaTeX (Pandoc/Obsidian rules: no space after the opening `$`, `\$` is a literal dollar, code is never touched)
- **Diagrams** — ```` ```mermaid ```` blocks via Mermaid, dark theme aware
- **Documents** — New / Open / Save / autosave / window restoration; owns `.md` `.markdown` `.mdown` `.mkd`
- **View modes** — Editor (⌘1) · Split (⌘2) · Preview (⌘3)
- **Local images** — paths relative to the document work (served through a `markpad://` URL scheme handler, no private API)
- KaTeX and Mermaid are bundled but loaded lazily — documents without math or diagrams never pay for them

## Build

Requires Xcode 16+ (Swift 5.9 toolchain) and macOS 14+.

```bash
./build.sh            # → dist/MarkPad.app (ad-hoc signed)
./build.sh --install  # also copies it to /Applications
```

The first build generates the app icon (`Scripts/make-icon.swift`) and downloads pinned KaTeX/Mermaid builds (`Scripts/fetch-vendor.sh`) into `Assets/`.

To make MarkPad the default app for `.md` files: Finder → Get Info on any `.md` → Open With → MarkPad → Change All.

## Layout

```
Sources/MarkPad/
  MarkPadApp.swift              DocumentGroup entry point, view-mode menu
  AppDelegate.swift             closes the stray blank "Untitled" window DocumentGroup opens at launch
  MarkdownDocument.swift        FileDocument (UTF-8 text)
  EditorView.swift              split layout, toolbar, debounced render
  MarkdownTextView.swift        NSTextView wrapper
  PreviewView.swift             WKWebView wrapper (shell loads once, body swapped via JS)
  PreviewTemplate.swift         HTML shell, CSS, lazy KaTeX/Mermaid loader
  MarkdownRenderer.swift        markdown → HTML pipeline
  HTMLRenderer.swift            AST → HTML with escaping and heading ids (derived from swift-markdown)
  MathProtector.swift           lifts $…$ spans out before parsing, splices them back after
  LocalFileSchemeHandler.swift  markpad:///abs/path → local file
Scripts/                        make-icon.swift, fetch-vendor.sh
build.sh                        assembles the .app bundle
```

## License

MIT — see [LICENSE](LICENSE). Third-party components and their licenses are listed in [THIRD_PARTY.md](THIRD_PARTY.md).
