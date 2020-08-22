import XCTest
@testable import CardGames
@testable import CardDeck

final class CribbageScoringTests: XCTestCase {
    func testSetup() {
    }
    
    func testNullHands() {
        let nullHand = CribbageHand(["AS", "3H", "8H", "9H"])
        XCTAssertEqual(nullHand.score(with: "JS"), 0)
    }
    
    func testNobs() {
        let nobsHand = CribbageHand(["AS", "3H", "8H", "JH"])
        XCTAssertEqual(nobsHand.score(with: "9H"), 1)
    }
    
    func testPairs() {
        let pairHand = CribbageHand(["AS", "3H", "8H", "9H"])
        XCTAssertEqual(pairHand.score(with: "9S"), 2)
    }
    
    func testRuns() {
        let runHand = CribbageHand(["AS", "3H", "8H", "9H"])
        XCTAssertEqual(runHand.score(with: "10S"), 3)
        
        let runOf4Hand = CribbageHand(["AS", "8H", "9H", "10H"])
        XCTAssertEqual(runOf4Hand.score(with: "JS"), 4)
        
        let runOf5Hand = CribbageHand(["QS", "8H", "9H", "10H"])
        XCTAssertEqual(runOf5Hand.score(with: "JS"), 5)
        
        let doubleRunOfThreeHand = CribbageHand(["7H", "9H", "9S", "10H"])
        XCTAssertEqual(doubleRunOfThreeHand.score(with: "JS"), 8)
        
        let doubleRunOfFourHand = CribbageHand(["8H", "9H", "9S", "10H"])
        XCTAssertEqual(doubleRunOfFourHand.score(with: "JS"), 10)
    }
    
    func testFifteens() {
        var fifteenHand = CribbageHand(["AS", "3H", "8H", "10H"])
        XCTAssertEqual(fifteenHand.score(with: "5S"), 2)
        
        fifteenHand = CribbageHand(["AS", "2H", "4H", "10H"])
        XCTAssertEqual(fifteenHand.score(with: "7S"), 2)
    }
    
    func testFlush() {
        let flush4Hand = CribbageHand(["AS", "3S", "8S", "9S"])
        let cribFlush4Hand = CribbageHand(["AS", "3S", "8S", "9S"], crib: true)
        XCTAssertEqual(flush4Hand.score(with: "JH"), 4)
        XCTAssertEqual(cribFlush4Hand.score(with: "JH"), 0)
        
        let flush5Hand = CribbageHand(["AS", "3S", "8S", "9S"])
        let cribFlush5Hand = CribbageHand(["AS", "3S", "8S", "9S"], crib: true)
        XCTAssertEqual(flush5Hand.score(with: "JS"), 5)
        XCTAssertEqual(cribFlush5Hand.score(with: "JS"), 5)
    }
    
    func test29() {
        let highestHand = CribbageHand(["5S", "5H", "5D", "JC"])
        XCTAssertEqual(highestHand.score(with: "5C"), 29)
    }
    
    static let allTests = [
        ("testExample", testSetup),
    ]
}
