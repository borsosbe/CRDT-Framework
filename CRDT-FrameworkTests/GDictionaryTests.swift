//
//  GDictionaryTests.swift
//  CRDT-FrameworkTests
//
//  Created by Bence Borsos on 2022. 11. 14..
//

import XCTest
import CRDT_Framework

// Approach
// Naming Structure: test_UnitOfWork_StateUnderTest_ExpectedBehavior
// Naming Structure: test_[struct or class]_[variable or function]_[expected result]
// Testing Structure: Given, When, Then

final class GDictionaryTests: XCTestCase {
    var sut: GDictionary<String, Int>! // System Under Test
    
    override func setUp() {
        sut = GDictionary(dictionary: [:])
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_LWWElementDictionary_addFunction_Works() {
        // given
        let expectation1 = XCTestExpectation(description: "add function add element to GDictionary")
        let expectation2 = XCTestExpectation(description: "element should be updated if its get a higher timestamp")
        let expectation3 = XCTestExpectation(description: "element should not be updated if its get a lower timestamp")
        let expectation4 = XCTestExpectation(description: "element should not be found if not added")
        // when
        sut.add(key: "dog", value: 3, timestamp: 1)
        sut.add(key: "dog", value: 3, timestamp: 2)
        sut.add(key: "dog", value: 3, timestamp: 1)
        // then
        XCTAssertEqual(sut.lookup(key: "dog")?.element, 3, "expectation1 -> DictionaryElement element propery should be equal to the added value: 3 with the key: 'dog'")
        expectation1.fulfill()
        XCTAssertEqual(sut.lookup(key: "dog")?.timestamp, 2, "expectation2 -> timestamp should be: 2 for key: 'dog'")
        XCTAssertEqual(sut.lookup(key: "dog")?.element, 3, "expectation2 -> element value should not be chaned still: 3'")
        expectation2.fulfill()
        XCTAssertNotEqual(sut.lookup(key: "dog")?.timestamp, 1, "expectation3 -> timestamp should not be: 1 for key: 'dog'")
        expectation3.fulfill()
        XCTAssertNil(sut.lookup(key: "lion"), "expectation4 -> liob should not be here")
        expectation4.fulfill()
    }
    
    func test_LWWElementDictionary_updateFunction_Works() {
        // given
        let expectation1 = XCTestExpectation(description: "update function update and already existing DictionaryElement")
        let expectation2 = XCTestExpectation(description: "expect DictionaryElement not be updated if the timestamp is is not older")
        sut.add(key: "dog", value: 1)
        sut.add(key: "cat", value: 1, timestamp: 1)
        // when
        sut.update(key: "dog", value: 2)
        sut.update(key: "cat", value: 2, timestamp: 0)
        // then
        XCTAssertEqual(sut.lookup(key: "dog")?.element, 2, "expectation1 -> DictionaryElement element 'dog' should be equal to the updated value: 2")
        expectation1.fulfill()
        XCTAssertEqual(sut.lookup(key: "cat")?.element, 1, "expectation2 -> DictionaryElement element 'cat' should be equal to the base value: 1")
        expectation2.fulfill()
    }
    
    func test_LWWElementDictionary_compareFunction_Works() {
        // given
        let expectation = XCTestExpectation(description: "compare function decides if a dictionary is a subset of the other")
        var sut2 = GDictionary<String, Int>(dictionary: [:])
        let emptySut = GDictionary<String, Int>(dictionary: [:])
        sut.add(key: "dog", value: 1, timestamp: 0)
        sut.add(key: "cat", value: 2, timestamp: 1)
        sut.add(key: "fish", value: 3, timestamp: 0)
        // when
        sut2.add(key: "cat", value: 2, timestamp: 0)
        sut2.add(key: "fish", value: 3, timestamp: 1)
        // then
        XCTAssertTrue(sut.compare(anotherDictionary: sut), "sut should be subsets of self")
        XCTAssertTrue(emptySut.compare(anotherDictionary: sut), "emptySut should be subset of sut")
        XCTAssertFalse(sut.compare(anotherDictionary: sut2), "sut should not be a subset of sut2")
        XCTAssertTrue(sut2.compare(anotherDictionary: sut), "sut2 should be a subset of sut")
        sut2.update(key: "fish", value: 6, timestamp: 2)
        XCTAssertFalse(sut2.compare(anotherDictionary: sut), "sut2 should not be a subset of sut because for key:'fish' value has changed")
        expectation.fulfill()
    }
    
    func test_LWWElementDictionary_mergeFunction_Works() {
        // given
        let expectation = XCTestExpectation(description: "merge function merge into a dictionary an another")
        let expectation2 = XCTestExpectation(description: "merge is commutative, merging sut2 into sut should give the same results as merging sut into sut2")
        var sut2 = GDictionary<String, Int>(dictionary: [:])
        var tempSut = GDictionary<String, Int>(dictionary: [:])
        sut.add(key: "dog", value: 1, timestamp: 0)
        sut.add(key: "cat", value: 2, timestamp: 0)
        sut.add(key: "fish", value: 3, timestamp: 1)
        sut2.add(key: "cat", value: 2, timestamp: 1)
        sut2.add(key: "fish", value: 3, timestamp: 0)
        sut2.add(key: "lion", value: 66, timestamp: 2)
        tempSut = sut
        // when
        sut.merge(sut2)
        sut2.merge(tempSut)
        // then
        XCTAssertTrue(sut.lookup(key: "dog")?.element == 1, "item not in the merged dic should be unchanged")
        XCTAssertTrue(sut.lookup(key: "dog")?.timestamp == 0, "item not in the merged dic should be unchanged")
        XCTAssertTrue(sut.lookup(key: "cat")?.timestamp == 1, "item timestamp should be updated if the merged one was older")
        XCTAssertFalse(sut.lookup(key: "fish")?.timestamp == 0, "item timestamp should not be updated if the merged one was before")
        XCTAssertTrue(sut.lookup(key: "lion")?.element == 66, "new item 'lion' should be here because of the merge")
        XCTAssertFalse(sut.lookup(key: "fox") != nil, "no random item should not be presented which was not in either of them")
        expectation.fulfill()
        XCTAssertTrue(sut2.lookup(key: "dog")?.element == 1, "item not in the merged dic should be unchanged")
        XCTAssertTrue(sut2.lookup(key: "dog")?.timestamp == 0, "item not in the merged dic should be unchanged")
        XCTAssertTrue(sut2.lookup(key: "cat")?.timestamp == 1, "item timestamp should be updated if the merged one was older")
        XCTAssertFalse(sut2.lookup(key: "fish")?.timestamp == 0, "item timestamp should not be updated if the merged one was before")
        XCTAssertTrue(sut2.lookup(key: "lion")?.element == 66, "new item 'lion' should be here because of the merge")
        XCTAssertFalse(sut2.lookup(key: "fox") != nil, "no random item should not be presented which was not in either of them")
       expectation2.fulfill()
    }
}
