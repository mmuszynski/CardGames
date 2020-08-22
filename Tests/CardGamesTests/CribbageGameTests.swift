import XCTest
@testable import CardGames
@testable import CardDeck

private struct Player: CardGamePlayer {
    var uuid: UUID = UUID()
}

final class CribbageGameTests: XCTestCase {
    func testGameFlow() {
        let game = CribbageGame()
        game.dealNewCards()
        
        XCTAssertEqual(game.currentNorthHand.count, 6)
        XCTAssertEqual(game.currentSouthHand.count, 6)
        
        func tryToSendNoCards(for player: CardGameSeat) {
            do {
                try game.sendCardsToCrib(for: player)
                XCTFail("No error was produced for no cards selected")
            } catch CribbageGame.SelectionError.notEnoughCardsSelected {
                
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        func tryToSendTooManyCards(for player: CardGameSeat) {
            do {
                if player == .north {
                    game.selectedLeftHandCards = Set(game.currentNorthHand[0..<3])
                } else {
                    game.selectedRightHandCards = Set(game.currentSouthHand[0..<3])
                }
                try game.sendCardsToCrib(for: player)
                XCTFail("No error was produced for no cards selected")
            } catch CribbageGame.SelectionError.tooManyCardsSelected {
                
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        func doTheCribRight(for player: CardGameSeat) {
            if player == .north {
                game.selectedLeftHandCards = Set(game.currentNorthHand.shuffled()[0..<2])
            } else {
                game.selectedRightHandCards = Set(game.currentSouthHand.shuffled()[0..<2])
            }
            XCTAssertNoThrow(try game.sendCardsToCrib(for: player))
        }
        
        for player in [CardGameSeat.north, CardGameSeat.south] {
            tryToSendNoCards(for: player)
            tryToSendTooManyCards(for: player)
            doTheCribRight(for: player)
        }
    }
    
    func gameFlowUntilPegging() {
        let game = CribbageGame()
        game.currentNorthHand = ["4H", "5H", "6H", "6D", "7H", "10D"]
        game.currentSouthHand = ["AD", "2H", "2C", "QH", "6S", "JS"]
        game.drawDeck.removeAll { (game.currentSouthHand + game.currentNorthHand).contains($0) }
        
        game.selectedRightHandCards = Set(game.currentSouthHand[4..<6])
        game.selectedLeftHandCards = Set(game.currentNorthHand[4..<6])
        
        try! game.sendCardsToCrib(for: .north)
        try! game.sendCardsToCrib(for: .south)
        
        game.cutRandomCard()
        XCTAssertNotNil(game.currentCutCard)
        game.currentCutCard = "5S"
        
        game.selectedLeftHandCards = Set(game.currentNorthHand[0..<1])
        XCTAssertNoThrow(try game.pegSelectedCard(for: .north))
        XCTAssertEqual(game.currentNorthHand.count, 3)
        
        game.selectedRightHandCards = Set(game.currentSouthHand[0..<1])
        XCTAssertNoThrow(try game.pegSelectedCard(for: .south))
    }
    
}
