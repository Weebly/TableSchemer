//
//  AccordionScheme_Tests.swift
//  TableSchemer
//
//  Created by James Richard on 6/14/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import XCTest
import UIKit
import TableSchemer

class AccordionScheme_Tests: XCTestCase {
    let ReuseIdentifier = "UITableViewCell"

    var subject: AccordionScheme<UITableViewCell, UITableViewCell>!
    
    // MARK: Setup and Teardown
    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    // MARK: Items
    func testItems_matchesReuseIdentifierCount() {
        configureSubjectWithConfigurationHandler()
        XCTAssert(subject.numberOfItems == 3)
    }
    
    // MARK: Configuring Cell
    func testConfigureCell_whenUnexpanded_callsConfigurationBlockWithCell() {
        var passedCell: UITableViewCell?
        configureSubjectWithConfigurationHandler({(cell) in
            passedCell = cell
        })
        
        let configureCell = UITableViewCell()
        subject.configureCell(configureCell, withRelativeIndex: 0)
        
        XCTAssert(passedCell === configureCell)
    }
    
    func testConfigureCell_whenExpanded_callsAccordionConfigurationBlockWithCell() {
        var passedCell1: UITableViewCell?
        var passedCell2: UITableViewCell?
        var passedCell3: UITableViewCell?
        
        configureSubjectWithConfigurationHandler({(cell) in
        }, accordionConfigurationHandler: {(cell, index) in
            if index == 0 {
                passedCell1 = cell
            } else if index == 1 {
                passedCell2 = cell
            } else if index == 2 {
                passedCell3 = cell
            }
        })
        
        let tableView = UITableView()
        let configureCell1 = UITableViewCell()
        let configureCell2 = UITableViewCell()
        let configureCell3 = UITableViewCell()
        
        subject.selectCell(configureCell1, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        subject.configureCell(configureCell1, withRelativeIndex: 0)
        subject.configureCell(configureCell2, withRelativeIndex: 1)
        subject.configureCell(configureCell3, withRelativeIndex: 2)
        
        XCTAssert(passedCell1 === configureCell1)
        XCTAssert(passedCell2 === configureCell2)
        XCTAssert(passedCell3 === configureCell3)
    }
    
    // MARK: Select Cell
    func testSelectCell_whenUnexpanded_callsSelectBlock() {
        var passedCell: UITableViewCell?
        var passedScheme: AccordionScheme<UITableViewCell, UITableViewCell>?
        
        configureSubjectWithConfigurationHandler()
        subject.selectionHandler = {(cell, scheme) in
            passedCell = cell
            passedScheme = scheme as? AccordionScheme
        }
        
        let tableView = UITableView()
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        XCTAssert(passedCell === cell)
        XCTAssert(passedScheme === subject)
    }
    
    func testSelectCell_whenExpanded_callsAccordionSelectBlock() {
        var passedCell: UITableViewCell?
        var passedScheme: AccordionScheme<UITableViewCell, UITableViewCell>?
        var passedIndex: Int?
        
        configureSubjectWithConfigurationHandler()
        subject.accordionSelectionHandler = {(cell, scheme, index) in
            passedCell = cell
            passedScheme = scheme
            passedIndex = index
        }
        
        let tableView = UITableView()
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 1)
        
        XCTAssert(passedCell === cell)
        XCTAssert(passedScheme === subject)
        XCTAssert(passedIndex == 1)
    }
    
    func testSelectCell_whenUnexpanded_expandsCell() {
        configureSubjectWithConfigurationHandler()
        
        let tableView = UITableView()
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        XCTAssertEqual(subject.numberOfCells, 3)
    }
    
    func testSelectCell_whenExpanded_unexpandsCell() {
        configureSubjectWithConfigurationHandler()
        
        let tableView = UITableView()
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        XCTAssertEqual(subject.numberOfCells, 1)
    }
    
