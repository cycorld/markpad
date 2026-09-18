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
    @State private var html = ""
    @State private var headings: [HeadingInfo] = []
    @State private var jump: JumpRequest?

    var body: some View {
        HSplitView {
            if showOutline {
                OutlineView(headings: headings) { jump = JumpRequest(heading: $0) }
                    .frame(minWidth: 160, idealWidth: 220, maxWidth: 360, maxHeight: .infinity)
            }
            if mode != .preview {
                editorPane
                    .frame(minWidth: 320, maxWidth: .infinity, maxHeight: .infinity)
            }
            if mode != .editor {
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
            ToolbarItem(placement: .primaryAction) {
                Picker("View", selection: $mode) {
                    ForEach(ViewMode.allCases) { item in
                        Image(systemName: item.symbol).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .help("Editor (⌘1) · Split (⌘2) · Preview (⌘3)")
            }
        }
        .focusedSceneValue(\.printSource, printSource)
        .task(id: document.text) { await render(document.text) }
    }

    private var directoryURL: URL? { fileURL?.deletingLastPathComponent() }

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
            MarkdownTextView(text: $document.text, jump: jump)
            Divider()
            HStack {
                Text("\(wordCount) words")
                Spacer()
                Text("\(lineCount) lines")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
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
