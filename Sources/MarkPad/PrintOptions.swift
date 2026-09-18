import Foundation

/// Header / footer configuration for printing, stored in UserDefaults (edited in Settings → Print).
struct PrintOptions {
    enum PageNumberStyle: String, CaseIterable, Identifiable {
        case plain, slash, pageOf, dashed

        var id: String { rawValue }

        var label: String {
            switch self {
            case .plain: "1"
            case .slash: "1 / 5"
            case .pageOf: "Page 1 of 5"
            case .dashed: "– 1 –"
            }
        }

        func format(page: Int, pages: Int) -> String {
            switch self {
            case .plain: "\(page)"
            case .slash: "\(page) / \(pages)"
            case .pageOf: "Page \(page) of \(pages)"
            case .dashed: "– \(page) –"
            }
        }
    }

    enum Keys {
        static let headerEnabled = "print.header.enabled"
        static let headerLeft = "print.header.left"
        static let headerCenter = "print.header.center"
        static let headerRight = "print.header.right"
        static let footerEnabled = "print.footer.enabled"
        static let footerLeft = "print.footer.left"
        static let footerCenter = "print.footer.center"
        static let footerRight = "print.footer.right"
        static let pageNumberStyle = "print.pageNumberStyle"
    }

    static let defaults: [String: Any] = [
        Keys.headerEnabled: true,
        Keys.headerLeft: "{title}",
        Keys.headerCenter: "",
        Keys.headerRight: "{date}",
        Keys.footerEnabled: true,
        Keys.footerLeft: "",
        Keys.footerCenter: "{page}",
        Keys.footerRight: "",
        Keys.pageNumberStyle: PageNumberStyle.slash.rawValue,
    ]

    /// Values substituted for the `{…}` tokens.
    struct Context {
        let title: String
        let file: String
        let date: String
        let time: String
    }

    var headerEnabled: Bool
    /// Left, center, right templates.
    var header: [String]
    var footerEnabled: Bool
    var footer: [String]
    var pageNumberStyle: PageNumberStyle

    static var current: PrintOptions {
        let store = UserDefaults.standard
        store.register(defaults: defaults)
        return PrintOptions(
            headerEnabled: store.bool(forKey: Keys.headerEnabled),
            header: [Keys.headerLeft, Keys.headerCenter, Keys.headerRight].map { store.string(forKey: $0) ?? "" },
            footerEnabled: store.bool(forKey: Keys.footerEnabled),
            footer: [Keys.footerLeft, Keys.footerCenter, Keys.footerRight].map { store.string(forKey: $0) ?? "" },
            pageNumberStyle: PageNumberStyle(rawValue: store.string(forKey: Keys.pageNumberStyle) ?? "") ?? .slash
        )
    }

    func expand(_ template: String, page: Int, pages: Int, context: Context) -> String {
        template
            .replacingOccurrences(of: "{title}", with: context.title)
            .replacingOccurrences(of: "{file}", with: context.file)
            .replacingOccurrences(of: "{page}", with: pageNumberStyle.format(page: page, pages: pages))
            .replacingOccurrences(of: "{pages}", with: "\(pages)")
            .replacingOccurrences(of: "{date}", with: context.date)
            .replacingOccurrences(of: "{time}", with: context.time)
    }
}
