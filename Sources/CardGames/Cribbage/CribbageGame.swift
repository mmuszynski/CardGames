//
//  File.swift
//  
//
//  Created by Mike Muszynski on 8/18/20.
//

import Foundation
import CardDeck

public class CribbageGame: CardGame {
    typealias CardType = PlayingCard
    
    /// Reserved for making selections
    /// May be removed in favor of better UI selection
    public enum SelectionError: Error {
        case notEnoughCardsSelected
        case tooManyCardsSelected
    }
    
    ///Describes the next action that needs to happen in the game
    public enum GamePhase {
        case deal
        case discard
        case cut
        case pegging(for: CardGameSeat)
        case handCount(for: CardGameSeat)
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
    public var currentGamePhase: GamePhase = .deal
    
    /// A transcript of the rounds that have occurred in the game
    public var rounds = [CribbageGameRound]()
    
    public var hands: [CardGameSeat : Deck<PlayingCard>] = [.north : .empty, .south : .empty]
    public var currentNorthHand: Deck<PlayingCard> {
        get {
            return hands[.north] ?? PlayingCard.emptyDeck
        }
        set {
            hands[.north] = newValue
        }
    }
    public var currentSouthHand: Deck<PlayingCard> {
        get {
            return hands[.south] ?? PlayingCard.emptyDeck
        }
        set {
            hands[.south]  = newValue
        }
    }
    
    public var currentCrib = PlayingCard.emptyDeck
    public lazy var currentDealer: CardGameSeat = [.south, .north].randomElement()!
    
    public var selectedLeftHandCards = Set<PlayingCard>()
    public var selectedRightHandCards = Set<PlayingCard>()
    
    public var currentCutCard: PlayingCard?
    public var currentPegging: [PeggingPlay] = []
    
    var drawDeck = PlayingCard.fullDeck.shuffled()
    
    //deal new round
    func dealNewCards() {
        var newHands = [Deck<PlayingCard>](repeating: .empty, count: 2)
        drawDeck.deal(6, into: &newHands)
        self.currentNorthHand = currentDealer == .north ? newHands[1] : newHands[0]
        self.currentSouthHand = currentDealer == .north ? newHands[0] : newHands[1]
    }
    
    private func move(_ cards: Set<PlayingCard>, from: inout Deck<PlayingCard>, to: inout Deck<PlayingCard>) {
        from.removeAll(where: { cards.contains($0) })
        to.append(contentsOf: cards)
    }
    
    //send selected cards to crib
    func sendCardsToCrib(for seat: CardGameSeat) throws {
        if seat == .north {
            if selectedLeftHandCards.count > 2 {
                throw SelectionError.tooManyCardsSelected
            } else if selectedLeftHandCards.count < 2 {
                throw SelectionError.notEnoughCardsSelected
            }
            
            move(selectedLeftHandCards, from: &currentNorthHand, to: &currentCrib)
        } else {
            if selectedRightHandCards.count > 2 {
                throw SelectionError.tooManyCardsSelected
            } else if selectedRightHandCards.count < 2 {
                throw SelectionError.notEnoughCardsSelected
            }
            
            move(selectedRightHandCards, from: &currentSouthHand, to: &currentCrib)
        }
    }
    
    //cut
    func cutRandomCard() {
        self.currentCutCard = drawDeck.randomElement()
    }
    
    //pegging
    func pegSelectedCard(for seat: CardGameSeat) throws {
        var selected: PlayingCard!

        if seat == .north {
            if selectedLeftHandCards.count < 1 { throw SelectionError.notEnoughCardsSelected }
            if selectedLeftHandCards.count > 1 { throw SelectionError.tooManyCardsSelected }
            
            selected = selectedLeftHandCards.remove(selectedLeftHandCards.first!)
        } else {
            if selectedRightHandCards.count < 1 { throw SelectionError.notEnoughCardsSelected }
            if selectedRightHandCards.count > 1 { throw SelectionError.tooManyCardsSelected }
            
            selected = selectedRightHandCards.remove(selectedRightHandCards.first!)
        }
        
        let play = PeggingPlay(player: seat, play: .card(selected))
        currentPegging.append(play)
    }
    
    func declareGo(for seat: CardGameSeat) {
        currentPegging.append(PeggingPlay(player: seat, play: .go))
        
        if seat == .north {
            currentGamePhase = .pegging(for: .south)
        } else {
            currentGamePhase = .pegging(for: .north)
        }
    }
    
    //count
    //count crib
}
