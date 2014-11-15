//
//  TableScheme_Tests.swift
//  TableSchemer
//
//  Created by James Richard on 7/2/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import XCTest
import TableSchemer
import UIKit

let TableSchemeTestsReuseIdentifier = "ReuseIdentifier"

class TableScheme_Tests: XCTestCase {
    var subject: TableScheme!
    var schemeSet1: SchemeSet!
    var schemeSet2: SchemeSet!
    var schemeSet3: SchemeSet!
    
    var schemeSet1Scheme1: TestableScheme!
    var schemeSet1Scheme2: TestableScheme!
    var schemeSet2Scheme1: TestableScheme!
    var schemeSet3Scheme1: TestableScheme!
    
    var tableView: UITableView!
    
    // MARK: Setup and Teardown
    override func setUp() {
        super.setUp()
        schemeSet1Scheme1 = TestableScheme()
        schemeSet1Scheme1.definedNumberOfCells = 3
        schemeSet1Scheme2 = TestableScheme()
        schemeSet2Scheme1 = TestableScheme()
        schemeSet2Scheme1.definedNumberOfCells = 5
        schemeSet3Scheme1 = TestableScheme()
        
        schemeSet1 = SchemeSet(name: "Test Scheme Set", withSchemes: [schemeSet1Scheme1, schemeSet1Scheme2])
        schemeSet2 = SchemeSet(schemes: [schemeSet2Scheme1])
        schemeSet3 = SchemeSet(schemes: [schemeSet3Scheme1])
        
        subject = TableScheme(schemeSets: [schemeSet1, schemeSet2, schemeSet3])
        tableView = UITableView()
    }
    
    override func tearDown() {
        subject = nil
        
        schemeSet1 = nil
        schemeSet2 = nil
        schemeSet3 = nil
        
        schemeSet1Scheme1 = nil
        schemeSet1Scheme2 = nil
        schemeSet2Scheme1 = nil
        schemeSet3Scheme1 = nil
        
        super.tearDown()
    }
    
    // MARK: Number Of Sections In Table View
    func testNumberOfSections_matchesNumberOfSchemes() {
        XCTAssertEqual(subject.numberOfSectionsInTableView(tableView), 3)
    }
    
