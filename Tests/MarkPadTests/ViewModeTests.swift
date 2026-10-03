import XCTest
@testable import MarkPad

final class ViewModeTests: XCTestCase {
    func testViewModeCases() {
        XCTAssertEqual(ViewMode.allCases.count, 3)
        XCTAssertEqual(ViewMode.editor.rawValue, "editor")
        XCTAssertEqual(ViewMode.split.rawValue, "split")
        XCTAssertEqual(ViewMode.preview.rawValue, "preview")
    }

    func testLabels() {
        XCTAssertEqual(ViewMode.editor.label, "Editor")
        XCTAssertEqual(ViewMode.split.label, "Split")
        XCTAssertEqual(ViewMode.preview.label, "Preview")
    }

    func testSymbols() {
        XCTAssertEqual(ViewMode.editor.symbol, "rectangle.leadinghalf.filled")
        XCTAssertEqual(ViewMode.split.symbol, "rectangle.split.2x1")
        XCTAssertEqual(ViewMode.preview.symbol, "rectangle.trailinghalf.filled")
    }

    func testStorageKeys() {
        XCTAssertEqual(ViewMode.storageKey, "viewMode")
        XCTAssertEqual(ViewMode.defaultViewModeKey, "defaultViewMode")
    }
}
