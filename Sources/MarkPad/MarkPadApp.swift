import SwiftUI

@main
struct MarkPadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            EditorView(document: file.$document, fileURL: file.fileURL)
        }
        .commands {
            CommandGroup(after: .toolbar) {
                ViewModeCommands()
                Divider()
            }
        }
    }
}

private struct ViewModeCommands: View {
    @AppStorage(ViewMode.storageKey) private var mode: ViewMode = .split

    var body: some View {
        ForEach(Array(ViewMode.allCases.enumerated()), id: \.element) { index, item in
            Button(item.label) { mode = item }
                .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: .command)
        }
    }
}
