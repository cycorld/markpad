import Sparkle
import SwiftUI
import UniformTypeIdentifiers

@main
struct MarkPadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }

    var body: some Scene {
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            EditorView(document: file.$document, fileURL: file.fileURL)
        }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
            CommandGroup(after: .pasteboard) {
                FindCommands()
            }
            CommandGroup(after: .toolbar) {
                ViewCommands()
                Divider()
            }
            CommandGroup(replacing: .printItem) {
                PrintCommands()
            }
        }

        Settings {
            TabView {
                EditorSettingsView()
                    .tabItem {
                        Label("Editor", systemImage: "doc.text")
                    }
                PrintSettingsView()
                    .tabItem {
                        Label("Print", systemImage: "printer")
                    }
                SparkleSettingsView(updater: updaterController.updater)
                    .tabItem {
                        Label("Updates", systemImage: "arrow.triangle.2.circlepath")
                    }
            }
        }
    }
}

private struct ViewCommands: View {
    @FocusedBinding(\.viewModeBinding) private var mode: ViewMode?
    @FocusedBinding(\.editorModeBinding) private var editorMode: EditorMode?
    @FocusedBinding(\.outlineBinding) private var showOutline: Bool?

    var body: some View {
        Menu("Editor Mode") {
            Button("Source (Plain Text)") {
                editorMode = .plain
            }
            .keyboardShortcut("1", modifiers: [.command, .option])

            Button("Live WYSIWYG") {
                editorMode = .wysiwyg
            }
            .keyboardShortcut("2", modifiers: [.command, .option])
        }
        .disabled(editorMode == nil)

        Divider()

        Button("Editor") {
            mode = .editor
        }
        .keyboardShortcut("1", modifiers: .command)
        .disabled(mode == nil)

        Button("Split") {
            mode = .split
        }
        .keyboardShortcut("2", modifiers: .command)
        .disabled(mode == nil)

        Button("Preview") {
            mode = .preview
        }
        .keyboardShortcut("3", modifiers: .command)
        .disabled(mode == nil)

        Divider()

        Button(showOutline == true ? "Hide Outline" : "Show Outline") {
            if let current = showOutline {
                showOutline = !current
            }
        }
        .keyboardShortcut("s", modifiers: [.command, .option])
        .disabled(showOutline == nil)
    }
}

private struct PrintCommands: View {
    @FocusedValue(\.printSource) private var source

    var body: some View {
        Button("Page Setup…") {
            NSPageLayout().runModal(with: NSPrintInfo.shared)
        }
        .keyboardShortcut("p", modifiers: [.command, .shift])

        Button("Print…") {
            if let source { PrintController.shared.print(source, from: NSApp.keyWindow) }
        }
        .keyboardShortcut("p", modifiers: .command)
        .disabled(source == nil)

        Button("Export as PDF…") {
            if let source { exportPDF(source) }
        }
        .keyboardShortcut("p", modifiers: [.command, .option])
        .disabled(source == nil)
    }

    private func exportPDF(_ source: PrintSource) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = source.title + ".pdf"
        let host = NSApp.keyWindow
        let handler: (NSApplication.ModalResponse) -> Void = { response in
            guard response == .OK, let url = panel.url else { return }
            PrintController.shared.exportPDF(source, to: url, host: host) { ok in
                guard !ok else { return }
                let alert = NSAlert()
                alert.messageText = "Couldn't export the PDF."
                alert.runModal()
            }
        }
        if let host {
            panel.beginSheetModal(for: host, completionHandler: handler)
        } else {
            handler(panel.runModal())
        }
    }
}
