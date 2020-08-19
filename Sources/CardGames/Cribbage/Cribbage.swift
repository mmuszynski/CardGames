import CardDeck

/// Cribbage definitions and rules
///
/// In Cribbage, the main goal is to make combinations of cards in your hand that satisfy various conditions in order to score points. In a standard game of cribbage, the goal is to score 121 points.
///
/// **Rules**
///
/// *Setup*
///
/// Each player is dealt six cards initially, and sends two to the dealer's "crib," thus creating three hands of four cards each. A final card, which acts as a communal card is cut from a random place in the remaining unused cards (if the cut card turns up a jack, this scores two points to the dealer).
///
/// *Pegging*
///
/// In this phase, the players alternately lay down cards, adding their value to a running count, scoring for various combinations of cards that have been laid down in order. For example, if a player lays down a card that makes the count reach exactly 15, he scores two points. Similarly, points are scored for runs and pairs, or for reaching the target count of 31.
///
/// Players must play a card on their turn so long as they will not exceed the target count of 31. Any player unable to do so declares that their opponent should "go." When neither player may go, the player who played the last card scores one point, in addition to any points they score for the cards they have played. Pegging ends when each player's hand has been exhausted.
///
/// *Scoring*
///
/// Hands are scored for combinations that produce points, starting with the player who did not deal and ending with the dealer's main hand and crib. See `score(hand:cutCard:crib:)` for a full list of scoring combinations.
///
struct Cribbage: CardGame {
    var minimumPlayerCount: Int { return 2 }
    
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
