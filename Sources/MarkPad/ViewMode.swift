import Foundation

/// The view mode determining which panes are visible in the document window.
public enum ViewMode: String, CaseIterable, Identifiable, Sendable {
    case editor = "editor"
    case split = "split"
    case preview = "preview"

    public static let storageKey = "viewMode"
    public static let defaultViewModeKey = "defaultViewMode"

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .editor: return "Editor"
        case .split: return "Split"
        case .preview: return "Preview"
        }
    }

    /// Layout-focused SF Symbols representing:
    /// - Editor: Left half filled (single editing pane)
    /// - Split: Split 2x1 panes (editor + preview side-by-side)
    /// - Preview: Right half filled (single preview pane)
    public var symbol: String {
        switch self {
        case .editor: return "rectangle.leadinghalf.filled"
        case .split: return "rectangle.split.2x1"
        case .preview: return "rectangle.trailinghalf.filled"
        }
    }
}
