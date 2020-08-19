//
//  File.swift
//  
//
//  Created by Mike Muszynski on 8/18/20.
//

import Foundation
import CardDeck

struct CribbageHand {
    var deck: Deck<PlayingCard>
    var isCrib: Bool = false
    var cutCard: PlayingCard
    
    var fifteens: NestedSet<PlayingCard>
    var pairs: NestedSet<PlayingCard>
    var runs: NestedSet<PlayingCard>
    var flush: Set<PlayingCard>
    var nobs: Bool = false

    var score: Int {
        let runPoints = runs.reduce(0, { $0 + $1.count })
        let fifteenPoints = fifteens.count * 2
        let pairPoints = pairs.count * 2
        let flushPoints = flush.count
        let nobsPoints = nobs ? 1 : 0
        
        return runPoints + fifteenPoints + pairPoints + flushPoints + nobsPoints
    }
    
    init(_ cards: [PlayingCard], cut cutCard: PlayingCard, crib isCrib: Bool = false) {
        self.deck = Deck(cards)
        self.isCrib = isCrib
        self.cutCard = cutCard
        
        self.fifteens = []
        self.pairs = []
        self.runs = []
        self.flush = []
        
        let components = CribbageHand.scoringComponents(for: self)
        self.fifteens = components.fifteens
        self.pairs = components.pairs
        self.runs = components.runs
        self.flush = components.flush
        self.nobs = components.nobs
    }
    
    typealias NestedSet<T: Hashable> = Set<Set<T>>
    
    /// Scores a hand of Cribbage
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
    private static func scoringComponents(for hand: CribbageHand) -> (fifteens: NestedSet<PlayingCard>, pairs: NestedSet<PlayingCard>, runs: NestedSet<PlayingCard>, flush: Set<PlayingCard>, nobs: Bool) {
        var fifteens: NestedSet<PlayingCard> = []
        var pairs: NestedSet<PlayingCard> = []
        var runs: NestedSet<PlayingCard> = []
        var nobs: Bool = false
        var flush: Set<PlayingCard> = []
        
        let handWithCut = hand.deck + [hand.cutCard]

        //look for nobs
        let jacks = hand.deck.filter { $0.rank == .jack }
        nobs = jacks.map(\.suit).contains(hand.cutCard.suit)
        
        //check for a flush of five
        let hasFlushOfFive = Set(handWithCut.map(\.suit)).count == 1
        let hasFlushOfFour = Set(hand.deck.map(\.suit)).count == 1
        if hasFlushOfFive {
            flush = Set(handWithCut)
        } else if hasFlushOfFour && !hand.isCrib {
            flush = Set(hand.deck)
        }
        
        for i in 0..<5 {
            let numCards = 5 - i
            let combinations = handWithCut.combinations(ofLength: numCards)
            
            //look for fifteens in combinations of at least two cards
            if numCards > 1 {
                for cards in combinations {
                    let sum = cards.reduce(0) { (result, card) -> Int in
                        result + Cribbage.numericValue(for: card)
                    }
                    if sum == 15 {
                        fifteens.insert(Set(cards))
                    }
                }
            }
            
            //look for pairs in combinations of exactly two cards
            if numCards == 2 {
                for cards in combinations {
                    if cards[0].rank == cards[1].rank {
                        pairs.insert(Set(cards))
                    }
                }
            }
            
            //look for runs in combinations of at least three cards
            if numCards > 2 {
                for cards in combinations {
                    if cards.isSequential {
                        let newSet = Set(cards)
                        if runs.filter({ newSet.isSubset(of: $0) }).isEmpty {
                            runs.insert(newSet)
                        }
                    }
                }
            }
        }
        
        return (fifteens: fifteens, pairs: pairs, runs: runs, flush: flush, nobs: nobs)
    }
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
