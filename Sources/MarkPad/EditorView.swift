import SwiftUI

enum ViewMode: String, CaseIterable, Identifiable {
    case editor, split, preview

    static let storageKey = "viewMode"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .editor: "Editor"
        case .split: "Split"
        case .preview: "Preview"
        }
    }

    var symbol: String {
        switch self {
        case .editor: "square.and.pencil"
        case .split: "rectangle.split.2x1"
        case .preview: "eye"
        }
    }
}

struct EditorView: View {
    static let outlineStorageKey = "showOutline"

    @Binding var document: MarkdownDocument
    let fileURL: URL?

    @AppStorage(ViewMode.storageKey) private var mode: ViewMode = .split
    @AppStorage(Self.outlineStorageKey) private var showOutline = false
    @AppStorage(EditorMode.storageKey) private var editorMode: EditorMode = .wysiwyg
    @State private var html = ""
    @State private var headings: [HeadingInfo] = []
    @State private var jump: JumpRequest?

    var body: some View {
        HSplitView {
            if showOutline {
                OutlineView(headings: headings) { jump = JumpRequest(heading: $0) }
                    .frame(minWidth: 160, idealWidth: 220, maxWidth: 360, maxHeight: .infinity)
            }
            if shouldShowEditor {
                editorPane
                    .frame(minWidth: 320, maxWidth: .infinity, maxHeight: .infinity)
            }
            if shouldShowPreview {
                PreviewView(html: html, baseURL: directoryURL, jump: jump)
                    .frame(minWidth: 320, maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 520, minHeight: 360)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    showOutline.toggle()
                } label: {
                    Image(systemName: "sidebar.leading")
                }
                .help("Outline (⌥⌘S)")
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Picker("Editor Mode", selection: $editorMode) {
                    ForEach(EditorMode.allCases) { item in
                        Text(item.shortLabel).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .help("Editor Mode: Source (plain text) or WYSIWYG (live rich text)")

                if editorMode == .plain {
                    Picker("View", selection: $mode) {
                        ForEach(ViewMode.allCases) { item in
                            Image(systemName: item.symbol).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .help("Editor (⌘1) · Split (⌘2) · Preview (⌘3)")
                } else {
                    Picker("View", selection: Binding(
                        get: { mode == .preview ? ViewMode.preview : ViewMode.editor },
                        set: { mode = $0 }
                    )) {
                        Image(systemName: "square.and.pencil").tag(ViewMode.editor)
                        Image(systemName: "eye").tag(ViewMode.preview)
                    }
                    .pickerStyle(.segmented)
                    .help("WYSIWYG Editor (⌘1) · HTML Preview (⌘3)")
                }
            }
        }
        .focusedSceneValue(\.printSource, printSource)
        .task(id: document.text) { await render(document.text) }
    }

    private var directoryURL: URL? { fileURL?.deletingLastPathComponent() }

    private var shouldShowEditor: Bool {
        mode != .preview
    }

    private var shouldShowPreview: Bool {
        if editorMode == .wysiwyg {
            // In WYSIWYG mode, preview is only shown when explicitly in Preview mode. Never side-by-side split.
            return mode == .preview
        }
        return mode != .editor
    }

    private var printSource: PrintSource {
        PrintSource(
            html: html,
            baseURL: directoryURL,
            title: fileURL?.deletingPathExtension().lastPathComponent ?? "Untitled",
            fileName: fileURL?.lastPathComponent ?? "Untitled.md"
        )
    }

    private var editorPane: some View {
        VStack(spacing: 0) {
            if editorMode == .wysiwyg {
                WysiwygTextView(
                    text: $document.text,
                    documentId: fileURL?.path ?? "untitled"
                )
            } else {
                MarkdownTextView(text: $document.text, jump: jump)
            }
            Divider()
            HStack {
                Text("\(wordCount) words")
                Spacer()
                Text("\(lineCount) lines")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
            .background(.bar)
        }
    }

    private var wordCount: Int {
        document.text.split(whereSeparator: \.isWhitespace).count
    }

    private var lineCount: Int {
        document.text.isEmpty ? 0 : document.text.split(separator: "\n", omittingEmptySubsequences: false).count
    }

    private func render(_ text: String) async {
        try? await Task.sleep(for: .milliseconds(100))
        guard !Task.isCancelled else { return }
        let result = await Task.detached(priority: .userInitiated) {
            MarkdownRenderer.render(text)
        }.value
        guard !Task.isCancelled else { return }
        html = result.html
        headings = result.headings
    }
}
