# Third-party components

| Component | Version | License | Use |
|---|---|---|---|
| [swift-markdown](https://github.com/swiftlang/swift-markdown) | 0.8.0 | Apache-2.0 with Runtime Library Exception | Markdown parser (SwiftPM dependency). `Sources/MarkPad/HTMLRenderer.swift` is derived from its `HTMLFormatter`. |
| [KaTeX](https://katex.org) | 0.18.7 | MIT | Math rendering. Downloaded by `Scripts/fetch-vendor.sh`, bundled into the app. |
| [Mermaid](https://mermaid.js.org) | 12.0.0 | MIT | Diagram rendering. Downloaded by `Scripts/fetch-vendor.sh`, bundled into the app. |
| [highlight.js](https://highlightjs.org) | 11.12.0 | BSD-3-Clause | Code syntax highlighting (`@highlightjs/cdn-assets`, github / github-dark themes). Downloaded by `Scripts/fetch-vendor.sh`, bundled into the app. |

License texts for KaTeX, Mermaid and highlight.js are copied next to the downloaded files in `Assets/vendor/`.
