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
    func testInitWithNameFooterTextAndSchemes_setsSchemes() {
        let schemes = [Scheme()]
        let subject = SchemeSet(name: "Foo Bar", footerText: nil, withSchemes: schemes)
        XCTAssert(subject.schemes == schemes)
    }

    func testInitWithSchemes_setsSchemes() {
        let schemes = [Scheme()]
        let subject = SchemeSet(schemes: schemes)
        XCTAssert(subject.schemes == schemes)
    }

    func testInitWithNameFooterTextAndSchemes_setsName() {
        let subject: SchemeSet = SchemeSet(name: "Foo Bar", footerText: nil, withSchemes: [Scheme()])
        XCTAssert(subject.name == "Foo Bar")
    }
    
    func testInitWithNameFooterTextAndSchemes_setsFooterText() {
        let subject: SchemeSet = SchemeSet(name: "Foo Bar", footerText: "Buzz", withSchemes: [Scheme()])
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
}
