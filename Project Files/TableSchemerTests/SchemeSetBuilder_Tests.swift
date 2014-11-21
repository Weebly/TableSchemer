//
//  SchemeSetBuilder_Tests.swift
//  TableSchemer
//
//  Created by James Richard on 6/15/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import XCTest
import TableSchemer
import UIKit

class SchemeSetBuilder_Tests: XCTestCase {
    // MARK: Creating Scheme Sets
    func testCreateSchemeSet_setsName() {
        let subject = SchemeSetBuilder()
        subject.name = "Foo Bar"
        let schemeSet = subject.createSchemeSet()
        XCTAssertEqual(schemeSet.name!, "Foo Bar")
    }
    
    func testCreateSchemeSet_setsBuiltSchemeSets() {
        let subject = SchemeSetBuilder()
        let scheme1 = subject.buildScheme {(scheme: BasicScheme) in
            scheme.reuseIdentifier = "Foo"
            scheme.configurationHandler = {(cell: UITableViewCell) in}
        }
        let scheme2 = subject.buildScheme {(scheme: BasicScheme) in
            scheme.reuseIdentifier = "Bar"
            scheme.configurationHandler = {(cell: UITableViewCell) in}
        }
        
        let schemeSet = subject.createSchemeSet()
        XCTAssert(schemeSet.schemes == [scheme1, scheme2])
    }
    
    func testCreateSchemeSet_setsFooterText() {
        let subject = SchemeSetBuilder()
        let scheme1 = subject.buildScheme {(scheme: BasicScheme) in
            scheme.reuseIdentifier = "Foo"
            scheme.configurationHandler = {(cell: UITableViewCell) in}
        }
        
        subject.footerText = "Foo bar"
        
        let schemeSet = subject.createSchemeSet()
        XCTAssert(schemeSet.footerText == "Foo bar")
    }
    
    func testCreateSchemeSet_setsHidden() {
        let subject = SchemeSetBuilder()
        let scheme1 = subject.buildScheme {(scheme: BasicScheme) in
            scheme.reuseIdentifier = "Foo"
            scheme.configurationHandler = {(cell: UITableViewCell) in}
        }
        
        subject.hidden = true
        
        let schemeSet = subject.createSchemeSet()
        XCTAssertTrue(schemeSet.hidden)
    }
}
