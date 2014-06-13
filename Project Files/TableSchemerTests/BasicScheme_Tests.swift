//
//  BasicScheme_Tests.swift
//  TableSchemer
//
//  Created by James Richard on 6/13/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import XCTest
import UIKit
import TableSchemer

class BasicScheme_Tests: XCTestCase {
    let ReuseIdentifier = "ReuseIdentifier"
    var subject: BasicScheme!
    
    // MARK: Setup and Teardown
    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    // MARK: Instantiation
    func testInitDefaultsRowHeightToUseTableView() {
        subject = BasicScheme()
        XCTAssert(subject.height == RowHeight.UseTable)
    }
    
    // MARK: Validation
    func testValidate_withAllRequiredProperties_returnsTrue() {
        configureSubjectWithHandler()
        XCTAssertTrue(subject.isValid())
    }
    
    // MARK: Scheme Abstract Method Overrides
    func testConfigureCell_callsConfigurationBlockWithCell() {
        var passedCell: UITableViewCell?
        configureSubjectWithHandler { (cell) in
            passedCell = cell
        }
        
        let configureCell = UITableViewCell()
        subject.configureCell(configureCell, withRelativeIndex: 0)
        XCTAssert(passedCell === configureCell)
    }
    
    func testSelectCell_callsSelectBlockWithCellAndSelf() {
        configureSubjectWithHandler()
        var passedCell: UITableViewCell?
        var passedScheme: BasicScheme?
        subject.selectionHandler = {(cell, scheme) in
            passedCell = cell
            passedScheme = scheme
        }
        
        let tableView = UITableView()
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        XCTAssert(passedCell === cell)
        XCTAssert(passedScheme === subject)
    }
    
    func testReuseIdentifierForRelativeIndex_isReuseIdentifier() {
        configureSubjectWithHandler()
        XCTAssert(subject.reuseIdentifierForRelativeIndex(0) == ReuseIdentifier)
    }
    
    func testHeightForRelativeIndex_usesDefinedHeight() {
        configureSubjectWithHandler()
        subject.height = .Custom(83.0)
        XCTAssert(subject.heightForRelativeIndex(0) == .Custom(83.0))
    }
    
    func testHeightForRelativeIndex_defaultsToUseTableHeight() {
        configureSubjectWithHandler()
        XCTAssert(subject.heightForRelativeIndex(0) == .UseTable)
    }
    
    // MARK: Test Configuration
    func configureSubjectWithHandler(handler: BasicScheme.ConfigurationHandler = {(cell) in }) {
        subject = BasicScheme()
        subject.reuseIdentifier = ReuseIdentifier
        subject.configurationHandler = handler
    }
}
