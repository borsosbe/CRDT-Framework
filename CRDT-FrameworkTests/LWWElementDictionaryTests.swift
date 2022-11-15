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
        sut2.add(key: "fish", value: 1, timestamp: 2)
        sut2.remove(key: "fish", timestamp: 3)
        // then
        XCTAssertTrue(sut.compare(anotherDictionary: sut), "sut should be subsets of self")
        XCTAssertTrue(emptySut.compare(anotherDictionary: sut), "emptySut should be subset of sut")
        XCTAssertFalse(sut.compare(anotherDictionary: sut2), "sut should not be a subset of sut2")
        expectation.fulfill()
    }
    
    func test_LWWElementDictionary_merge_Works() {
        // given
        let expectation1 = XCTestExpectation(description: "merge another LWWElementDictionary into the caller LWWElementDictionary")
        let expectation2 = XCTestExpectation(description: "merge is commutative, merging sut2 into sut should give the same results as merging sut into sut2")
        let expectation3 = XCTestExpectation(description: "sut is biased towards add on equal timestamp")
        let expectation4 = XCTestExpectation(description: "sut2 is biased towards remove on equal timestamp")
        var sut2 =  LWWElementDictionary<String, Int>(biasedTowardsAdd: false)
        var tempSut = LWWElementDictionary<String, Int>()
        sut.add(key: "dog", value: 1, timestamp: 2)
        sut.add(key: "cat", value: 2, timestamp: 2)
        sut.add(key: "fish", value: 1, timestamp: 0)
        sut.add(key: "fox", value: 1, timestamp: 0)
        sut.remove(key: "fish", timestamp: 1)
        sut2.add(key: "dog", value: 1, timestamp: 0)
        sut2.add(key: "cat", value: 2, timestamp: 1)
        sut2.add(key: "fish", value: 6, timestamp: 2)
        sut2.add(key: "lion", value: 23, timestamp: 0)
        sut2.add(key: "fox", value: 10, timestamp: 1)
        sut2.remove(key: "dog", timestamp: 1)
        sut2.remove(key: "cat", timestamp: 2)
        sut2.remove(key: "fish", timestamp: 3)
        tempSut = sut
        // when
        sut.merge(anotherDictionary: sut2)
        sut2.merge(anotherDictionary: tempSut)
        // then
        XCTAssertTrue(sut.lookup(key: "fox")?.element == 10, "")
        
        XCTAssertTrue(sut.lookup(key: "dog")?.element == 1, "item not in the other dic should be unchanged")
        XCTAssertTrue(sut.lookup(key: "dog")?.element == 1, "item not in the other dic should be unchanged")
        XCTAssertNil(sut.lookup(key: "fish"), "The other dic removed item 'fish' with older timestamp than the origin added it, so it should be removed from sut")
        XCTAssertTrue(sut.lookup(key: "lion")?.element == 23, "item from the other dic should be present")
        expectation1.fulfill()
        XCTAssertTrue(sut2.lookup(key: "dog")?.element == 1, "item not in the merged dic should be unchanged")
        XCTAssertNil(sut2.lookup(key: "fish"), "The other dic removed item 'cat' with older timestamp than the origin added it, so it should be removed from sut")
        XCTAssertTrue(sut2.lookup(key: "lion")?.element == 23, "item from the other dic should be present")
        expectation2.fulfill()
        XCTAssertNotNil(sut.lookup(key: "cat"), "expectation3: -> cat should be here")
        expectation3.fulfill()
        XCTAssertNil(sut2.lookup(key: "cat"), "expectation4: -> cat should not be here")
        XCTAssertNotNil(sut2.lookup(key: "dog"), "expectation4: -> dog should be here because its added in sut after removed in sut2")
        expectation4.fulfill()
    }
    
}
