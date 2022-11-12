//
//  GDictionary.swift
//  CRDT-Framework
//
//  Created by Bence Borsos on 2022. 11. 12..
//

import Foundation

// MARK: Grow-only Dictionary
// building block for LWW-Element-Dictionary, supports operations lookup, add and merge

struct GDictionary<K: Hashable, V: Equatable> {
    private var dictionary: [K : DictionaryElement<V>]
    
    // MARK: Lookup
    public func lookup(value: V) -> V? {
        return self.dictionary.first(where: { $0.value.value == value })?.value as? V
    }

    // MARK: Add
    public mutating func add(key: K, value: V, timestamp: TimeInterval = Date().timeIntervalSinceNow) {
        self.dictionary[key] = DictionaryElement(value: value, timestamp: timestamp)
    }

    // MARK: Merge
    public mutating func merge<T>(_ gDictionary: GDictionary<T, V>?) where T: Hashable {
        guard gDictionary?.dictionary.keys.first is K && gDictionary?.dictionary.values.first is V else {
            return
        }
        for (key, value) in gDictionary!.dictionary {
            if let found = self.dictionary[key as! K] {
                if value.timestamp >= found.timestamp {
                    self.dictionary[key as! K] = value
                }
            }
            add(key: key as! K, value: value as! V)
        }
    }
}
