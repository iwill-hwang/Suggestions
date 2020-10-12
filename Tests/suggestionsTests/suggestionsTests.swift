import XCTest
@testable import Suggestions

final class suggestionsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Suggestions().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
