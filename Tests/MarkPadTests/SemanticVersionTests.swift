import XCTest
@testable import MarkPad

final class SemanticVersionTests: XCTestCase {
    func testBasicVersionParsing() {
        let v1 = SemanticVersion("0.2.2")
        XCTAssertNotNil(v1)
        XCTAssertEqual(v1?.major, 0)
        XCTAssertEqual(v1?.minor, 2)
        XCTAssertEqual(v1?.patch, 2)
        XCTAssertNil(v1?.prerelease)
        XCTAssertNil(v1?.buildMetadata)
        XCTAssertEqual(v1?.description, "0.2.2")

        let v2 = SemanticVersion("v1.4.10")
        XCTAssertNotNil(v2)
        XCTAssertEqual(v2?.major, 1)
        XCTAssertEqual(v2?.minor, 4)
        XCTAssertEqual(v2?.patch, 10)
        XCTAssertEqual(v2?.description, "1.4.10")
    }

    func testPrereleaseAndBuildParsing() {
        let v1 = SemanticVersion("v1.0.0-beta.1")
        XCTAssertNotNil(v1)
        XCTAssertEqual(v1?.major, 1)
        XCTAssertEqual(v1?.minor, 0)
        XCTAssertEqual(v1?.patch, 0)
        XCTAssertEqual(v1?.prerelease, "beta.1")
        XCTAssertNil(v1?.buildMetadata)

        let v2 = SemanticVersion("2.0.0-rc.3+20261002")
        XCTAssertNotNil(v2)
        XCTAssertEqual(v2?.major, 2)
        XCTAssertEqual(v2?.minor, 0)
        XCTAssertEqual(v2?.patch, 0)
        XCTAssertEqual(v2?.prerelease, "rc.3")
        XCTAssertEqual(v2?.buildMetadata, "20261002")
    }

    func testInvalidVersions() {
        XCTAssertNil(SemanticVersion(""))
        XCTAssertNil(SemanticVersion("v"))
        XCTAssertNil(SemanticVersion("invalid"))
        XCTAssertNil(SemanticVersion("..."))
    }

    func testVersionComparisons() {
        let current = SemanticVersion("0.2.2")!

        XCTAssertTrue(current < SemanticVersion("0.2.3")!)
        XCTAssertTrue(current < SemanticVersion("0.3.0")!)
        XCTAssertTrue(current < SemanticVersion("1.0.0")!)
        XCTAssertTrue(current < SemanticVersion("v0.3.0")!)

        XCTAssertFalse(current < SemanticVersion("0.2.2")!)
        XCTAssertFalse(current < SemanticVersion("0.2.1")!)
        XCTAssertFalse(current < SemanticVersion("0.1.9")!)

        XCTAssertEqual(current, SemanticVersion("0.2.2")!)
        XCTAssertEqual(current, SemanticVersion("v0.2.2")!)

        // Prerelease comparison: normal release has higher precedence than prerelease
        let release = SemanticVersion("0.3.0")!
        let beta = SemanticVersion("0.3.0-beta.1")!
        XCTAssertTrue(beta < release)
        XCTAssertTrue(SemanticVersion("0.3.0-beta.1")! < SemanticVersion("0.3.0-beta.2")!)
    }
}
