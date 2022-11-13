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
    public func lookup(value: V) -> V? {
        if let addedElement = addDictionary.lookup(value: value) {
            if let removedElement = removeDictionary.lookup(value: value) {
                if biasedTowardsAdd {
                    if addedElement.timestamp >= removedElement.timestamp {
                        return addedElement.element
                    }
                } else {
                    if addedElement.timestamp > removedElement.timestamp {
                        return addedElement.element
                    }
                }
                return nil
            }
            return addedElement.element
        }
        return nil
    }
    
    // MARK: Add
    public mutating func add(key: K, value: V, timeStamp: TimeInterval = Date().timeIntervalSinceNow) {
        self.addDictionary.add(key: key, value: value, timestamp: timeStamp)
    }
    
    // MARK: Remove
    public mutating func remove(key: K, timeStamp: TimeInterval = Date().timeIntervalSinceNow) {
        guard let addedElement = addDictionary.lookup(key: key), timeStamp >= addedElement.timestamp else { return }
        self.removeDictionary.add(key: key, value: addedElement.element, timestamp: timeStamp)
    }
    
    // MARK: Merge
    public mutating func merge(_ dictionary: LWWElementDictionary<K,V>?) {
        self.addDictionary.merge(dictionary?.addDictionary)
        self.removeDictionary.merge(dictionary?.removeDictionary)
    }
    
    ///     Compare a LWWElementDictionary with self.
    ///
    ///     Check if both addDictionary and removeDictionary  is a subset of the other addDictionary and  removeDictionary
    ///     - Parameter anotherDictionary: The other dictionary
    ///     - Returns: Wheter this dictionary is a subset of the other
        public func compare(_ anotherDictionary: LWWElementDictionary<K,V>?) -> Bool {
            guard anotherDictionary != nil else { return false }
            return addDictionary.compare(anotherDictionary?.addDictionary) && removeDictionary.compare(anotherDictionary?.removeDictionary)
        }
}
