import SwiftUI

private struct FocusedViewModeKey: FocusedValueKey {
    typealias Value = Binding<ViewMode>
}

private struct FocusedEditorModeKey: FocusedValueKey {
    typealias Value = Binding<EditorMode>
}

private struct FocusedOutlineKey: FocusedValueKey {
    typealias Value = Binding<Bool>
}

extension FocusedValues {
    var viewModeBinding: Binding<ViewMode>? {
        get { self[FocusedViewModeKey.self] }
        set { self[FocusedViewModeKey.self] = newValue }
    }

    var editorModeBinding: Binding<EditorMode>? {
        get { self[FocusedEditorModeKey.self] }
        set { self[FocusedEditorModeKey.self] = newValue }
    }

    var outlineBinding: Binding<Bool>? {
        get { self[FocusedOutlineKey.self] }
        set { self[FocusedOutlineKey.self] = newValue }
    }
}

struct EditorView: View {
    static let outlineStorageKey = "showOutline"

    @Binding var document: MarkdownDocument
    let fileURL: URL?

    @State private var mode: ViewMode
    @State private var showOutline: Bool
    @State private var editorMode: EditorMode
    @State private var html = ""
    @State private var headings: [HeadingInfo] = []
    @State private var jump: JumpRequest?
    @State private var showEditConfirmation = false
    @State private var lastEditMode: ViewMode = .editor

    init(document: Binding<MarkdownDocument>, fileURL: URL?) {
        self._document = document
        self.fileURL = fileURL

        let defaultEditor = UserDefaults.standard.string(forKey: EditorMode.defaultModeKey)
            .flatMap(EditorMode.init) ?? .wysiwyg
        self._editorMode = State(initialValue: defaultEditor)

        let defaultView = UserDefaults.standard.string(forKey: ViewMode.defaultViewModeKey)
            .flatMap(ViewMode.init) ?? (defaultEditor == .wysiwyg ? .editor : .split)
        self._mode = State(initialValue: defaultView)
        self._lastEditMode = State(initialValue: defaultView == .preview ? .editor : defaultView)

        let defaultOutline = UserDefaults.standard.bool(forKey: Self.outlineStorageKey)
        self._showOutline = State(initialValue: defaultOutline)
    }

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
                PreviewView(
                    html: html,
                    baseURL: directoryURL,
                    jump: jump,
                    isPreviewOnly: mode == .preview,
                    onEditRequest: { immediate in
                        handleEditRequest(immediate: immediate)
                    }
                )
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
        .focusedSceneValue(\.viewModeBinding, $mode)
        .focusedSceneValue(\.editorModeBinding, $editorMode)
        .focusedSceneValue(\.outlineBinding, $showOutline)
        .alert("문서를 수정하시겠습니까?", isPresented: $showEditConfirmation) {
            Button("수정") {
                switchToEditMode()
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("보기 모드에서 편집 모드로 전환합니다.")
        }
        .onChange(of: mode) { oldMode, newMode in
            if oldMode != .preview {
                lastEditMode = oldMode
            }
        }
        .task(id: document.text) { await render(document.text) }
    }

    private func handleEditRequest(immediate: Bool) {
        guard mode == .preview else { return }
        if immediate {
            switchToEditMode()
        } else {
            showEditConfirmation = true
        }
    }

    private func switchToEditMode() {
        withAnimation(.easeInOut(duration: 0.15)) {
            if lastEditMode == .preview {
                mode = .editor
            } else {
                mode = lastEditMode
            }
        }
    }

    private var directoryURL: URL? { fileURL?.deletingLastPathComponent() }

    private var shouldShowEditor: Bool {
        mode != .preview
    }

    private var shouldShowPreview: Bool {
        mode != .editor
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
