//
//  File.swift
//  
//
//  Created by Mike Muszynski on 8/18/20.
//

import Foundation

public protocol CardGamePlayer: Equatable {}

public struct AnyCardGamePlayer: CardGamePlayer {
    private let value: Any
    private let equals: (Any) -> Bool

    public init<T: Equatable>(_ value: T) {
        self.value = value
        self.equals = { ($0 as? T == value) }
    }
}

extension AnyCardGamePlayer: Equatable {
    static public func ==(lhs: AnyCardGamePlayer, rhs: AnyCardGamePlayer) -> Bool {
        return lhs.equals(rhs.value)
    }
}
