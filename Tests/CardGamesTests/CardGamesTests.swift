import XCTest
@testable import CardGames
@testable import CardDeck

final class CardGamesTests: XCTestCase {
    func testInequality() {
        XCTAssertNotEqual(CardGamePlayer(), CardGamePlayer())
    }
    
}
