//
//  GDictionary.swift
//  CRDT-Framework
//
//  Created by Bence Borsos on 2022. 11. 12..
//

import Foundation

/// Grow-Only-Dictionary using`DictionaryElement`.
///
/// Bulding block for `LWWElementDictionary`.
public struct GDictionary<K: Hashable, V: Equatable> {
    private var dictionary: [K : DictionaryElement<V>]
    
    /// Init `GDictionary` with the given dictionary otherwise with an empty dic.
    ///
    ///  - Parameter dictionary: The dictionary that will be initialized with the `GDictionary`.
    public init(dictionary: [K : DictionaryElement<V>] = [:]) {
        self.dictionary = dictionary
    }
    
    /// Returns the `DictionaryElement` which contains the element and the timestamp for the given key..
    ///
    /// - Parameter key: The key to look up.
    /// - Returns: The `DictionaryElement` for the key or `nil`.
    public func lookup(key: K) -> DictionaryElement<V>? {
        return self.dictionary[key]
    }

    /// Adds an item to the dictionary with the current system time if timestamp is not provided.
    ///
    /// - Parameters:
    ///   - key: The  key  to be added to the dictionary.
    ///   - value: The value for the given key that to be added to the dictionary.
    ///   - timestamp: The timestamp when the item is added. Not mandatory parameter. Default is the current system time.
    public mutating func add(key: K, value: V, timestamp: TimeInterval = Date().timeIntervalSinceNow) {
        guard self.lookup(key: key) == nil else {
            self.update(key: key, value: value, timestamp: timestamp)
            return
        }
        self.dictionary[key] = DictionaryElement(element: value, timestamp: timestamp)
    }
    
    /// Update an item on a specific key in dictionary with the current system time if timestamp is not provided.
    ///
    /// - Parameters:
    ///   - key: The  key  to be updated in the dictionary.
    ///   - value: The value for the given key that to be updated in the dictionary.
    ///   - timestamp: The timestamp when the item is added. Not mandatory parameter. Default is the current system time.
    /// - Warning:
    ///   - `DictionaryElement` is only updated when the passed timestamp is greater than the one in dictionary, and the given `key` exists.
    public mutating func update(key: K, value: V, timestamp: TimeInterval = Date().timeIntervalSinceNow) {
        guard let element = self.lookup(key: key), timestamp >= element.timestamp else { return }
        self.dictionary[key] = DictionaryElement(element: value, timestamp: timestamp)
    }

    /// Merge a `GDictionary` into self if param dictionary has elements
    ///
    /// If an element exits -> try to update, if not -> add
    ///
    /// - Parameters:
    ///   - anotherDictionary: The dictionary that should be merged into self.
    /// - Warning:
    ///   - `DictionaryElement` is only updated when the passed timestamp is greater than the one in dictionary, and the given `key` exists.
    public mutating func merge(anotherDictionary: GDictionary<K, V>?) {
        guard (anotherDictionary?.dictionary.isEmpty != nil) else { return }
        for (key, value) in anotherDictionary!.dictionary {
            if self.lookup(key: key) != nil {
                self.update(key: key, value: value.element, timestamp: value.timestamp)
            } else {
                add(key: key, value: value.element, timestamp: value.timestamp)
            }
        }
    }
    
    /// Check if this dictionary is a subset of the other.
    ///
    /// - Parameters:
    ///   - anotherDictionary: The other dictionary
    /// - Returns:
    ///    Wheter this dictionary is a subset of the other aka all elements of `anotherDictionary`can be found on the same keys.
    public func compare(anotherDictionary: GDictionary<K,V>?) -> Bool {
        guard anotherDictionary != nil else { return false }
        return dictionary.allSatisfy {
            return anotherDictionary!.lookup(key: $0.key)?.element == $0.value.element
        }
    }
}
