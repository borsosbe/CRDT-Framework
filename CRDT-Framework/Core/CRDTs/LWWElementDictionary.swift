//
//  LWWElementDictionary.swift
//  CRDT-Framework
//
//  Created by Bence Borsos on 2022. 11. 12..
//

import Foundation

/// Grow-Only-Dictionary using`DictionaryElement`.
///
/// Bulding block for `LWWElementDictionary`.
public struct LWWElementDictionary<K: Hashable, V: Equatable> {
    private let biasedTowardsAdd: Bool
    private var addDictionary = GDictionary<K,V>(dictionary: [:])
    private var removeDictionary = GDictionary<K,V>(dictionary: [:])
    
    /// Init  `LWWElementDictionary`.
    ///
    /// - Parameter biasedTowardsAdd: ecided which way the LWW-Element-Dictionary is biased on exact timestapms -> add or remove
    public init(biasedTowardsAdd: Bool = true) {
        self.biasedTowardsAdd = biasedTowardsAdd
    }
    
    /// Returns a `DictionaryElement` if there is a valid element to the given key.
    ///
    /// To be a valid element (if exists) timestamp should be higher than the one in the removeDic (if exists).
    /// - Parameter key: The key to look up.
    /// - Returns: The `DictionaryElement` for the key or `nil`.
    public func lookup(key: K) -> DictionaryElement<V>? {
        if let addedElement = addDictionary.lookup(key: key) {
            if let removedElement = removeDictionary.lookup(key: key) {
                if biasedTowardsAdd {
                    if addedElement.timestamp >= removedElement.timestamp {
                        return addedElement
                    }
                } else {
                    if addedElement.timestamp > removedElement.timestamp {
                        return addedElement
                    } 
                }
                return nil
            }
            return addedElement
        }
        return nil
    }
    
    /// Adds an item to the `addDictionary` with the current system time if timestamp is not provided.
    ///
    /// - Parameters:
    ///   - key: The  key  to be added to the `addDictionary`.
    ///   - value: The value for the given key that to be added to the `addDictionary`.
    ///   - timestamp: The timestamp when the item is added. Not mandatory parameter. Default is the current system time.
    public mutating func add(key: K, value: V, timestamp: TimeInterval = Date().timeIntervalSinceNow) {
        self.addDictionary.add(key: key, value: value, timestamp: timestamp)
    }
    
    /// Adds an item to the `removeDictionary` with the current system time if timestamp is not provided.
    ///
    /// - Parameters:
    ///   - key: The  key  to be added to the `removeDictionary`.
    ///   - value: The value for the given key that to be added to the `removeDictionary`.
    ///   - timestamp: The timestamp when the item is added. Not mandatory parameter. Default is the current system time.
    public mutating func remove(key: K, timestamp: TimeInterval = Date().timeIntervalSinceNow) {
        guard let addedElement = addDictionary.lookup(key: key), timestamp >= addedElement.timestamp else { return }
        self.removeDictionary.add(key: key, value: addedElement.element, timestamp: timestamp)
    }
    
    /// Merge a `GDictionary` into self if param dictionary has elements.
    ///
    /// Calls the merge function of `GDictionary`  on add `addDictionary` and `removeDictionary`.
    ///
    /// - Parameters:
    ///   - dictionary: The dictionary that should be merged into self.
    public mutating func merge(anotherDictionary: LWWElementDictionary<K,V>?) {
        self.addDictionary.merge(anotherDictionary: anotherDictionary?.addDictionary)
        self.removeDictionary.merge(anotherDictionary: anotherDictionary?.removeDictionary)
    }
    
    ///     Compare a LWWElementDictionary with self.
    ///
    ///     Check if both `addDictionary` and `removeDictionary` is a subset of the other `addDictionary` and  `removeDictionary` with `GDictionary`'s compare method.
    ///
    ///     - Parameter anotherDictionary: The other dictionary
    ///     - Returns:
    ///         Wheter this dictionary is a subset of the other
    public func compare(anotherDictionary: LWWElementDictionary<K,V>?) -> Bool {
        guard anotherDictionary != nil else { return false }
        return (addDictionary.compare(anotherDictionary: anotherDictionary?.addDictionary)) && (removeDictionary.compare(anotherDictionary: anotherDictionary?.removeDictionary))
    }
}
