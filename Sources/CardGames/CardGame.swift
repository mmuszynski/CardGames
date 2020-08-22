//
//  File.swift
//  
//
//  Created by Mike Muszynski on 8/18/20.
//

import Foundation
import CardDeck

protocol CardGame {
    associatedtype CardType: Card
    var hands: [CardGameSeat : Deck<CardType>] { get }
}

public enum CardGameSeat: Int {
    case north, northeast, east, southeast, south, southwest, west, northwest
}
