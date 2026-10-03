import AppKit
import SwiftUI

/// Edit → Find submenu. Drives the editor's built-in `NSTextFinder` bar (find, replace, next/previous).
struct FindCommands: View {
    @FocusedBinding(\.viewModeBinding) private var mode: ViewMode?

    var body: some View {
        Menu("Find") {
            Button("Find…") { trigger(.showFindInterface) }
                .keyboardShortcut("f", modifiers: .command)
            Button("Find and Replace…") { trigger(.showReplaceInterface) }
                .keyboardShortcut("f", modifiers: [.command, .option])
            Button("Find Next") { Self.performAction(.nextMatch) }
                .keyboardShortcut("g", modifiers: .command)
            Button("Find Previous") { Self.performAction(.previousMatch) }
                .keyboardShortcut("g", modifiers: [.command, .shift])
            Divider()
            Button("Use Selection for Find") { Self.performAction(.setSearchString) }
                .keyboardShortcut("e", modifiers: .command)
            Button("Hide Find Bar") { Self.performAction(.hideFindInterface) }
                .keyboardShortcut("f", modifiers: [.command, .shift])
        }
    }

    private func trigger(_ action: NSTextFinder.Action) {
        if mode == .preview {
            mode = .editor
        }
        DispatchQueue.main.async {
            Self.performAction(action)
        }
    }

    /// Sends the text-finder action to the editor of the key window.
    static func performAction(_ action: NSTextFinder.Action) {
        guard let window = NSApp.keyWindow else { return }
        if !(window.firstResponder is NSTextView) {
            guard let textView = firstTextView(in: window.contentView) else { return }
            window.makeFirstResponder(textView)
        }
        let item = NSMenuItem()
        item.tag = action.rawValue
        NSApp.sendAction(#selector(NSResponder.performTextFinderAction(_:)), to: nil, from: item)
    }

    private static func firstTextView(in view: NSView?) -> NSTextView? {
        guard let view else { return nil }
        if let textView = view as? NSTextView { return textView }
        for child in view.subviews {
            if let found = firstTextView(in: child) { return found }
        }
        return nil
    }
}
