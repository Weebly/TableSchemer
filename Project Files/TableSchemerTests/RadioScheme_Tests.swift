//
//  RadioScheme_Tests.swift
//  TableSchemer
//
//  Created by James Richard on 6/14/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import XCTest
import UIKit
import TableSchemer

class RadioScheme_Tests: XCTestCase {
    let ReuseIdentifier1 = "ReuseIdentifier1"
    let ReuseIdentifier2 = "ReuseIdentifier2"
    var subject: RadioScheme<UITableViewCell>!

    // MARK: Setup and Teardown
    override func tearDown() {
        subject = nil
        super.tearDown()
    }
    
    // MARK: Validation
    func testValidate_withAllRequiredProperties_returnsTrue() {
        configureSubjectWithConfigurationHandler()
        XCTAssertTrue(subject.isValid())
    }
    
    // MARK: Configuring Cell
    func testConfigureCell_configuresCellWithCellAndRelativeIndex() {
        var passedCell: UITableViewCell?
        var passedIndex: Int?
        
        configureSubjectWithConfigurationHandler(configurationHandler: { (cell, index) in
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
        
        XCTAssertEqual(cell.accessoryType, UITableViewCellAccessoryType.Checkmark)
    }
    
    func testConfigureCell_whenNotSelected_setsAccessoryToNone() {
        configureSubjectWithConfigurationHandler()
        subject.selectedIndex = 1
        
        let cell = UITableViewCell()
        cell.accessoryType = .Checkmark
        subject.configureCell(cell, withRelativeIndex: 0)
        
        XCTAssertEqual(cell.accessoryType, UITableViewCellAccessoryType.None)
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
        
        let mockTableView : AnyObject! = OCMockObject.niceMockForClass(UITableView.self)
        let oldCell = UITableViewCell()
        oldCell.accessoryType = .Checkmark
        mockTableView.stub().andReturn(oldCell).cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0))
        
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: mockTableView as UITableView, inSection: 0, havingRowsBeforeScheme: 3, withRelativeIndex: 1)
        
        XCTAssertEqual(oldCell.accessoryType, UITableViewCellAccessoryType.None)
        XCTAssertEqual(cell.accessoryType, UITableViewCellAccessoryType.Checkmark)
    }
    
    // MARK: Number of Cells
    func testNumberOfCells_isNumberOfReuseIdentifiers() {
        configureSubjectWithConfigurationHandler()
        
        XCTAssertEqual(subject.numberOfCells, 2)
    }
    
    // MARK: Reuse Identifier for Relative Index
    func testReuseIdentifierForRelativeIndex_matchesReuseIdentifiers() {
        configureSubjectWithConfigurationHandler()
        
        XCTAssertEqual(subject.reuseIdentifierForRelativeIndex(0)!, ReuseIdentifier1)
        XCTAssertEqual(subject.reuseIdentifierForRelativeIndex(1)!, ReuseIdentifier2)
    }
    
    // MARK: Height For Relative Index
    func testReuseIdentifiersForRelativeIndex_matchesReuseIdentifiers() {
        configureSubjectWithConfigurationHandler()
        subject.heights = [.Custom(22.0), .Custom(44.0)]
        
        XCTAssertEqual(subject.heightForRelativeIndex(0), RowHeight.Custom(22.0))
        XCTAssertEqual(subject.heightForRelativeIndex(1), RowHeight.Custom(44.0))
    }
    
    func testHeightForRelativeIndex_defaultsToUseTableHeight() {
        configureSubjectWithConfigurationHandler()
        
        XCTAssertEqual(subject.heightForRelativeIndex(0), RowHeight.UseTable)
    }
    
    func testUsingReuseIdentifierWithNumberOfOptions_setsReuseIdentifiersToSameReuseIdentifierXTimes() {
        configureSubjectWithConfigurationHandler()
        subject.useReuseIdentifier(ReuseIdentifier1, withNumberOfOptions: 5)
        
        XCTAssertEqual(subject.reuseIdentifiers![0], ReuseIdentifier1)
        XCTAssertEqual(subject.reuseIdentifiers![1], ReuseIdentifier1)
        XCTAssertEqual(subject.reuseIdentifiers![2], ReuseIdentifier1)
        XCTAssertEqual(subject.reuseIdentifiers![3], ReuseIdentifier1)
        XCTAssertEqual(subject.reuseIdentifiers![4], ReuseIdentifier1)
    }
    
    // MARK: Test Configuration
    func configureSubjectWithConfigurationHandler(configurationHandler: RadioScheme<UITableViewCell>.ConfigurationHandler = {(cell, index) in }, selectionHandler: RadioScheme<UITableViewCell>.SelectionHandler = {(cell, scheme, index) in}) {
        subject = RadioScheme()
        subject.reuseIdentifiers = [ReuseIdentifier1, ReuseIdentifier2]
        subject.configurationHandler = configurationHandler
        subject.selectionHandler = selectionHandler
    }
}
