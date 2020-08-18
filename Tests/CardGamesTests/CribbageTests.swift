import XCTest
@testable import CardGames
@testable import CardDeck

final class CardGamesTests: XCTestCase {
    func testSetup() {
    }
    
    func testNullHands() {
        let score0 = Cribbage.score(["AS", "3H", "8H", "9H"], cutCard: "JS")
        XCTAssertEqual(score0, 0)
    }
    
    func testNobs() {
        let score1 = Cribbage.score(["AS", "3H", "8H", "JH"], cutCard: "9H")
        XCTAssertEqual(score1, 1)
    }
    
    func testPairs() {
        let score2 = Cribbage.score(["AS", "3H", "8H", "9H"], cutCard: "9S")
        XCTAssertEqual(score2, 2)
    }
    
    func testRuns() {
        let runScore = Cribbage.score(["AS", "3H", "8H", "9H"], cutCard: "10S")
        XCTAssertEqual(runScore, 3)
        
        let runOf4 = Cribbage.score(["AS", "8H", "9H", "10H"], cutCard: "JS")
        XCTAssertEqual(runOf4, 4)
        
        let runOf5 = Cribbage.score(["QS", "8H", "9H", "10H"], cutCard: "JS")
        XCTAssertEqual(runOf5, 5)
        
        let doubleRunOf3 = Cribbage.score(["7H", "9H", "9S", "10H"], cutCard: "JS")
        XCTAssertEqual(doubleRunOf3, 8)
        
        let doubleRunOf4 = Cribbage.score(["8H", "9H", "9S", "10H"], cutCard: "JS")
        XCTAssertEqual(doubleRunOf4, 10)
    }
    
    func testFifteens() {
        var score = Cribbage.score(["AS", "3H", "8H", "10H"], cutCard: "5S")
        XCTAssertEqual(score, 2)
        
        score = Cribbage.score(["AS", "2H", "4H", "10H"], cutCard: "7S")
        XCTAssertEqual(score, 2)
    }
    
    func testFlush() {
        let flush4 = Cribbage.score(["AS", "3S", "8S", "9S"], cutCard: "JH")
        let cribFlush4 = Cribbage.score(["AS", "3S", "8S", "9S"], cutCard: "JH", crib: true)
        XCTAssertEqual(flush4, 4)
        XCTAssertEqual(cribFlush4, 0)
        
        let flush5 = Cribbage.score(["AS", "3S", "8S", "9S"], cutCard: "JS")
        let cribFlush5 = Cribbage.score(["AS", "3S", "8S", "9S"], cutCard: "JS", crib: true)
        XCTAssertEqual(flush5, 5)
        XCTAssertEqual(cribFlush5, 5)
    }
    
    func test29() {
        let score29 = Cribbage.score(["5S", "5H", "5D", "JC"], cutCard: "5C")
        XCTAssertEqual(score29, 29)
    }
    
    static var allTests = [
        ("testExample", testSetup),
    ]
}
