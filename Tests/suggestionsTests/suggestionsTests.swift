import XCTest
@testable import suggestions

final class suggestionsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(suggestions().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
