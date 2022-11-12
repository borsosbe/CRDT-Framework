//
//  LWWElementDictionary.swift
//  CRDT-Framework
//
//  Created by Bence Borsos on 2022. 11. 12..
//

import Foundation

public struct LWWElementDictionary<T>: Equatable {
    
    private let biasedTowardsAdd: Bool
   // private var addDictionary = 
    
    // MARK: Init -> should be decided which way the LWW-Element-Dictionary is biased
    public init(biasedTowardsAdd: Bool = true) {
        self.biasedTowardsAdd = biasedTowardsAdd
    }
    
    // MARK: Lookup
    
    // MARK: Add
    
    // MARK: Remove
    
    // MARK: Merge
    
}
