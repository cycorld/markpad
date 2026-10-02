import XCTest
@testable import MarkPad

final class EditorModeTests: XCTestCase {
    func testEditorModeCases() {
        XCTAssertEqual(EditorMode.allCases.count, 2)
        XCTAssertEqual(EditorMode.plain.rawValue, "plain")
        XCTAssertEqual(EditorMode.wysiwyg.rawValue, "wysiwyg")
    }

    func testLabels() {
        XCTAssertEqual(EditorMode.plain.shortLabel, "Source")
        XCTAssertEqual(EditorMode.wysiwyg.shortLabel, "WYSIWYG")
        XCTAssertFalse(EditorMode.plain.label.isEmpty)
        XCTAssertFalse(EditorMode.wysiwyg.label.isEmpty)
        XCTAssertFalse(EditorMode.plain.symbol.isEmpty)
        XCTAssertFalse(EditorMode.wysiwyg.symbol.isEmpty)
    }

    func testStorageKey() {
        XCTAssertEqual(EditorMode.storageKey, "editorMode")
    }
}
