import Foundation

/// Models a GitHub Release payload from `https://api.github.com/repos/{owner}/{repo}/releases/latest`.
public struct GitHubRelease: Decodable, Equatable, Sendable {
    public let tagName: String
    public let name: String?
    public let body: String?
    public let htmlURL: URL
    public let publishedAt: String?
    public let prerelease: Bool
    public let draft: Bool
    public let assets: [GitHubReleaseAsset]

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name
        case body
        case htmlURL = "html_url"
        case publishedAt = "published_at"
        case prerelease
        case draft
        case assets
    }

    public init(
        tagName: String,
        name: String? = nil,
        body: String? = nil,
        htmlURL: URL,
        publishedAt: String? = nil,
        prerelease: Bool = false,
        draft: Bool = false,
        assets: [GitHubReleaseAsset] = []
    ) {
        self.tagName = tagName
        self.name = name
        self.body = body
        self.htmlURL = htmlURL
        self.publishedAt = publishedAt
        self.prerelease = prerelease
        self.draft = draft
        self.assets = assets
    }

    public var version: SemanticVersion? {
        SemanticVersion(tagName)
    }

    public var displayTitle: String {
        if let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }
        return tagName
    }

    /// Finds the application zip asset (e.g. `MarkPad-v0.2.2.zip`).
    public var appZipAsset: GitHubReleaseAsset? {
        assets.first { $0.name.lowercased().hasSuffix(".zip") && $0.name.lowercased().contains("markpad") }
            ?? assets.first { $0.name.lowercased().hasSuffix(".zip") }
    }
}

public struct GitHubReleaseAsset: Decodable, Equatable, Sendable {
    public let id: Int
    public let name: String
    public let size: Int
    public let browserDownloadURL: URL
    public let contentType: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case size
        case browserDownloadURL = "browser_download_url"
        case contentType = "content_type"
    }

    public init(id: Int, name: String, size: Int, browserDownloadURL: URL, contentType: String? = nil) {
        self.id = id
        self.name = name
        self.size = size
        self.browserDownloadURL = browserDownloadURL
        self.contentType = contentType
    }
}
