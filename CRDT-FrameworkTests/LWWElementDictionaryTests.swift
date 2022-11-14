//
//  LWWElementDictionaryTests.swift
//  CRDT-FrameworkTests
//
//  Created by Bence Borsos on 2022. 11. 12..
//

import XCTest
import CRDT_Framework

// Approach
// Naming Structure: test_UnitOfWork_StateUnderTest_ExpectedBehavior
// Naming Structure: test_[struct or class]_[variable or function]_[expected result]
// Testing Structure: Given, When, Then

final class LWWElementDictionaryTests: XCTestCase {
    var sut: LWWElementDictionary<String, Int>! // System Under Test
    
    override func setUp() {
        sut = LWWElementDictionary()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_LWWElementDictionary_addFunction_Works() {
        // given
        let expectation = XCTestExpectation(description: "add function add element to LWWElementDictionary")
        // when
        sut.add(key: "dog", value: 1)
        // then
        XCTAssertEqual(sut.lookup(key: "dog")?.element, 1, "element should be added")
        expectation.fulfill()
    }
    
    func test_LWWElementDictionary_removeFunction_Works() {
        // given
        let expectation1 = XCTestExpectation(description: "remove function remove element from LWWElementDictionary if the timestamp is older")
        let expectation2 = XCTestExpectation(description: "remove function DO NOT remove element from LWWElementDictionary if the timestamp is NOT older")
        sut.add(key: "dog", value: 1, timestamp: 0)
        sut.add(key: "cat", value: 2, timestamp: 1)
        // when
        sut.remove(key: "dog", timestamp: 1)
        sut.remove(key: "cat", timestamp: 0)
        // then
        XCTAssertNil(sut.lookup(key: "dog"), "element should be removed because of older remove timestamp")
        expectation1.fulfill()
        XCTAssertEqual(sut.lookup(key: "cat")?.element, 2, "element should not be removed because of older add timestamp")
        expectation2.fulfill()
    }
    
    func test_LWWElementDictionary_compare_Works() {
        // given
        let expectation = XCTestExpectation(description: "compare function decides if a LWWElementDictionary is a subset of the other")
        var sut2 =  LWWElementDictionary<String, Int>()
        let emptySut = LWWElementDictionary<String, Int>()
        sut.add(key: "dog", value: 1, timestamp: 0)
        sut.add(key: "cat", value: 2, timestamp: 1)
        sut.add(key: "fish", value: 1, timestamp: 0)
        sut.add(key: "lion", value: 23, timestamp: 0)
        sut.remove(key: "fish", timestamp: 1)
        sut.remove(key: "dog", timestamp: 1)
        // when
        sut2.add(key: "cat", value: 2, timestamp: 1)
        sut2.add(key: "fish", value: 2, timestamp: 2)
        sut2.remove(key: "fish", timestamp: 3)
        // then
        XCTAssertTrue(sut.compare(anotherDictionary: sut), "sut should be subsets of self")
        XCTAssertTrue(emptySut.compare(anotherDictionary: sut), "emptySut should be subset of sut")
        XCTAssertFalse(sut.compare(anotherDictionary: sut2), "sut should not be a subset of sut2")
        XCTAssertTrue(sut2.compare(anotherDictionary: sut, trueIdentical: false), "sut2 should be a subset of sut")
        XCTAssertFalse(sut2.compare(anotherDictionary: sut, trueIdentical: true), "sut2 should not be a true Subset of sut")
        sut2.add(key: "fish", value: 1, timestamp: 4)
        sut2.remove(key: "fish", timestamp: 5)
        XCTAssertTrue(sut2.compare(anotherDictionary: sut, trueIdentical: true), "sut2 now should be a true Subset of sut because even in removeDic they has the same values")
        expectation.fulfill()
    }
    
}
