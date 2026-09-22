# MarkPad

[![CI](https://github.com/cycorld/markpad/actions/workflows/ci.yml/badge.svg)](https://github.com/cycorld/markpad/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/cycorld/markpad?display_name=tag)](https://github.com/cycorld/markpad/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**English** | [한국어](README.ko.md)

A small native markdown editor for macOS: edit on the left, live preview on the right. SwiftUI + `NSTextView` + `WKWebView`, no Electron. Math, diagrams, syntax highlighting, table of contents, and printing with headers and footers — all offline.

![MarkPad](docs/screenshot.png)

## Features

- **Editor** — `NSTextView`: monospaced, smart quotes/dashes/autocorrect off, undo, find and replace (⌘F / ⌥⌘F) with incremental highlighting
- **Preview** — `WKWebView` with GitHub-flavoured styling, follows system dark mode, keeps scroll position while typing
- **Markdown** — Apple [swift-markdown](https://github.com/swiftlang/swift-markdown) (CommonMark + GFM tables, strikethrough, task lists)
- **Math** — `$inline$` and `$$display$$` via KaTeX (Pandoc/Obsidian rules: no space after the opening `$`, `\$` is a literal dollar, code is never touched)
- **Diagrams** — ```` ```mermaid ```` blocks via Mermaid, dark theme aware
- **Code** — fenced blocks with a language are highlighted by highlight.js (GitHub light/dark themes); languages outside the common bundle load on demand
- **Table of contents** — a paragraph containing just `[TOC]` (or `[[toc]]`) becomes a nested list of the document's headings; every heading gets a GitHub-style anchor id, so `[link](#section)` works
- **Outline sidebar** — ⌥⌘S lists the headings; click one to jump both the editor and the preview
- **Print & PDF** — ⌘P prints the rendered preview through the normal print panel; ⌥⌘P exports a PDF. Header and footer are configurable in Settings (⌘,) with `{title}` `{file}` `{page}` `{pages}` `{date}` `{time}` tokens and four page-number styles. Paper size and orientation come from Page Setup (⇧⌘P)
- **Documents** — New / Open / Save / autosave / window restoration; owns `.md` `.markdown` `.mdown` `.mkd`
- **View modes** — Editor (⌘1) · Split (⌘2) · Preview (⌘3)
- **Local images** — paths relative to the document work (served through a `markpad://` URL scheme handler, no private API)
- KaTeX, Mermaid and highlight.js are bundled but loaded lazily — a document only pays for what it uses

## Install

### Requirements

- macOS 14 Sonoma or later
- Apple silicon or Intel (the release build is a universal binary)
- No other dependencies — nothing is fetched at runtime

### 1. Download

1. Open the [latest release](https://github.com/cycorld/markpad/releases/latest) and download `MarkPad-vX.Y.Z.zip`.
2. Double-click the zip to unpack `MarkPad.app`.
3. Drag `MarkPad.app` into your `Applications` folder.

Optional — verify the download. Put `SHA256SUMS.txt` from the same release next to the zip and run:

```bash
shasum -a 256 -c SHA256SUMS.txt
```

### 2. First launch

MarkPad is ad-hoc signed and not notarized (there is no paid Apple Developer account behind it), so macOS blocks the very first launch with *"MarkPad" cannot be opened because Apple cannot verify it* or *… was not opened*. Allow it once, with whichever of these you prefer:

**macOS 15 Sequoia or later**

1. Double-click `MarkPad.app` once and dismiss the warning.
2. Open **System Settings → Privacy & Security**, scroll down to **Security**.
3. Next to *"MarkPad" was blocked to protect your Mac*, click **Open Anyway**, then confirm with **Open Anyway** again (you may be asked for your password or Touch ID).

**macOS 14 Sonoma**

1. Control-click (right-click) `MarkPad.app` → **Open**.
2. Click **Open** in the dialog.

**Terminal (any version)**

```bash
xattr -d com.apple.quarantine /Applications/MarkPad.app
```

This removes the quarantine flag macOS puts on downloaded files. After that MarkPad opens like any other app. You will need to repeat this step after installing a new version.

### 3. Open `.md` files with MarkPad

To make MarkPad the default app for markdown files:

1. In Finder, select any `.md` file and press ⌘I (**Get Info**).
2. Under **Open with**, choose **MarkPad**.
3. Click **Change All…** and confirm.

Double-clicking `.md`, `.markdown`, `.mdown` and `.mkd` files now opens them in MarkPad. You can also drop a file onto the app icon, or use `open -a MarkPad notes.md` from the terminal.

### Updating

Download the new zip and replace `MarkPad.app` in `Applications`. Your settings (view mode, outline, print header/footer) live in macOS user defaults and survive the swap. Gatekeeper treats the new copy as a new download, so run step 2 again.

### Uninstall

Move `MarkPad.app` to the Trash. To remove every trace:

```bash
defaults delete com.cycorld.markpad
rm -rf ~/Library/Saved\ Application\ State/com.cycorld.markpad.savedState
```

### Build from source

Requires Xcode 16 or newer (Swift 5.9 toolchain) and macOS 14 or newer.

```bash
git clone https://github.com/cycorld/markpad.git
cd markpad
./build.sh            # → dist/MarkPad.app (universal, ad-hoc signed)
./build.sh --install  # also copies it to /Applications
```

The first build generates the app icon (`Scripts/make-icon.swift`) and downloads pinned KaTeX / Mermaid / highlight.js builds (`Scripts/fetch-vendor.sh`) into `Assets/`. Apps you build yourself are not quarantined, so the Gatekeeper step is not needed.

## Usage

| Action | Shortcut |
|---|---|
| New / Open / Save | ⌘N / ⌘O / ⌘S |
| Editor only / Split / Preview only | ⌘1 / ⌘2 / ⌘3 |
| Toggle outline sidebar | ⌥⌘S |
| Find / Find and Replace | ⌘F / ⌥⌘F |
| Find next / previous | ⌘G / ⇧⌘G |
| Use selection for find · Hide find bar | ⌘E · ⇧⌘F |
| Print | ⌘P |
| Export as PDF | ⌥⌘P |
| Page Setup (paper size, orientation) | ⇧⌘P |
| Print header / footer settings | ⌘, |

### Headless PDF export

```bash
/Applications/MarkPad.app/Contents/MacOS/MarkPad --export-pdf notes.md notes.pdf
```

Renders the file with the same pipeline as ⌘P (header/footer settings included) and exits. Set `MARKPAD_DEBUG=1` to trace the pipeline on stderr.

## Layout

```
Sources/MarkPad/
  MarkPadApp.swift              DocumentGroup entry point, view-mode menu
  AppDelegate.swift             closes the stray blank "Untitled" window DocumentGroup opens at launch
  MarkdownDocument.swift        FileDocument (UTF-8 text)
  EditorView.swift              outline / editor / preview layout, toolbar, debounced render
  OutlineView.swift             heading sidebar
  MarkdownTextView.swift        NSTextView wrapper
  PreviewView.swift             WKWebView wrapper (shell loads once, body swapped via JS)
  PreviewTemplate.swift         HTML shell, CSS (screen + print), lazy KaTeX/Mermaid/highlight.js loader
  MarkdownRenderer.swift        markdown → HTML pipeline
  HTMLRenderer.swift            AST → HTML with escaping, unique heading ids, heading list (derived from swift-markdown)
  MathProtector.swift           lifts $…$ spans out before parsing, splices them back after
  LocalFileSchemeHandler.swift  markpad:///abs/path → local file
  PrintController.swift         WebKit pagination → PDF → pages drawn with header/footer → print panel / file
  PrintOptions.swift            header / footer templates, page-number styles (UserDefaults)
  PrintSettingsView.swift       Settings → Print
Scripts/                        make-icon.swift, fetch-vendor.sh
build.sh                        assembles the .app bundle
```

## Contributing

Issues and pull requests are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). Please follow the [Code of Conduct](CODE_OF_CONDUCT.md). Security problems: [SECURITY.md](SECURITY.md). Changes are tracked in [CHANGELOG.md](CHANGELOG.md).

## License

MIT — see [LICENSE](LICENSE). Third-party components and their licenses are listed in [THIRD_PARTY.md](THIRD_PARTY.md).
