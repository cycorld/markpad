import SwiftUI
import UniformTypeIdentifiers

@main
struct MarkPadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            EditorView(document: file.$document, fileURL: file.fileURL)
        }
        .commands {
            CommandGroup(after: .toolbar) {
                ViewCommands()
                Divider()
            }
            CommandGroup(replacing: .printItem) {
                PrintCommands()
            }
        }

        Settings {
            PrintSettingsView()
        }
    }
}

private struct ViewCommands: View {
    @AppStorage(ViewMode.storageKey) private var mode: ViewMode = .split
    @AppStorage(EditorView.outlineStorageKey) private var showOutline = false

    var body: some View {
        ForEach(Array(ViewMode.allCases.enumerated()), id: \.element) { index, item in
            Button(item.label) { mode = item }
                .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: .command)
        }
        Divider()
        Toggle("Outline", isOn: $showOutline)
            .keyboardShortcut("s", modifiers: [.command, .option])
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
