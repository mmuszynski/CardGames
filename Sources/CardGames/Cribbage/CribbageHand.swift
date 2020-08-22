//
//  File.swift
//  
//
//  Created by Mike Muszynski on 8/18/20.
//

import Foundation
import CardDeck

public struct CribbageHand {
    var deck: Deck<PlayingCard>
    public var isCrib: Bool = false
    
    private func cardCombinations(with cutCard: PlayingCard) -> Array<Deck<PlayingCard>> {
        var combinations = Array<Deck<PlayingCard>>()
        let handWithCut = deck + [cutCard]
        for i in 1...5 {
            combinations += handWithCut.combinations(ofLength: i)
        }
        
        return combinations
    }
    
    public func fifteens(with cutCard: PlayingCard) -> Array<Deck<PlayingCard>> {
        //look for fifteens in combinations of at least two cards
        let fifteens = cardCombinations(with: cutCard).filter { (cards) -> Bool in
            let sum = cards.reduce(0) { (result, card) -> Int in
                result + CribbageGame.numericValue(for: card)
            }
            return sum == 15
        }
        
        return fifteens
    }
    
    public func pairs(with cutCard: PlayingCard) -> Array<Deck<PlayingCard>> {
        return cardCombinations(with: cutCard).filter { $0.count == 2 }.filter({ Set($0.map(\.rank)).count == 1 })
    }
    
    public func runs(with cutCard: PlayingCard) -> Set<Set<PlayingCard>> {
        //look for runs in combinations of at least three cards
        var runs = Set<Set<PlayingCard>>()
        let setsPlus = cardCombinations(with: cutCard).filter { $0.count > 2 }.sorted(by: { $1.count < $0.count })
        
        for cards in setsPlus {
            if cards.isSequential {
                let newSet = Set(cards)
                if runs.filter({ newSet.isSubset(of: $0) }).isEmpty {
                    runs.insert(newSet)
                }
            }
        }
        
        return runs
    }
    
    public func flush(with cutCard: PlayingCard) -> Set<PlayingCard> {
        let hand = self.deck
        let handWithCut = hand + [cutCard]
        
        //check for a flush of five
        let hasFlushOfFive = Set(handWithCut.map(\.suit)).count == 1
        let hasFlushOfFour = Set(hand.map(\.suit)).count == 1
        if hasFlushOfFive {
            return Set(handWithCut)
        } else if hasFlushOfFour && !self.isCrib {
            return Set(hand)
        }
        
        return []
    }
    
    public func hasNobs(with cutCard: PlayingCard) -> Bool {
        let jacks = self.deck.filter { $0.rank == .jack }
        return jacks.map(\.suit).contains(cutCard.suit)
    }

    public func score(with cutCard: PlayingCard) -> Int {
        let runPoints = runs(with: cutCard).reduce(0, { $0 + $1.count })
        let fifteenPoints = fifteens(with: cutCard).count * 2
        let pairPoints = pairs(with: cutCard).count * 2
        let flushPoints = flush(with: cutCard).count
        let nobsPoints = self.hasNobs(with: cutCard) ? 1 : 0
        
        return runPoints + fifteenPoints + pairPoints + flushPoints + nobsPoints
    }
    
    public init(_ cards: [PlayingCard], crib isCrib: Bool = false) {
        self.deck = Deck(cards)
        self.isCrib = isCrib
    }
    
    public typealias NestedSet<T: Hashable> = Set<Set<T>>
    
    /// Sorts out the scoring components for a hand of cribbage
    ///
    /// Iterates through all combinations of cards, looking for those that satsify scoring conditions as follows:
    ///
    /// - Cards whose value sum to 15: 2 points
    /// - Pairs: 2 points
    /// - Runs (e.g. 3, 4, 5): points equivalent to run length
    /// - Held flush: 4 points (only available in held hand) or 5 if cut card can be included
    /// - Crib flush: 5 points (must include cut card)
    /// - His Nobs: one point for holding the jack with the same suit as the cut card
    ///
    /// - Parameters:
    ///   - hand: A `Deck` of `PlayingCard` objects representing a player's hand
    ///   - cutCard: The `PlayingCard` selected as the communal cut card
    ///   - isCrib: True if this represents the player's crib cards
    /// - Returns: Scoring components
}

internal extension Deck where Element == PlayingCard {
    var isSequential: Bool {
        let ordered = self.map(\.rank).sorted(by: { card1, card2 in
            let ranks = PlayingCard.Rank.defaultOrder
            return ranks.firstIndex(of: card1) ?? 0 < ranks.firstIndex(of: card2) ?? 0
        })
        let count = self.count
        
        let ranks = PlayingCard.Rank.defaultOrder
        guard let lowest = ordered.first, let lowestIndex = ranks.firstIndex(of: lowest) else { return false }
        let highest = lowestIndex + count
        guard highest < ranks.count else { return false }
        
        let setA = Set(ranks[lowestIndex..<lowestIndex+count])
        let setB = Set(ordered)
        
        return setA == setB
    }
    
    func combinations(ofLength length: Int) -> [Deck<Element>] {
        if(self.count == length) {
            return [self]
        }

        if(self.isEmpty) {
            return []
        }

        if(length == 0) {
            return []
        }

        if(length == 1) {
            return self.map { [$0] }
        }

        var result : [Deck<Element>] = []

        let rest = Deck(self.suffix(from: 1))
        let subCombos = rest.combinations(ofLength: length - 1)
        result += subCombos.map { [self[0]] + $0 }
        result += rest.combinations(ofLength: length)
        return result
    }
}

internal extension ArraySlice {
    //https://stackoverflow.com/questions/25162500/apple-swift-generate-combinations-with-repetition
    fileprivate func combinations(ofLength count: Int) -> [Array<Element>] {
        if count == 0 {
            return [[]]
        }
        
        guard let first = self.first else {
            return []
        }
        
        let head = [first]
        let subcombos = self.combinations(ofLength: count - 1)
        var ret = subcombos.map { head + $0 }
        ret += self.dropFirst().combinations(ofLength: count)
        
        return ret
    }
}
