//
//  SchemeSet_Tests.swift
//  TableSchemer
//
//  Created by James Richard on 6/15/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import XCTest
@testable import TableSchemer

class SchemeSet_Tests: XCTestCase {
    // MARK: Initializers
    func testInitWithNameAndSchemes_setsSchemes() {
        let schemes: [Scheme] = [TestableScheme()]
        let subject = SchemeSet(name: "Foo Bar", withSchemes: schemes)
        XCTAssertTrue(subject.schemes.isEqualToSchemes(schemes))
    }

    func testInitWithSchemes_setsSchemes() {
        let schemes: [Scheme] = [TestableScheme()]
        let subject = SchemeSet(schemes: schemes)
        XCTAssertTrue(subject.schemes.isEqualToSchemes(schemes as [Scheme]))
    }

    func testInitWithNameAndSchemes_setsName() {
        let subject: SchemeSet = SchemeSet(name: "Foo Bar", withSchemes: [TestableScheme()])
        XCTAssert(subject.name == "Foo Bar")
    }
    
    func testInitWithNameFooterTextAndSchemes_setsFooterText() {
        let subject: SchemeSet = SchemeSet(name: "Foo Bar", footerText: "Buzz", withSchemes: [TestableScheme()])
        XCTAssert(subject.footerText == "Buzz")
    }
    
    func testInitWithFooterTextAndSchemes_setsFooterText() {
        let subject: SchemeSet = SchemeSet(footerText: "Buzz", withSchemes: [TestableScheme()])
        XCTAssert(subject.footerText == "Buzz")
    }

    // MARK: Subscript Support
    func testSubscript_accessesSchemes() {
        let schemes: [Scheme] = [TestableScheme()]
        let subject = SchemeSet(schemes: schemes)
        
        XCTAssert(subject[0] === schemes[0])
    }
    
    // MARK: Count
    func testCount_whenOneScheme_is1() {
        let subject = SchemeSet(schemes: [TestableScheme()])
        
        XCTAssertEqual(subject.count, 1)
    }
    
    func testCount_whenTwoSchemes_is2() {
        let subject = SchemeSet(schemes: [TestableScheme(), TestableScheme()])
        
        XCTAssertEqual(subject.count, 2)
    }
    
    // MARK: Visibility
    func testVisibleSchemes_onlyIncludeVisibleSchemes() {
        let scheme1 = TestableScheme()
        let scheme2 = TestableScheme()
        let schemes: [Scheme] = [scheme1, scheme2]
        let subject = SchemeSet(schemes: schemes)
        subject.schemeItems[0].hidden = true
        XCTAssertTrue(subject.visibleSchemes.isEqualToSchemes([scheme2] as [Scheme]))
    }
    
}

extension SequenceType where Self.Generator.Element == Scheme {
    func isEqualToSchemes<SchemeSequenceType: SequenceType where SchemeSequenceType.Generator.Element == Scheme>(schemes: SchemeSequenceType) -> Bool {
        var gen = generate()
        for scheme in schemes {
            guard let comp = gen.next() else {
                return false
            }

            if comp !== scheme {
                return false
            }
        }

        return true
    }
}
