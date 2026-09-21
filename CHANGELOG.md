# Changelog

All notable changes to MarkPad are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.2.1] - 2026-09-21

### Added
- Universal binary: releases now run on Intel Macs as well as Apple silicon
- `SHA256SUMS.txt` attached to every release
- Step-by-step install guide in the README, plus a Korean README (`README.ko.md`)

## [0.2.0] - 2026-09-18

### Added
- `[TOC]` / `[[toc]]` paragraph expands to a nested table of contents
- Outline sidebar (⌥⌘S) with click-to-jump in both editor and preview
- Printing (⌘P) of the rendered document with configurable header / footer (Settings → Print): `{title}` `{file}` `{page}` `{pages}` `{date}` `{time}` tokens, four page-number styles
- Export as PDF (⌥⌘P) and headless `MarkPad --export-pdf in.md out.pdf`
- Page Setup (⇧⌘P)
- Print stylesheet: light colors, no page breaks inside code, tables, diagrams and math

### Changed
- Duplicate headings get unique anchor ids (`-1`, `-2`, …)
- Display math no longer shifts source line numbers of later headings

## [0.1.0] - 2026-09-18

### Added
- Split editor / live preview with Editor, Split and Preview modes (⌘1 / ⌘2 / ⌘3)
- `NSTextView` editor with smart substitutions disabled, find bar and undo
- swift-markdown based rendering with GFM tables, strikethrough and task lists
- HTML escaping and GitHub-style heading anchors in the renderer
- KaTeX math (`$…$`, `$$…$$`) with Pandoc-style delimiter rules
- Mermaid diagrams from ```` ```mermaid ```` blocks, dark-theme aware
- highlight.js syntax highlighting for fenced code blocks, per-language lazy loading
- Document-relative images through a `markpad://` URL scheme handler
- Document-based app: open / save / autosave / window restoration, owns `.md` files
- `build.sh` bundle assembly with generated icon and pinned vendor assets

[Unreleased]: https://github.com/cycorld/markpad/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/cycorld/markpad/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/cycorld/markpad/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/cycorld/markpad/releases/tag/v0.1.0
