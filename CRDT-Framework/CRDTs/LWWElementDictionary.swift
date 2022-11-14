//
//  LWWElementDictionary.swift
//  CRDT-Framework
//
//  Created by Bence Borsos on 2022. 11. 12..
//

import Foundation

public struct LWWElementDictionary<K: Hashable, V: Equatable> {
    private let biasedTowardsAdd: Bool
    private var addDictionary = GDictionary<K,V>(dictionary: [:])
    private var removeDictionary = GDictionary<K,V>(dictionary: [:])
    
    // MARK: Init
    // should be decided which way the LWW-Element-Dictionary is biased on exact timestapms
    public init(biasedTowardsAdd: Bool = true) {
        self.biasedTowardsAdd = biasedTowardsAdd
    }
    
    // MARK: Lookup
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
    
    // MARK: Add
    public mutating func add(key: K, value: V, timestamp: TimeInterval = Date().timeIntervalSinceNow) {
        self.addDictionary.add(key: key, value: value, timestamp: timestamp)
    }
    
    // MARK: Remove
    public mutating func remove(key: K, timestamp: TimeInterval = Date().timeIntervalSinceNow) {
        guard let addedElement = addDictionary.lookup(key: key), timestamp >= addedElement.timestamp else { return }
        self.removeDictionary.add(key: key, value: addedElement.element, timestamp: timestamp)
    }
    
    // MARK: Merge
    public mutating func merge(_ dictionary: LWWElementDictionary<K,V>?) {
        self.addDictionary.merge(dictionary?.addDictionary)
        self.removeDictionary.merge(dictionary?.removeDictionary)
    }
    
    ///     Compare a LWWElementDictionary with self.
    ///
    ///     Check if both addDictionary and removeDictionary  is a subset of the other addDictionary and  removeDictionary
    ///
    ///     - Parameter anotherDictionary: The other dictionary
    ///     - Parameter trueIdentical: Decides that in the removeDic even the values have to be the same or just the existence of the same keys is enough to be considered identical
    ///     - Returns: Wheter this dictionary is a subset of the other
    public func compare(anotherDictionary: LWWElementDictionary<K,V>?, trueIdentical: Bool = false) -> Bool {
        guard anotherDictionary != nil else { return false }
        return addDictionary.compare(anotherDictionary: anotherDictionary?.addDictionary) && removeDictionary.compare(anotherDictionary: anotherDictionary?.removeDictionary, trueIdentical: trueIdentical)
    }
}
