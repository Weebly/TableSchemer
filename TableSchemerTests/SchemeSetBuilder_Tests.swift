//
//  SchemeSetBuilder_Tests.swift
//  TableSchemer
//
//  Created by James Richard on 6/15/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import XCTest
@testable import TableSchemer

class SchemeSetBuilder_Tests: XCTestCase {
    // MARK: Creating Scheme Sets
    func testCreateSchemeSet_setsHeaderTExt() {
        let subject = SchemeSetBuilder()
        subject.headerText = "Foo Bar"
        let schemeSet = subject.createSchemeSet()
        XCTAssertEqual(schemeSet.schemeSet.headerText, "Foo Bar")
    }
    
    func testCreateSchemeSet_setsBuiltSchemeSets() {
        let subject = SchemeSetBuilder()
        let scheme1 = subject.buildScheme {(builder: BasicSchemeBuilder<UITableViewCell>) in
            builder.configurationHandler = {(cell: UITableViewCell) in}
        }
        let scheme2 = subject.buildScheme {(builder: BasicSchemeBuilder<UITableViewCell>) in
            builder.configurationHandler = {(cell: UITableViewCell) in}
        }
        
        let schemeSet = subject.createSchemeSet()
        XCTAssert(schemeSet.schemeSet.schemes[0] === scheme1)
        XCTAssert(schemeSet.schemeSet.schemes[1] === scheme2)
    }
    
    func testCreateSchemeSet_setsFooterText() {
        let subject = SchemeSetBuilder()
        _ = subject.buildScheme {(builder: BasicSchemeBuilder<UITableViewCell>) in
            builder.configurationHandler = {(cell: UITableViewCell) in}
        }
        
        subject.footerText = "Foo bar"
        
        let schemeSet = subject.createSchemeSet()
        XCTAssert(schemeSet.schemeSet.footerText == "Foo bar")
    }
    
    func testCreateScheme_setsHeaderView() {
        let subject = SchemeSetBuilder()
        _ = subject.buildScheme {(builder: BasicSchemeBuilder<UITableViewCell>) in
            builder.configurationHandler = {(cell: UITableViewCell) in}
        }
        
        let view = UIView()
        subject.headerView = view
        
        let schemeSet = subject.createSchemeSet()
        XCTAssert(schemeSet.schemeSet.headerView === view)
    }
    
    func testCreateScheme_setsHeaderViewHeight() {
        let subject = SchemeSetBuilder()
        _ = subject.buildScheme {(builder: BasicSchemeBuilder<UITableViewCell>) in
            builder.configurationHandler = {(cell: UITableViewCell) in}
        }
        
        subject.headerViewHeight = .custom(42)
        
        let schemeSet = subject.createSchemeSet()
        XCTAssertEqual(schemeSet.schemeSet.headerViewHeight, .custom(42))
    }
    
    func testCreateScheme_setsFooterView() {
        let subject = SchemeSetBuilder()
        _ = subject.buildScheme {(builder: BasicSchemeBuilder<UITableViewCell>) in
            builder.configurationHandler = {(cell: UITableViewCell) in}
        }
        
        let view = UIView()
        subject.footerView = view
        
        let schemeSet = subject.createSchemeSet()
        XCTAssert(schemeSet.schemeSet.footerView === view)
    }
    
    func testCreateScheme_setsFooterViewHeight() {
        let subject = SchemeSetBuilder()
        _ = subject.buildScheme {(builder: BasicSchemeBuilder<UITableViewCell>) in
            builder.configurationHandler = {(cell: UITableViewCell) in}
        }
        
        subject.footerViewHeight = .custom(42)
        
        let schemeSet = subject.createSchemeSet()
        XCTAssertEqual(schemeSet.schemeSet.footerViewHeight, .custom(42))
    }
    
    func testCreateSchemeSet_setsHidden() {
        let subject = SchemeSetBuilder()
        _ = subject.buildScheme {(builder: BasicSchemeBuilder<UITableViewCell>) in
            builder.configurationHandler = {(cell: UITableViewCell) in}
        }
        
        subject.hidden = true
        
        let schemeSet = subject.createSchemeSet()
        XCTAssertTrue(schemeSet.hidden)
    }
}
