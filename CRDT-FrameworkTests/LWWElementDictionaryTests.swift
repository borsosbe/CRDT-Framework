//
//  LWWElementDictionaryTests.swift
//  CRDT-FrameworkTests
//
//  Created by Bence Borsos on 2022. 11. 12..
//

import XCTest
import CRDT_Framework

// MARK: Approach
// Naming Structure: test_UnitOfWork_StateUnderTest_ExpectedBehavior
// Naming Structure: test_[struct or class]_[variable or function]_[expected result]
// Testing Structure: Given, When, Then

final class LWWElementDictionaryTests: XCTestCase {
    var sut: LWWElementDictionary<Int, String>! // System Under Test
    
    override func setUp() {
        sut = LWWElementDictionary()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_LWWElementDictionary_addFunction_Works() throws {
        // given
        let expectation = XCTestExpectation(description: "add function add element to LWWElementDictionary")
        // when
        sut.add(key: 0, value: "zero")
        // then
        XCTAssertEqual(sut.lookup(value: "zero"), "zero")
        expectation.fulfill()
    }
    
    func test_LWWElementDictionary_removeFunction_Works() throws {
        // given
        let expectation1 = XCTestExpectation(description: "remove function remove element from LWWElementDictionary if its timestamp older")
        let expectation2 = XCTestExpectation(description: "remove function DO NOT remove element from LWWElementDictionary if its timestamp NOT older")
        sut.add(key: 0, value: "zero", timeStamp: 0)
        sut.add(key: 1, value: "one", timeStamp: 1)
        // when
        sut.remove(key: 0, timeStamp: 1)
        sut.remove(key: 1, timeStamp: 0)
        // then
        XCTAssertNil(sut.lookup(value: "zero"))
        expectation1.fulfill()
        XCTAssertEqual(sut.lookup(value: "one"), "one")
        expectation2.fulfill()
    }
    
    func test_LWWElementDictionary_mergeFunction_Works() throws {
        // given
        let expectation = XCTestExpectation(description: "merge two LWWElementDictionary. expercted result: cat, ape is an element, dog is not an element")
        var sut2 = LWWElementDictionary<Int,String>()
        // add 0-cat, 1-dog at timestamp 1, remove 0-cat at timestamp 3
        sut.add(key: 0, value: "cat", timeStamp: 1)
        sut.add(key: 1, value: "dog", timeStamp: 1)
        sut.remove(key: 0, timeStamp: 3)
        // add 0-cat timestamp 5, add 2-ape timestamp 1, remove 0-cat, 1-dog at timestamp 1
        sut2.add(key: 0, value: "cat", timeStamp: 5)
        sut2.add(key: 2, value: "ape", timeStamp: 1)
        sut2.remove(key: 0, timeStamp: 1)
        // when
        sut.merge(sut2)
        // then
        XCTAssertEqual(sut.lookup(value: "cat"), "cat")
        XCTAssertEqual(sut.lookup(value: "dog"), "dog")
        XCTAssertEqual(sut.lookup(value: "ape"), "ape")
        expectation.fulfill()
    }
    
    func test_LWWElementDictionary_mergeFucntion_Commutative() throws {
        // given
        let expectation = XCTestExpectation(description: "merge function is commutative. sut and sut2 will be the same regardless who is the merger")
        var sut2 = LWWElementDictionary<Int,String>()
        // add 0-cat
        sut.add(key: 0, value: "cat", timeStamp: 1)
        sut.add(key: 1, value: "dog", timeStamp: 1)
        sut.remove(key: 0, timeStamp: 3)
        // add 1-cat timestamp 5, add 2-ape timestamp 1, remove 0-cat, 1-dog at timestamp 1
        sut2.add(key: 0, value: "cat", timeStamp: 5)
        sut2.add(key: 2, value: "ape", timeStamp: 1)
        sut2.remove(key: 0, timeStamp: 1)
        // create tempSut to be able to merge with same statet both times
        let tempSut = sut
        // when
        sut.merge(sut2)
        sut2.merge(tempSut)
        // then
        XCTAssertEqual(sut.lookup(value: "cat"), "cat")
        XCTAssertEqual(sut.lookup(value: "dog"), "dog")
        XCTAssertEqual(sut.lookup(value: "ape"), "ape")
        
        XCTAssertEqual(sut2.lookup(value: "cat"), "cat")
        XCTAssertEqual(sut2.lookup(value: "dog"), "dog")
        XCTAssertEqual(sut2.lookup(value: "ape"), "ape")
        
        XCTAssertTrue(sut.compare(sut2))
        XCTAssertTrue(sut2.compare(sut))
        
        expectation.fulfill()
    }
}
