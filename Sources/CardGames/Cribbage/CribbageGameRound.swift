//
//  File.swift
//  
//
//  Created by Mike Muszynski on 8/18/20.
//

import Foundation
import CardDeck

/// A transcript of the game round
public struct CribbageGameRound {
    public var dealer: AnyCardGamePlayer
    
    public var leftHand: CribbageHand
    public var rightHand: CribbageHand
    public var cribHand: CribbageHand
    
    public var cutCard: PlayingCard
    
    var pegging: Array<PeggingPlay>
}

public struct PeggingPlay {
    public enum PlayType {
        case card(_ card: PlayingCard)
        case go
    }

    public var player: CardGameSeat
    public var play: PlayType
}