    // MARK: Number of Rows In Section
    func testNumberOfRowsInSection_matchesSchemeReportedCells() {
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 0), 4)
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 1), 5)
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 2), 1)
    }

    // MARK: Cell For Row At Index Path
    func testCellForRowAtIndex_returnsCorrectCellType() {
        let tableView = configuredTableView()
        let cell = subject.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2))
        XCTAssertTrue(cell is SchemeCell)
    }
    
    func testCellForRowAtIndexPath_setsSchemeOnCell_whenSubclassOfSchemeCell() {
        let tableView = configuredTableView()
        let cell = subject.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as SchemeCell
        XCTAssert(cell.scheme === schemeSet3Scheme1)
    }
    
    func testCellForRowAtIndexPath_configuresCellCorrectly_forBasicScheme() {
        let tableView = configuredTableView()
        let cell = subject.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2))
        let configureCall = schemeSet3Scheme1.lastConfigureCall
        XCTAssert(configureCall.cell === cell)
        XCTAssert(configureCall.relativeIndex == 0)
    }
    
    func testCellForRowAtIndexPath_configuresCellCorrectly_forSchemeBelowLargeScheme() {
        let tableView = configuredTableView()
        let cell = subject.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 3, inSection: 0))
        let configureCall = schemeSet1Scheme2.lastConfigureCall
        XCTAssert(configureCall.cell === cell)
        XCTAssert(configureCall.relativeIndex == 0)
    }
    
    func testCellForRowAtIndexPath_configuresCellCorrectly_forLargeScheme() {
        let tableView = configuredTableView()
        let cell = subject.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0))
        let configureCall = schemeSet1Scheme1.lastConfigureCall
        XCTAssert(configureCall.cell === cell)
        XCTAssert(configureCall.relativeIndex == 2)
    }
    
    // MARK: Title For Header In Section
    func testTitleForHeaderInSection_whenProvided_isCorrect() {
        XCTAssert(subject.tableView(tableView, titleForHeaderInSection: 0) == schemeSet1.name!)
    }
    
    func testTitleForHeaderInSection_whenNotProvided_isNil() {
        XCTAssert(subject.tableView(tableView, titleForHeaderInSection: 1) == nil)
    }
    
    // MARK: Handling Selection
    func testHandleSelectionInTableView_sendsCorrectSelection_forBasicScheme() {
        let tableView = configuredTableView()
        let indexPath = NSIndexPath(forRow: 0, inSection: 2)
        let cell = subject.tableView(tableView, cellForRowAtIndexPath: indexPath)
        let tableMock : AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.stub().andReturn(cell).cellForRowAtIndexPath(indexPath)
        
        subject.handleSelectionInTableView(tableView, forIndexPath: indexPath)
        let selectCall = schemeSet3Scheme1.lastSelectCall
        
        XCTAssert(selectCall.cell === cell)
        XCTAssert(selectCall.tableView === tableView)
        XCTAssertEqual(selectCall.section, 2)
        XCTAssertEqual(selectCall.rowsBeforeScheme, 0)
        XCTAssertEqual(selectCall.relativeIndex, 0)
    }
    
    func testHandleSelectionInTableView_sendsCorrectSelection_forSchemeBelowLargeScheme() {
        let tableView = configuredTableView()
        let indexPath = NSIndexPath(forRow: 3, inSection: 0)
        let cell = subject.tableView(tableView, cellForRowAtIndexPath: indexPath)
        let tableMock : AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.stub().andReturn(cell).cellForRowAtIndexPath(indexPath)
        
        subject.handleSelectionInTableView(tableView, forIndexPath: indexPath)
        let selectCall = schemeSet1Scheme2.lastSelectCall
        
        XCTAssert(selectCall.cell === cell)
        XCTAssert(selectCall.tableView === tableView)
        XCTAssertEqual(selectCall.section, 0)
        XCTAssertEqual(selectCall.rowsBeforeScheme, 3)
        XCTAssertEqual(selectCall.relativeIndex, 0)
    }
    
    func testHandleSelectionInTableView_sendsCorrectSelection_forLargeScheme() {
        let tableView = configuredTableView()
        let indexPath = NSIndexPath(forRow: 2, inSection: 0)
        let cell = subject.tableView(tableView, cellForRowAtIndexPath: indexPath)
        let tableMock : AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.stub().andReturn(cell).cellForRowAtIndexPath(indexPath)
        
        subject.handleSelectionInTableView(tableView, forIndexPath: indexPath)
        let selectCall = schemeSet1Scheme1.lastSelectCall
        
        XCTAssert(selectCall.cell === cell)
        XCTAssert(selectCall.tableView === tableView)
        XCTAssertEqual(selectCall.section, 0)
        XCTAssertEqual(selectCall.rowsBeforeScheme, 0)
        XCTAssertEqual(selectCall.relativeIndex, 2)
    }
    
    // MARK: Height In Table View
    func testHeightInTableView_returnsCorrectHeight() {
        let tableView = configuredTableView()
        let height = subject.heightInTableView(tableView, forIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(height, CGFloat(44.0))
    }
    
    // MARK: Scheme At Index Path
    func testSchemeAtIndexPath_returnsCorrectScheme() {
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) === schemeSet1Scheme1)
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) === schemeSet1Scheme1)
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) === schemeSet1Scheme1)
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) === schemeSet1Scheme2)
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) === schemeSet2Scheme1)
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) === schemeSet2Scheme1)
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 2, inSection: 1)) === schemeSet2Scheme1)
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 3, inSection: 1)) === schemeSet2Scheme1)
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 4, inSection: 1)) === schemeSet2Scheme1)
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)) === schemeSet3Scheme1)
    }
    
    // MARK: Finding a Scheme within a View
    func testSchemeContainingView_returnsCorrectScheme() {
        let tableView = configuredTableView()
        let subview = UIView()
        let cell = tableView.dequeueReusableCellWithIdentifier(TableSchemeTestsReuseIdentifier, forIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as UITableViewCell
        cell.contentView.addSubview(subview)
        let tableMock : AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.stub().andReturn(NSIndexPath(forRow: 0, inSection: 2)).indexPathForCell(cell)
        XCTAssert(subject.schemeContainingView(subview) ===  schemeSet3Scheme1)
    }
    
    func testSchemeWithIndexContainingView_returnsCorrectTuple() {
        let tableView = configuredTableView()
        let subview = UIView()
        let cell = tableView.dequeueReusableCellWithIdentifier(TableSchemeTestsReuseIdentifier, forIndexPath: NSIndexPath(forRow: 2, inSection: 1)) as UITableViewCell
        cell.contentView.addSubview(subview)
        let tableMock : AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.stub().andReturn(NSIndexPath(forRow: 2, inSection: 1)).indexPathForCell(cell)
        let tuple = subject.schemeWithIndexContainingView(subview)!
        XCTAssert(tuple.scheme ===  schemeSet2Scheme1)
        XCTAssertEqual(tuple.index, 2)
    }
    
    // MARK: Test Helpers
    func configuredTableView(cellClass: AnyObject.Type = SchemeCell.self) -> UITableView {
        let tableView = UITableView()
        tableView.registerClass(cellClass, forCellReuseIdentifier: TableSchemeTestsReuseIdentifier)
        tableView.dataSource = subject
        
        return tableView
    }
}

public class TestableScheme: Scheme {
    var lastConfigureCall: (cell: UITableViewCell, relativeIndex: Int)!
    var lastSelectCall: (cell: UITableViewCell, tableView: UITableView, section: Int, rowsBeforeScheme: Int, relativeIndex: Int)!
    
    var definedNumberOfCells = 1
    
    override public var numberOfCells: Int {
        return definedNumberOfCells
    }
    
    public required init() {
        super.init()
    }
    
    override public func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int)  {
        lastConfigureCall = (cell: cell, relativeIndex: relativeIndex)
    }
    
    override public func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int)  {
        lastSelectCall = (cell: cell, tableView: tableView, section: section, rowsBeforeScheme: rowsBeforeScheme, relativeIndex: relativeIndex)
    }
    
    override public func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String? {
        return TableSchemeTestsReuseIdentifier
    }
    
    override public func heightForRelativeIndex(relativeIndex: Int) -> RowHeight {
        return .Custom(44)
    }
}