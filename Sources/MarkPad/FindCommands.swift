import AppKit
import SwiftUI

/// Edit → Find submenu. Drives the editor's built-in `NSTextFinder` bar (find, replace, next/previous).
struct FindCommands: View {
    var body: some View {
        Menu("Find") {
            Button("Find…") { Self.perform(.showFindInterface) }
                .keyboardShortcut("f", modifiers: .command)
            Button("Find and Replace…") { Self.perform(.showReplaceInterface) }
                .keyboardShortcut("f", modifiers: [.command, .option])
            Button("Find Next") { Self.perform(.nextMatch) }
                .keyboardShortcut("g", modifiers: .command)
            Button("Find Previous") { Self.perform(.previousMatch) }
                .keyboardShortcut("g", modifiers: [.command, .shift])
            Divider()
            Button("Use Selection for Find") { Self.perform(.setSearchString) }
                .keyboardShortcut("e", modifiers: .command)
            Button("Hide Find Bar") { Self.perform(.hideFindInterface) }
                .keyboardShortcut("f", modifiers: [.command, .shift])
        }
    }

    /// Sends the text-finder action to the editor of the key window. If the editor isn't visible
    /// (preview-only mode) the window switches to split view first.
    static func perform(_ action: NSTextFinder.Action, retrying: Bool = false) {
        guard let window = NSApp.keyWindow else { return }
        if !(window.firstResponder is NSTextView) {
            guard let textView = firstTextView(in: window.contentView) else {
                guard !retrying else { return }
                UserDefaults.standard.set(ViewMode.split.rawValue, forKey: ViewMode.storageKey)
                DispatchQueue.main.async { perform(action, retrying: true) }
                return
            }
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
