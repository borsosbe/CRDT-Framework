//
//  GDictionary.swift
//  CRDT-Framework
//
//  Created by Bence Borsos on 2022. 11. 12..
//

import Foundation

// MARK: Grow-only Dictionary - building block for LWW-Element-Dictionary

public struct GDictionary<K: Hashable, V: Equatable> {
    private var dictionary: [K : DictionaryElement<V>]
    
    public init(dictionary: [K : DictionaryElement<V>]) {
        self.dictionary = dictionary
    }

    public func lookup(key: K) -> DictionaryElement<V>? {
        return self.dictionary[key]
    }

    // MARK: Add
    public mutating func add(key: K, value: V, timestamp: TimeInterval = Date().timeIntervalSinceNow) {
        guard self.lookup(key: key) == nil else {
            self.update(key: key, value: value, timestamp: timestamp)
            return
        }
        self.dictionary[key] = DictionaryElement(element: value, timestamp: timestamp)
    }
    
    // MARK: Update
    // only update if param item exists and it's timestamp is greater than the previous
    public mutating func update(key: K, value: V, timestamp: TimeInterval = Date().timeIntervalSinceNow) {
        guard let element = self.lookup(key: key), timestamp >= element.timestamp else { return }
        self.dictionary[key] = DictionaryElement(element: value, timestamp: timestamp)
    }

    // MARK: Merge
    // merge if param dictionary has elements
    // if an element exits -> try to update, if not -> add
    public mutating func merge(_ gDictionary: GDictionary<K, V>?) {
        guard (gDictionary?.dictionary.isEmpty != nil) else { return }
        for (key, value) in gDictionary!.dictionary {
            if self.lookup(key: key) != nil {
                self.update(key: key, value: value.element, timestamp: value.timestamp)
            } else {
                add(key: key, value: value.element, timestamp: value.timestamp)
            }
        }
    }
    
///     Compare a Grow-Only-Dictionary with self.
///
///     Check if this dictionary is a subset of the other
///     - Parameter anotherDictionary: The other dictionary
///     - Returns: Wheter this dictionary is a subset of the other
    public func compare(anotherDictionary: GDictionary<K,V>?, trueIdentical: Bool = false) -> Bool {
        guard anotherDictionary != nil else { return false }
        return dictionary.allSatisfy {
            if trueIdentical {
                return anotherDictionary?.lookup(key: $0.key)?.element == $0.value.element
            } else {
                return anotherDictionary?.lookup(key: $0.key) != nil
            }
        }
    }
}