    func testSelectCell_whenUnexpanded_whenFirstRowIsSelected_animatesNewCellsIn() {
        configureSubjectWithConfigurationHandler()
        
        let tableMock = OCMockObject.niceMock(for: UITableView.self) as AnyObject
        (tableMock.expect() as AnyObject).beginUpdates()
        (tableMock.expect() as AnyObject).endUpdates()
        (tableMock.expect() as AnyObject).insertRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .fade)
        (tableMock.expect() as AnyObject).reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableMock as! UITableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        _ = tableMock.verify()
    }
    
    func testSelectCell_whenUnexpanded_whenLastRowIsSelected_animatesNewCellsIn() {
        configureSubjectWithConfigurationHandler()
        subject.selectedIndex = 2
        
        let tableMock = OCMockObject.niceMock(for: UITableView.self) as AnyObject
        (tableMock.expect() as AnyObject).beginUpdates()
        (tableMock.expect() as AnyObject).endUpdates()
        (tableMock.expect() as AnyObject).insertRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: .fade)
        (tableMock.expect() as AnyObject).reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableMock as! UITableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        _ = tableMock.verify()
    }
    
    func testSelectCell_whenUnexpanded_whenMiddleRowIsSelected_animatesNewCellsIn() {
        configureSubjectWithConfigurationHandler()
        subject.selectedIndex = 1
        
        let tableMock = OCMockObject.niceMock(for: UITableView.self) as AnyObject
        (tableMock.expect() as AnyObject).beginUpdates()
        (tableMock.expect() as AnyObject).endUpdates()
        (tableMock.expect() as AnyObject).insertRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
        (tableMock.expect() as AnyObject).insertRows(at: [IndexPath(row: 3, section: 0)], with: .fade)
        (tableMock.expect() as AnyObject).reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        
        let cell = UITableViewCell()

        subject.selectCell(cell, inTableView: tableMock as! UITableView, inSection: 0, havingRowsBeforeScheme: 1, withRelativeIndex: 0)
        
        _ = tableMock.verify()
    }
    
    func testSelectCell_whenExpanded_whenFirstRowIsSelected_animatesOldCellsOut() {
        configureSubjectWithConfigurationHandler()
        
        let tableMock = OCMockObject.niceMock(for: UITableView.self) as AnyObject
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableMock as! UITableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        (tableMock.expect() as AnyObject).beginUpdates()
        (tableMock.expect() as AnyObject).endUpdates()
        (tableMock.expect() as AnyObject).deleteRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .fade)
        (tableMock.expect() as AnyObject).reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)

        subject.selectCell(cell, inTableView: tableMock as! UITableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        _ = tableMock.verify()
    }
    
    func testSelectCell_whenExpanded_whenLastRowIsSelected_animatesOldCellsOut() {
        configureSubjectWithConfigurationHandler()
        
        let tableMock = OCMockObject.niceMock(for: UITableView.self) as AnyObject
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableMock as! UITableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        (tableMock.expect() as AnyObject).beginUpdates()
        (tableMock.expect() as AnyObject).endUpdates()
        (tableMock.expect() as AnyObject).deleteRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: .fade)
        (tableMock.expect() as AnyObject).reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        
        subject.selectCell(cell, inTableView: tableMock as! UITableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 2)
        
        _ = tableMock.verify()
    }
    
    func testSelectCell_whenExpanded_whenMiddleRowIsSelected_animatesOldCellsOut() {
        configureSubjectWithConfigurationHandler()
        
        let tableMock = OCMockObject.niceMock(for: UITableView.self) as AnyObject
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableMock as! UITableView, inSection: 0, havingRowsBeforeScheme: 1, withRelativeIndex: 0)
        
        (tableMock.expect() as AnyObject).beginUpdates()
        (tableMock.expect() as AnyObject).endUpdates()
        (tableMock.expect() as AnyObject).deleteRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
        (tableMock.expect() as AnyObject).deleteRows(at: [IndexPath(row: 3, section: 0)], with: .fade)
        (tableMock.expect() as AnyObject).reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)

        subject.selectCell(cell, inTableView: tableMock as! UITableView, inSection: 0, havingRowsBeforeScheme: 1, withRelativeIndex: 1)
        
        _ = tableMock.verify()
    }
    
    // MARK: Number of Cells
    func testNumberOfCells_whenUnexpanded_is1() {
        configureSubjectWithConfigurationHandler()
        XCTAssertTrue(subject.numberOfCells == 1)
    }
    
    func testNumberOfCells_whenExpanded_isNumberOfAccordionItems() {
        configureSubjectWithConfigurationHandler()
        
        let tableView = UITableView()
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        XCTAssert(subject.numberOfCells == 3)
    }
    
    // MARK: Reuse Identifier For Relative Index
    func testReuseIdentifierForRelativeIndex_whenUnexpanded_isUnexpandedReuseIdentifier() {
        configureSubjectWithConfigurationHandler()
        XCTAssertEqual(subject.reuseIdentifier(forRelativeIndex:0), ReuseIdentifier)
    }
    
    func testReuseIdentifierForRelativeIndex_whenExpanded_isCorrectExpandedReuseIdentifier() {
        configureSubjectWithConfigurationHandler()
        
        let tableView = UITableView()
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        XCTAssertEqual(subject.reuseIdentifier(forRelativeIndex:1), "TestCell")
    }
    
    // MARK: Height For Relative Index
    func testHeightForRelativeIndex_usesDefinedHeight() {
        configureSubjectWithConfigurationHandler()
        subject.height = .custom(83.0)
        XCTAssertEqual(subject.height(forRelativeIndex:0), RowHeight.custom(83.0))
    }
    
    func testHeightForRelativeIndex_defaultsToUseTableHeight() {
        configureSubjectWithConfigurationHandler()
        XCTAssertEqual(subject.height(forRelativeIndex:0), RowHeight.useTable)
    }
    
    func testHeightForRelativeIndex_whenExpanded_equalsAccordionHeights() {
        configureSubjectWithConfigurationHandler()
        subject.accordionHeights = [.custom(25.0), .custom(29.0)]
        
        let tableView = UITableView()
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        XCTAssertEqual(subject.height(forRelativeIndex: 0), RowHeight.custom(25.0))
        XCTAssertEqual(subject.height(forRelativeIndex: 1), RowHeight.custom(29.0))
        XCTAssertEqual(subject.height(forRelativeIndex: 2), RowHeight.useTable)
    }
    
    // MARK: Test Configuration
    func configureSubjectWithConfigurationHandler(_ configurationHandler: @escaping BasicScheme<UITableViewCell>.ConfigurationHandler = {(cell) in }, accordionConfigurationHandler: @escaping AccordionScheme<UITableViewCell, UITableViewCell>.AccordionConfigurationHandler = {(cell, index) in }) {
        let expandedCells = [UITableViewCell.self, TestCell.self, UITableViewCell.self]
        subject = AccordionScheme(expandedCellTypes: expandedCells, collapsedCellConfigurationHandler: configurationHandler, expandedCellConfigurationHandler: accordionConfigurationHandler)
    }
}

class TestCell: UITableViewCell { }
