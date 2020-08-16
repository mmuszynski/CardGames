import XCTest
@testable import CardGames

final class CardGamesTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CardGames().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
