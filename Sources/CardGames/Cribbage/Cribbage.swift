import CardDeck

class Cribbage: CardGame {
    var minimumPlayerCount: Int { return 2 }
    
    static func score(_ hand: Deck<PlayingCard>, cutCard: PlayingCard, crib isCrib: Bool = false) -> Int {
        var count: Int = 0
        
        //look for nobs
        let jacks = hand.filter { $0.rank == .jack }
        if jacks.map(\.suit).contains(cutCard.suit) {
            count += 1
        }
        
        let handWithCut = hand + [cutCard]
        var countedRuns: [Set<PlayingCard>] = []
        
        for i in 0..<5 {
            let numCards = 5 - i
            let combinations = handWithCut.combinations(ofLength: numCards)
            
            //look for fifteens
            for cards in combinations {
                let sum = cards.reduce(0) { (result, card) -> Int in
                    result + Cribbage.numericValue(for: card)
                }
                if sum == 15 {
                    count += 2
                }
            }
            
            //look for pairs
            if numCards == 2 {
                for cards in combinations {
                    if cards[0].rank == cards[1].rank {
                        count += 2
                    }
                }
            }
            
            //look for runs
            for cards in combinations {
                if cards.isSequential {
                    let newSet = Set(cards)
                    if countedRuns.filter({ newSet.isSubset(of: $0) }).isEmpty {
                        countedRuns.append(newSet)
                    }
                }
            }
        }
        
        //sum up the run cards
        countedRuns = countedRuns.filter { $0.count > 2 }
        let runPoints = countedRuns.reduce(0, { $0 + $1.count })
        count += runPoints
        
        //check for a flush of five
        let hasFlushOfFive = Set(handWithCut.map(\.suit)).count == 1
        let hasFlushOfFour = Set(hand.map(\.suit)).count == 1
        if hasFlushOfFive {
            count += 5
        } else if hasFlushOfFour && !isCrib {
            count += 4
        }
        
        return count
    }
    
    static func numericValue(for card: PlayingCard) -> Int {
        switch card.rank {
        case .ace:
            return 1
        case .two:
            return 2
        case .three:
            return 3
        case .four:
            return 4
        case .five:
            return 5
        case .six:
            return 6
        case .seven:
            return 7
        case .eight:
            return 8
        case .nine:
            return 9
        case .ten, .jack, .queen, .king:
            return 10
        }
    }

}

extension Deck where Element == PlayingCard {
//    fileprivate func combinations(ofLength count: Int) -> [[Deck.Element]] {
//        return ArraySlice(self).combinations(ofLength: count)
//    }
    
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

extension ArraySlice {
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
