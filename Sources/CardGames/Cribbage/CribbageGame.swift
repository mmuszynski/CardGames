//
//  File.swift
//  
//
//  Created by Mike Muszynski on 8/18/20.
//

import Foundation
import CardDeck

class CribbageGame {
    enum SelectionError: Error {
        case notEnoughCardsSelected
        case tooManyCardsSelected
    }
    
    //Describes the next action that needs to happen
    enum GamePhase {
        case deal
        case discard
        case cut
        case pegging(for: CardGamePlayer)
        case handCount(for: CardGamePlayer)
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
    
    var currentGamePhase: GamePhase = .deal
    
    var rounds = [CribbageGameRound]()
    
    var left = CardGamePlayer()
    var right = CardGamePlayer()
    
    var currentLeftHand = PlayingCard.emptyDeck
    var currentRightHand = PlayingCard.emptyDeck
    var currentCrib = PlayingCard.emptyDeck
    var isLeftDealer: Bool = true
    
    var selectedLeftHandCards = Set<PlayingCard>()
    var selectedRightHandCards = Set<PlayingCard>()
    
    var currentCutCard: PlayingCard?
    
    enum PeggingPlay {
        case card(_ card: PlayingCard, player: CardGamePlayer)
        case go(player: CardGamePlayer)
    }
    var pegging: [PeggingPlay] = []
    
    var drawDeck = PlayingCard.fullDeck.shuffled()
    
    //deal new round
    func dealNewCards() {
        var hands: [Deck<PlayingCard>] = isLeftDealer ? [currentRightHand, currentLeftHand] : [currentLeftHand, currentRightHand]
        drawDeck.deal(4, into: &hands)
        self.currentLeftHand = isLeftDealer ? hands[1] : hands[0]
        self.currentRightHand = isLeftDealer ? hands[0] : hands[1]
    }
    
    private func move(_ cards: Set<PlayingCard>, from: inout Deck<PlayingCard>, to: inout Deck<PlayingCard>) {
        from.removeAll(where: { cards.contains($0) })
        to.append(contentsOf: cards)
    }
    
    //send selected cards to crib
    func sendCardsToCrib(for player: CardGamePlayer) throws {
        if player == left {
            if selectedLeftHandCards.count > 2 {
                throw SelectionError.tooManyCardsSelected
            } else if selectedLeftHandCards.count < 2 {
                throw SelectionError.notEnoughCardsSelected
            }
            
            move(selectedLeftHandCards, from: &currentLeftHand, to: &currentCrib)
        } else {
            if selectedRightHandCards.count > 2 {
                throw SelectionError.tooManyCardsSelected
            } else if selectedLeftHandCards.count < 2 {
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
    func pegSelectedCard(for player: CardGamePlayer) throws {
        var selected: PlayingCard!

        if player == left {
            if selectedLeftHandCards.count < 1 { throw SelectionError.notEnoughCardsSelected }
            if selectedLeftHandCards.count > 1 { throw SelectionError.tooManyCardsSelected }
            
            selected = selectedLeftHandCards.remove(selectedLeftHandCards.first!)
        } else {
            if selectedRightHandCards.count < 1 { throw SelectionError.notEnoughCardsSelected }
            if selectedRightHandCards.count > 1 { throw SelectionError.tooManyCardsSelected }
            
            selected = selectedRightHandCards.remove(selectedRightHandCards.first!)
        }
        
        let play = PeggingPlay.card(selected, player: player)
        pegging.append(play)
    }
    
    func declareGo(for player: CardGamePlayer) {
        pegging.append(.go(player: player))
        
        if player == left {
            currentGamePhase = .pegging(for: right)
        } else {
            currentGamePhase = .pegging(for: left)
        }
    }
    
    //count
    //count crib
}
