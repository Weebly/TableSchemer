//
//  BasicScheme_Tests.swift
//  TableSchemer
//
//  Created by James Richard on 6/13/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import XCTest
import UIKit
@testable import TableSchemer

class BasicScheme_Tests: XCTestCase {
    let ReuseIdentifier = "UITableViewCell"
    var subject: BasicScheme<UITableViewCell>!
    
    // MARK: Setup and Teardown
    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    // MARK: Instantiation
    func testInitDefaultsRowHeightToUseTableView() {
        configureSubjectWithHandler()
        XCTAssert(subject.height == RowHeight.useTable)
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
        var passedScheme: BasicScheme<UITableViewCell>?
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
        XCTAssert(subject.reuseIdentifier(forRelativeIndex:0) == ReuseIdentifier)
    }
    
    func testHeightForRelativeIndex_usesDefinedHeight() {
        configureSubjectWithHandler()
        subject.height = .custom(83.0)
        XCTAssert(subject.height(forRelativeIndex: 0) == .custom(83.0))
    }
    
    func testHeightForRelativeIndex_defaultsToUseTableHeight() {
        configureSubjectWithHandler()
        XCTAssert(subject.height(forRelativeIndex: 0) == .useTable)
    }
    
    // MARK: Test Configuration
    func configureSubjectWithHandler(_ handler: @escaping BasicScheme<UITableViewCell>.ConfigurationHandler = {(cell) in }) {
        subject = BasicScheme(configurationHandler: handler)
    }
}
