import XCTest
@testable import CardGames
@testable import CardDeck

private struct Player: CardGamePlayer {
    var uuid: UUID = UUID()
}

final class CribbageGameTests: XCTestCase {
    func testGameFlow() {
        let player1 = Player()
        let player2 = Player()
        let game = CribbageGame(leftPlayer: AnyCardGamePlayer(player1), rightPlayer: AnyCardGamePlayer(player2))
        game.dealNewCards()
        
        XCTAssertEqual(game.currentLeftHand.count, 6)
        XCTAssertEqual(game.currentRightHand.count, 6)
        
        func tryToSendNoCards(for player: AnyCardGamePlayer) {
            do {
                try game.sendCardsToCrib(for: player)
                XCTFail("No error was produced for no cards selected")
            } catch CribbageGame.SelectionError.notEnoughCardsSelected {
                
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        func tryToSendTooManyCards(for player: AnyCardGamePlayer) {
            do {
                if player == game.leftPlayer {
                    game.selectedLeftHandCards = Set(game.currentLeftHand[0..<3])
                } else {
                    game.selectedRightHandCards = Set(game.currentRightHand[0..<3])
                }
                try game.sendCardsToCrib(for: player)
                XCTFail("No error was produced for no cards selected")
            } catch CribbageGame.SelectionError.tooManyCardsSelected {
                
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        func doTheCribRight(for player: AnyCardGamePlayer) {
            if player == game.leftPlayer {
                game.selectedLeftHandCards = Set(game.currentLeftHand.shuffled()[0..<2])
            } else {
                game.selectedRightHandCards = Set(game.currentRightHand.shuffled()[0..<2])
            }
            XCTAssertNoThrow(try game.sendCardsToCrib(for: player))
        }
        
        for player in [game.rightPlayer, game.leftPlayer] {
            tryToSendNoCards(for: player)
            tryToSendTooManyCards(for: player)
            doTheCribRight(for: player)
        }
    }
    
    func gameFlowUntilPegging() {
        let game = CribbageGame(leftPlayer: AnyCardGamePlayer(Player()), rightPlayer: AnyCardGamePlayer(Player()))
        game.currentLeftHand = ["4H", "5H", "6H", "6D", "7H", "10D"]
        game.currentRightHand = ["AD", "2H", "2C", "QH", "6S", "JS"]
        game.drawDeck.removeAll { (game.currentRightHand + game.currentLeftHand).contains($0) }
        
        game.selectedRightHandCards = Set(game.currentRightHand[4..<6])
        game.selectedLeftHandCards = Set(game.currentLeftHand[4..<6])
        
        try! game.sendCardsToCrib(for: game.leftPlayer)
        try! game.sendCardsToCrib(for: game.rightPlayer)
        
        game.cutRandomCard()
        XCTAssertNotNil(game.currentCutCard)
        game.currentCutCard = "5S"
        
        game.selectedLeftHandCards = Set(game.currentLeftHand[0..<1])
        XCTAssertNoThrow(try game.pegSelectedCard(for: game.leftPlayer))
        XCTAssertEqual(game.currentLeftHand.count, 3)
        
        game.selectedRightHandCards = Set(game.currentRightHand[0..<1])
        XCTAssertNoThrow(try game.pegSelectedCard(for: game.rightPlayer))
    }
    
}
