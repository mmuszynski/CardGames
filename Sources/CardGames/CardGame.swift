//
//  File.swift
//  
//
//  Created by Mike Muszynski on 8/18/20.
//

import Foundation

protocol CardGame {
    var minimumPlayerCount: Int { get }
    var maximumPlayerCount: Int { get }
}

extension CardGame {
    var maximumPlayerCount: Int {
        return minimumPlayerCount
    }
}
