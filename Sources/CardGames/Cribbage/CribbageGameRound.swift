//
//  File.swift
//  
//
//  Created by Mike Muszynski on 8/18/20.
//

import Foundation
import CardDeck

/// A transcript of the game round
struct CribbageGameRound {
    var dealer: CardGamePlayer
    
    var leftHand: CribbageHand
    var rightHand: CribbageHand
    var cribHand: CribbageHand
    
    var peggingOrder: Array<PlayingCard>
}
