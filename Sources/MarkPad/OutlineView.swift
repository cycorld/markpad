import SwiftUI

/// A request to scroll both panes to a heading; a fresh token per click so repeated clicks work.
struct JumpRequest: Equatable {
    let heading: HeadingInfo
    let token = UUID()
}

/// Sidebar list of the document's headings.
struct OutlineView: View {
    let headings: [HeadingInfo]
    let onSelect: (HeadingInfo) -> Void

    var body: some View {
        List(headings) { heading in
            Button {
                onSelect(heading)
            } label: {
                Text(heading.text.isEmpty ? "(untitled)" : heading.text)
                    .font(heading.level <= 2 ? .body.weight(.medium) : .callout)
                    .foregroundStyle(heading.level <= 2 ? .primary : .secondary)
                    .lineLimit(1)
                    .padding(.leading, CGFloat(max(0, heading.level - 1)) * 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(heading.text)
        }
        .listStyle(.sidebar)
        .overlay {
            if headings.isEmpty {
                Text("No headings")
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
