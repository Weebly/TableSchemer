//
//  RadioScheme_Tests.swift
//  TableSchemer
//
//  Created by James Richard on 6/14/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import XCTest
import UIKit
@testable import TableSchemer

class RadioScheme_Tests: XCTestCase {
    var subject: RadioScheme<UITableViewCell>!

    // MARK: Setup and Teardown
    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    // MARK: Configuring Cell
    func testConfigureCell_configuresCellWithCellAndRelativeIndex() {
        var passedCell: UITableViewCell?
        var passedIndex: Int?
        
        configureSubjectWithConfigurationHandler({ (cell, index) in
            passedCell = cell
            passedIndex = index
        })
        
        let cell = UITableViewCell()
        
        subject.configureCell(cell, withRelativeIndex: 1)
        
        XCTAssert(passedCell === cell)
        XCTAssertEqual(passedIndex!, 1)
    }
    
    func testConfigureCell_whenSelected_setsCheckmarkAccessory() {
        configureSubjectWithConfigurationHandler()
        subject.selectedIndex = 1
        
        let cell = UITableViewCell()
        subject.configureCell(cell, withRelativeIndex: 1)
        
        XCTAssertEqual(cell.accessoryType, UITableViewCell.AccessoryType.checkmark)
    }
    
    func testConfigureCell_whenNotSelected_setsAccessoryToNone() {
        configureSubjectWithConfigurationHandler()
        subject.selectedIndex = 1
        
        let cell = UITableViewCell()
        cell.accessoryType = .checkmark
        subject.configureCell(cell, withRelativeIndex: 0)
        
        XCTAssertEqual(cell.accessoryType, UITableViewCell.AccessoryType.none)
    }
    
    // MARK: Selecing Cell
    func testSelectCell_updatesSelectedIndex() {
        configureSubjectWithConfigurationHandler()
        
        let tableView = UITableView()
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 1)
        
        XCTAssertEqual(subject.selectedIndex, 1)
    }
    
    func testSelectCell_callsSelectionHandler() {
        var passedCell: UITableViewCell?
        var passedScheme: RadioScheme<UITableViewCell>?
        var passedIndex: Int?
        var selectedIndexAtCalling: Int?
        
        configureSubjectWithConfigurationHandler(selectionHandler: {(cell, scheme, index) in
            passedCell = cell
            passedScheme = scheme
            passedIndex = index
            selectedIndexAtCalling = scheme.selectedIndex
        })
        
        let tableView = UITableView()
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 1)
        
        XCTAssert(passedCell === cell)
        XCTAssert(passedScheme === subject)
        XCTAssertEqual(passedIndex!, 1)
        XCTAssertEqual(selectedIndexAtCalling!, 0)
    }
    
    func testSelectCell_updatesPreviouslySelectedCellAccessoryType() {
        configureSubjectWithConfigurationHandler()

        let tableView = RecordingTableView()
        let oldCell = UITableViewCell()
        oldCell.accessoryType = .checkmark

        let indexPath = IndexPath(row: 3, section: 0)
        tableView.cellOverrides[indexPath] = oldCell

        let cell = UITableViewCell()

        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 3, withRelativeIndex: 1)
        
        XCTAssertEqual(oldCell.accessoryType, UITableViewCell.AccessoryType.none)
        XCTAssertEqual(cell.accessoryType, UITableViewCell.AccessoryType.checkmark)
    }
    
    // MARK: Number of Cells
    func testNumberOfCells_isNumberOfReuseIdentifiers() {
        configureSubjectWithConfigurationHandler()
        
        XCTAssertEqual(subject.numberOfCells, 2)
    }
    
    // MARK: Reuse Identifier for Relative Index
    func testReuseIdentifierForRelativeIndex_matchesReuseIdentifiers() {
        configureSubjectWithConfigurationHandler()
        
        XCTAssertEqual(subject.reuseIdentifier(forRelativeIndex: 0), "UITableViewCell")
        XCTAssertEqual(subject.reuseIdentifier(forRelativeIndex: 1), "UITableViewCell")
    }
    
    // MARK: Height For Relative Index
    func testReuseIdentifiersForRelativeIndex_matchesReuseIdentifiers() {
        configureSubjectWithConfigurationHandler()
        subject.heights = [.custom(22.0), .custom(44.0)]
        
        XCTAssertEqual(subject.height(forRelativeIndex: 0), RowHeight.custom(22.0))
        XCTAssertEqual(subject.height(forRelativeIndex: 1), RowHeight.custom(44.0))
    }
    
    func testHeightForRelativeIndex_defaultsToUseTableHeight() {
        configureSubjectWithConfigurationHandler()
        
        XCTAssertEqual(subject.height(forRelativeIndex: 0), RowHeight.useTable)
    }
        
    // MARK: Test Configuration
    func configureSubjectWithConfigurationHandler(_ configurationHandler: @escaping RadioScheme<UITableViewCell>.ConfigurationHandler = {(cell, index) in }, selectionHandler: @escaping RadioScheme<UITableViewCell>.SelectionHandler = {(cell, scheme, index) in}) {
        subject = RadioScheme(expandedCellTypes: [UITableViewCell.self, UITableViewCell.self], configurationHandler: configurationHandler)
        subject.selectionHandler = selectionHandler
    }
}
