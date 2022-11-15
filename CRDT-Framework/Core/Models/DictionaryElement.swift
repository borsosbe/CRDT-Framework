//
//  DictionaryElement.swift
//  CRDT-Framework
//
//  Created by Bence Borsos on 2022. 11. 12..
//

import Foundation

/// Bulding block for  `GDictionary`.
public struct DictionaryElement<T> {
    public let element: T
    public let timestamp: TimeInterval
    
    init(element: T, timestamp: TimeInterval = Date().timeIntervalSinceNow) {
        self.element = element
        self.timestamp = timestamp
    }
}
