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
    public let value: T
    public let timestamp: TimeInterval
    
    init(value: T, timestamp: TimeInterval = Date().timeIntervalSinceNow) {
        self.value = value
        self.timestamp = timestamp
    }
    
//    func equal(element: DictionaryElement<T>) -> Bool {
//        return self.value == element as? T
//    }
//    
//    public static func == (lhs: DictionaryElement<T>, rhs: DictionaryElement<T>) -> Bool {
//        guard lhs.value == rhs.value && lhs.timestamp == rhs.timestamp else {
//            return false
//        }
//        return true
//    }
//    public static func ==<K, V: Hashable, R: Hashable>(lhs: [K: V], rhs: [K: R] ) -> Bool {
//       (lhs as NSDictionary).isEqual(to: rhs)
//    }
//    public static func == (lhs: DictionaryElement<K, V>, rhs: DictionaryElement<K, V>) -> Bool {
//        return (lhs.element as NSDictionary).isEqual(to: rhs.element)
//    }
}
