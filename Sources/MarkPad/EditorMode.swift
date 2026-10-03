import Foundation

/// The editing style used in the editor pane.
public enum EditorMode: String, CaseIterable, Identifiable, Sendable {
    case plain = "plain"
    case wysiwyg = "wysiwyg"

    public static let storageKey = "editorMode"
    public static let defaultModeKey = "defaultEditorMode"

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .plain: return "Plain Text (Source)"
        case .wysiwyg: return "Live WYSIWYG"
        }
    }

    public var shortLabel: String {
        switch self {
        case .plain: return "Source"
        case .wysiwyg: return "WYSIWYG"
        }
    }

    public var symbol: String {
        switch self {
        case .plain: return "character.cursor.ibeam"
        case .wysiwyg: return "text.badge.sparkles"
        }
    }
}
