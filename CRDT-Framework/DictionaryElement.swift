//
//  DictionaryElement.swift
//  CRDT-Framework
//
//  Created by Bence Borsos on 2022. 11. 12..
//

import Foundation

// MARK: Element for LWW-Element-Dictionary
// LWW-Element-Dictionary attaches a timestamp to each element (rather than to the whole dictionary)

public struct DictionaryElement<T> {
    public let element: T
    public let timestamp: TimeInterval
    
    init(element: T, timestamp: TimeInterval = Date().timeIntervalSinceNow) {
        self.element = element
        self.timestamp = timestamp
    }
}
