import SwiftUI

/// Settings → Editor: editing mode (Plain Text vs Live WYSIWYG) and editor behaviors.
struct EditorSettingsView: View {
    @AppStorage(EditorMode.storageKey) private var editorMode: EditorMode = .wysiwyg

    var body: some View {
        Form {
            Section("Editing Experience") {
                Picker("Editor Mode", selection: $editorMode) {
                    ForEach(EditorMode.allCases) { mode in
                        Label(mode.label, systemImage: mode.symbol).tag(mode)
                    }
                }
                .pickerStyle(.radioGroup)

                Text(modeDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }

            Section("Mode Differences") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Image(systemName: "character.cursor.ibeam")
                            .frame(width: 20)
                            .foregroundStyle(.tint)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Plain Text (Source)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Raw monospaced markdown with zero text formatting. Best for direct source editing, code blocks, and distraction-free plain text.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    HStack(alignment: .top) {
                        Image(systemName: "text.badge.sparkles")
                            .frame(width: 20)
                            .foregroundStyle(.tint)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Live WYSIWYG")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Native AppKit & TextKit 2 live styling (powered by MarkdownEngine). Headings, bold/italic, task checkboxes, and lists render formatted in-place while keeping standard markdown on disk.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .navigationTitle("Editor")
    }

    private var modeDescription: String {
        switch editorMode {
        case .plain:
            return "Displays markdown as plain monospace text. Fast and simple."
        case .wysiwyg:
            return "Styles headings, emphasis, lists, and task checkboxes live as you type."
        }
    }
}
