//
//  File.swift
//  
//
//  Created by Mike Muszynski on 8/18/20.
//

import Foundation
import CardDeck

class CribbageGame {
    
    init(leftPlayer: AnyCardGamePlayer, rightPlayer: AnyCardGamePlayer) {
        self.leftPlayer = leftPlayer
        self.rightPlayer = rightPlayer
    }
    
    /// Reserved for making selections
    /// May be removed in favor of better UI selection
    enum SelectionError: Error {
        case notEnoughCardsSelected
        case tooManyCardsSelected
    }
    
    ///Describes the next action that needs to happen in the game
    enum GamePhase {
        case deal
        case discard
        case cut
        case pegging(for: AnyCardGamePlayer)
        case handCount(for: AnyCardGamePlayer)
        case cribCount
        
        var maxCardSelection: Int {
            switch self {
            case .discard:
                return 2
            case .pegging:
                return 1
            default:
                return 0
            }
        }
    }
    
    /// Holds the current phase of the game
    var currentGamePhase: GamePhase = .deal
    
    /// A transcript of the rounds that have occurred in the game
    var rounds = [CribbageGameRound]()
    
    /// The players for the game
    var leftPlayer: AnyCardGamePlayer
    var rightPlayer: AnyCardGamePlayer
    
    var currentLeftHand = PlayingCard.emptyDeck
    var currentRightHand = PlayingCard.emptyDeck
    var currentCrib = PlayingCard.emptyDeck
    var isLeftDealer: Bool = true
    
    var selectedLeftHandCards = Set<PlayingCard>()
    var selectedRightHandCards = Set<PlayingCard>()
    
    var currentCutCard: PlayingCard?
    var currentPegging: [PeggingPlay] = []
    
    var drawDeck = PlayingCard.fullDeck.shuffled()
    
    //deal new round
    func dealNewCards() {
        var hands: [Deck<PlayingCard>] = isLeftDealer ? [currentRightHand, currentLeftHand] : [currentLeftHand, currentRightHand]
        drawDeck.deal(6, into: &hands)
        self.currentLeftHand = isLeftDealer ? hands[1] : hands[0]
        self.currentRightHand = isLeftDealer ? hands[0] : hands[1]
    }
    
    private func move(_ cards: Set<PlayingCard>, from: inout Deck<PlayingCard>, to: inout Deck<PlayingCard>) {
        from.removeAll(where: { cards.contains($0) })
        to.append(contentsOf: cards)
    }
    
    //send selected cards to crib
    func sendCardsToCrib(for player: AnyCardGamePlayer) throws {
        if player == leftPlayer {
            if selectedLeftHandCards.count > 2 {
                throw SelectionError.tooManyCardsSelected
            } else if selectedLeftHandCards.count < 2 {
                throw SelectionError.notEnoughCardsSelected
            }
            
            move(selectedLeftHandCards, from: &currentLeftHand, to: &currentCrib)
        } else {
            if selectedRightHandCards.count > 2 {
                throw SelectionError.tooManyCardsSelected
            } else if selectedRightHandCards.count < 2 {
                throw SelectionError.notEnoughCardsSelected
            }
            
            move(selectedRightHandCards, from: &currentRightHand, to: &currentCrib)
        }
    }
    
    //cut
    func cutRandomCard() {
        self.currentCutCard = drawDeck.randomElement()
    }
    
    //pegging
    func pegSelectedCard(for player: AnyCardGamePlayer) throws {
        var selected: PlayingCard!

        if player == leftPlayer {
            if selectedLeftHandCards.count < 1 { throw SelectionError.notEnoughCardsSelected }
            if selectedLeftHandCards.count > 1 { throw SelectionError.tooManyCardsSelected }
            
            selected = selectedLeftHandCards.remove(selectedLeftHandCards.first!)
        } else {
            if selectedRightHandCards.count < 1 { throw SelectionError.notEnoughCardsSelected }
            if selectedRightHandCards.count > 1 { throw SelectionError.tooManyCardsSelected }
            
            selected = selectedRightHandCards.remove(selectedRightHandCards.first!)
        }
        
        let play = PeggingPlay.PlayType.card(selected).forPlayer(player)
        currentPegging.append(play)
    }
    
    func declareGo(for player: AnyCardGamePlayer) {
        currentPegging.append(PeggingPlay.PlayType.go.forPlayer(player))
        
        if player == leftPlayer {
            currentGamePhase = .pegging(for: rightPlayer)
        } else {
            currentGamePhase = .pegging(for: leftPlayer)
        }
    }
    
    //count
    //count crib
}
