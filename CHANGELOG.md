# Changelog

All notable changes to MarkPad are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

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

[Unreleased]: https://github.com/cycorld/markpad/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/cycorld/markpad/releases/tag/v0.1.0
