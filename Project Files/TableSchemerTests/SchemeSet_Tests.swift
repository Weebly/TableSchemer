//
//  SchemeSet_Tests.swift
//  TableSchemer
//
//  Created by James Richard on 6/15/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import XCTest
import TableSchemer

class SchemeSet_Tests: XCTestCase {
    // MARK: Initializers
    func testInitWithNameAndSchemes_setsSchemes() {
        let schemes = [Scheme()]
        let subject = SchemeSet(name: "Foo Bar", withSchemes: schemes)
        XCTAssert(subject.schemes == schemes)
    }

    func testInitWithSchemes_setsSchemes() {
        let schemes = [Scheme()]
        let subject = SchemeSet(schemes: schemes)
        XCTAssert(subject.schemes == schemes)
    }

    func testInitWithNameAndSchemes_setsName() {
        let subject: SchemeSet = SchemeSet(name: "Foo Bar", withSchemes: [Scheme()])
        XCTAssert(subject.name == "Foo Bar")
    }
    
    func testInitWithNameFooterTextAndSchemes_setsFooterText() {
        let subject: SchemeSet = SchemeSet(name: "Foo Bar", footerText: "Buzz", withSchemes: [Scheme()])
        XCTAssert(subject.footerText == "Buzz")
    }
    
    func testInitWithFooterTextAndSchemes_setsFooterText() {
        let subject: SchemeSet = SchemeSet(footerText: "Buzz", withSchemes: [Scheme()])
        XCTAssert(subject.footerText == "Buzz")
    }
    
    // MARK: Subscript Support
    func testSubscript_accessesSchemes() {
        let schemes = [Scheme()]
        let subject = SchemeSet(schemes: schemes)
        
        XCTAssert(subject[0] === schemes[0])
    }
    
    // MARK: Count
    func testCount_whenOneScheme_is1() {
        let schemes = [Scheme()]
        let subject = SchemeSet(schemes: schemes)
        
        XCTAssertEqual(subject.count, 1)
    }
    
    func testCount_whenTwoSchemes_is2() {
        let schemes = [Scheme(), Scheme()]
        let subject = SchemeSet(schemes: schemes)
        
        XCTAssertEqual(subject.count, 2)
    }
    
    // MARK: Visibility
    func testVisibleSchemes_onlyIncludeVisibleSchemes() {
        let scheme1 = Scheme()
        scheme1.hidden = true
        let scheme2 = Scheme()
        let schemes = [scheme1, scheme2]
        let subject = SchemeSet(schemes: schemes)
        XCTAssertEqual(subject.visibleSchemes, [scheme2])
    }
    
    // MARK: Equality
    func testSameInstances_areEqual() {
        let schemes = [Scheme()]
        let subject = SchemeSet(schemes: schemes)
        XCTAssertEqual(subject, subject)
    }
    
    func testDifferentInstances_withEqualProperties_areEqual() {
        let schemes = [Scheme()]
        let first = SchemeSet(name: "Foo", footerText: "Bar", withSchemes: schemes)
        let second = SchemeSet(name: "Foo", footerText: "Bar", withSchemes: schemes)
        XCTAssertEqual(first, second)
    }
    
    func testEquality_whenNameIsDifferent_isFalse() {
        let schemes = [Scheme()]
        let first = SchemeSet(name: "Foo", footerText: "Bar", withSchemes: schemes)
        let second = SchemeSet(name: "Fuz", footerText: "Bar", withSchemes: schemes)
        XCTAssertNotEqual(first, second)
    }
    
    func testEquality_whenFooterTextIsDifferent_isFalse() {
        let schemes = [Scheme()]
        let first = SchemeSet(name: "Foo", footerText: "Bar", withSchemes: schemes)
        let second = SchemeSet(name: "Foo", footerText: "Baz", withSchemes: schemes)
        XCTAssertNotEqual(first, second)
    }
    
    func testEquality_whenSchemesAreDifferent_isFalse() {
        let first = SchemeSet(name: "Foo", footerText: "Bar", withSchemes: [])
        let second = SchemeSet(name: "Foo", footerText: "Bar", withSchemes: [Scheme()])
        XCTAssertNotEqual(first, second)
    }
}
