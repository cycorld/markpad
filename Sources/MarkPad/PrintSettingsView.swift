import SwiftUI

/// Settings → Print: header / footer templates and page-number style.
struct PrintSettingsView: View {
    @AppStorage(PrintOptions.Keys.headerEnabled) private var headerEnabled = true
    @AppStorage(PrintOptions.Keys.headerLeft) private var headerLeft = "{title}"
    @AppStorage(PrintOptions.Keys.headerCenter) private var headerCenter = ""
    @AppStorage(PrintOptions.Keys.headerRight) private var headerRight = "{date}"
    @AppStorage(PrintOptions.Keys.footerEnabled) private var footerEnabled = true
    @AppStorage(PrintOptions.Keys.footerLeft) private var footerLeft = ""
    @AppStorage(PrintOptions.Keys.footerCenter) private var footerCenter = "{page}"
    @AppStorage(PrintOptions.Keys.footerRight) private var footerRight = ""
    @AppStorage(PrintOptions.Keys.pageNumberStyle) private var pageNumberStyle = PrintOptions.PageNumberStyle.slash.rawValue

    var body: some View {
        Form {
            Section("Header") {
                Toggle("Print header", isOn: $headerEnabled)
                TextField("Left", text: $headerLeft)
                TextField("Center", text: $headerCenter)
                TextField("Right", text: $headerRight)
            }
            .disabled(false)
            Section("Footer") {
                Toggle("Print footer", isOn: $footerEnabled)
                TextField("Left", text: $footerLeft)
                TextField("Center", text: $footerCenter)
                TextField("Right", text: $footerRight)
            }
            Section("Page numbers") {
                Picker("{page} looks like", selection: $pageNumberStyle) {
                    ForEach(PrintOptions.PageNumberStyle.allCases) { style in
                        Text(style.label).tag(style.rawValue)
                    }
                }
            }
            Section {
                Text("Tokens: {title} document name · {file} file name · {page} page number · {pages} page count · {date} · {time}")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Paper size and orientation come from File → Page Setup…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .navigationTitle("Print")
    }
}
