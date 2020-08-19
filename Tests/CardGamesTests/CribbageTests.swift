import XCTest
@testable import CardGames
@testable import CardDeck

final class CardGamesTests: XCTestCase {
    func testSetup() {
    }
    
    func testNullHands() {
        let nullHand = CribbageHand(["AS", "3H", "8H", "9H"], cut: "JS")
        XCTAssertEqual(nullHand.score, 0)
    }
    
    func testNobs() {
        let nobsHand = CribbageHand(["AS", "3H", "8H", "JH"], cut: "9H")
        XCTAssertEqual(nobsHand.score, 1)
    }
    
    func testPairs() {
        let pairHand = CribbageHand(["AS", "3H", "8H", "9H"], cut: "9S")
        XCTAssertEqual(pairHand.score, 2)
    }
    
    func testRuns() {
        let runHand = CribbageHand(["AS", "3H", "8H", "9H"], cut: "10S")
        XCTAssertEqual(runHand.score, 3)
        
        let runOf4Hand = CribbageHand(["AS", "8H", "9H", "10H"], cut: "JS")
        XCTAssertEqual(runOf4Hand.score, 4)
        
        let runOf5Hand = CribbageHand(["QS", "8H", "9H", "10H"], cut: "JS")
        XCTAssertEqual(runOf5Hand.score, 5)
        
        let doubleRunOfThreeHand = CribbageHand(["7H", "9H", "9S", "10H"], cut: "JS")
        XCTAssertEqual(doubleRunOfThreeHand.score, 8)
        
        let doubleRunOfFourHand = CribbageHand(["8H", "9H", "9S", "10H"], cut: "JS")
        XCTAssertEqual(doubleRunOfFourHand.score, 10)
    }
    
    func testFifteens() {
        var fifteenHand = CribbageHand(["AS", "3H", "8H", "10H"], cut: "5S")
        XCTAssertEqual(fifteenHand.score, 2)
        
        fifteenHand = CribbageHand(["AS", "2H", "4H", "10H"], cut: "7S")
        XCTAssertEqual(fifteenHand.score, 2)
    }
    
    func testFlush() {
        let flush4Hand = CribbageHand(["AS", "3S", "8S", "9S"], cut: "JH")
        let cribFlush4Hand = CribbageHand(["AS", "3S", "8S", "9S"], cut: "JH", crib: true)
        XCTAssertEqual(flush4Hand.score, 4)
        XCTAssertEqual(cribFlush4Hand.score, 0)
        
        let flush5Hand = CribbageHand(["AS", "3S", "8S", "9S"], cut: "JS")
        let cribFlush5Hand = CribbageHand(["AS", "3S", "8S", "9S"], cut: "JS", crib: true)
        XCTAssertEqual(flush5Hand.score, 5)
        XCTAssertEqual(cribFlush5Hand.score, 5)
    }
    
    func test29() {
        let highestHand = CribbageHand(["5S", "5H", "5D", "JC"], cut: "5C")
        XCTAssertEqual(highestHand.score, 29)
    }
    
    static var allTests = [
        ("testExample", testSetup),
    ]
}
