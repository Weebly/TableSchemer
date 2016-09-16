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
        let subject = SchemeSet(schemes: schemes, headerText: "Foo Bar")
        XCTAssertTrue(subject.schemes.isEqualToSchemes(schemes))
    }

    func testInitWithSchemes_setsSchemes() {
        let schemes: [Scheme] = [TestableScheme()]
        let subject = SchemeSet(schemes: schemes)
        XCTAssertTrue(subject.schemes.isEqualToSchemes(schemes as [Scheme]))
    }

    func testInitWithNameAndSchemes_setsName() {
        let subject: SchemeSet = SchemeSet(schemes: [TestableScheme()], headerText: "Foo Bar")
        XCTAssert(subject.headerText == "Foo Bar")
    }
    
    func testInitWithNameFooterTextAndSchemes_setsFooterText() {
        let subject: SchemeSet = SchemeSet(schemes: [TestableScheme()], headerText: "Foo Bar", footerText: "Buzz")
        XCTAssert(subject.footerText == "Buzz")
    }
    
    func testInitWithFooterTextAndSchemes_setsFooterText() {
        let subject: SchemeSet = SchemeSet(schemes: [TestableScheme()], footerText: "Buzz")
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
        subject.attributedSchemes[0].hidden = true
        XCTAssertTrue(subject.visibleSchemes.isEqualToSchemes([scheme2] as [Scheme]))
    }
    
}

extension Sequence where Self.Iterator.Element == Scheme {
    func isEqualToSchemes<SchemeSequenceType: Sequence>(_ schemes: SchemeSequenceType) -> Bool where SchemeSequenceType.Iterator.Element == Scheme {
        var gen = makeIterator()
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
