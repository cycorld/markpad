import XCTest
@testable import MarkPad

final class GitHubReleaseTests: XCTestCase {
    func testDecodeGitHubReleaseJSON() throws {
        let json = """
        {
          "tag_name": "v0.3.0",
          "name": "MarkPad 0.3.0",
          "html_url": "https://github.com/cycorld/markpad/releases/tag/v0.3.0",
          "published_at": "2026-10-02T12:00:00Z",
          "prerelease": false,
          "draft": false,
          "body": "## What's Changed\\n* Added automatic update checker with GitHub Releases SSOT.",
          "assets": [
            {
              "id": 123456,
              "name": "MarkPad-v0.3.0.zip",
              "size": 4805436,
              "browser_download_url": "https://github.com/cycorld/markpad/releases/download/v0.3.0/MarkPad-v0.3.0.zip",
              "content_type": "application/zip"
            },
            {
              "id": 123457,
              "name": "SHA256SUMS.txt",
              "size": 85,
              "browser_download_url": "https://github.com/cycorld/markpad/releases/download/v0.3.0/SHA256SUMS.txt",
              "content_type": "text/plain"
            }
          ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let release = try decoder.decode(GitHubRelease.self, from: json)

        XCTAssertEqual(release.tagName, "v0.3.0")
        XCTAssertEqual(release.name, "MarkPad 0.3.0")
        XCTAssertEqual(release.displayTitle, "MarkPad 0.3.0")
        XCTAssertEqual(release.htmlURL.absoluteString, "https://github.com/cycorld/markpad/releases/tag/v0.3.0")
        XCTAssertEqual(release.version, SemanticVersion("0.3.0"))
        XCTAssertFalse(release.prerelease)
        XCTAssertFalse(release.draft)
        XCTAssertEqual(release.assets.count, 2)

        let zipAsset = release.appZipAsset
        XCTAssertNotNil(zipAsset)
        XCTAssertEqual(zipAsset?.name, "MarkPad-v0.3.0.zip")
        XCTAssertEqual(zipAsset?.browserDownloadURL.absoluteString, "https://github.com/cycorld/markpad/releases/download/v0.3.0/MarkPad-v0.3.0.zip")
    }

    func testFallbackToTagNameWhenNameEmpty() throws {
        let json = """
        {
          "tag_name": "v0.2.2",
          "html_url": "https://github.com/cycorld/markpad/releases/tag/v0.2.2",
          "prerelease": false,
          "draft": false,
          "assets": []
        }
        """.data(using: .utf8)!

        let release = try JSONDecoder().decode(GitHubRelease.self, from: json)
        XCTAssertEqual(release.displayTitle, "v0.2.2")
        XCTAssertNil(release.appZipAsset)
    }
}
