import XCTest
@testable import Globals

final class GlobalsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Globals().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
