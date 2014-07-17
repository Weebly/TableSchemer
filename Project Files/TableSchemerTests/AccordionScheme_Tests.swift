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
    let ReuseIdentifier0 = "ReuseIdentifier0"
    let ReuseIdentifier1 = "ReuseIdentifier1"
    let ReuseIdentifier2 = "ReuseIdentifier2"
    let ReuseIdentifier3 = "ReuseIdentifier3"
    var subject: AccordionScheme<UITableViewCell, UITableViewCell>!
    
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
    
    // MARK: Items
    func testItems_matchesReuseIdentifierCount() {
        configureSubjectWithConfigurationHandler()
        XCTAssert(subject.numberOfItems == 3)
    }
    
    // MARK: Configuring Cell
    func testConfigureCell_whenUnexpanded_callsConfigurationBlockWithCell() {
        var passedCell: UITableViewCell?
        configureSubjectWithConfigurationHandler(configurationHandler: {(cell) in
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
        
        XCTAssert(subject.expanded == true)
    }
    
    func testSelectCell_whenExpanded_unexpandsCell() {
        configureSubjectWithConfigurationHandler()
        
        let tableView = UITableView()
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        XCTAssert(subject.expanded == false)
    }
    
    func testSelectCell_whenUnexpanded_whenFirstRowIsSelected_animatesNewCellsIn() {
        configureSubjectWithConfigurationHandler()
        
        let tableMock : AnyObject! = OCMockObject.niceMockForClass(UITableView.self)
        tableMock.expect().beginUpdates()
        tableMock.expect().endUpdates()
        tableMock.expect().insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: .Fade)
        tableMock.expect().reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
        
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableMock as UITableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        tableMock.verify()
    }
    
    func testSelectCell_whenUnexpanded_whenLastRowIsSelected_animatesNewCellsIn() {
        configureSubjectWithConfigurationHandler()
        subject.selectedIndex = 2
        
        let tableMock : AnyObject! = OCMockObject.niceMockForClass(UITableView.self)
        tableMock.expect().beginUpdates()
        tableMock.expect().endUpdates()
        tableMock.expect().insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Fade)
        tableMock.expect().reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
        
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableMock as UITableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        tableMock.verify()
    }
    
    func testSelectCell_whenUnexpanded_whenMiddleRowIsSelected_animatesNewCellsIn() {
        configureSubjectWithConfigurationHandler()
        subject.selectedIndex = 1
        
        let tableMock : AnyObject! = OCMockObject.niceMockForClass(UITableView.self)
        tableMock.expect().beginUpdates()
        tableMock.expect().endUpdates()
        tableMock.expect().insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Fade)
        tableMock.expect().insertRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: .Fade)
        tableMock.expect().reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Automatic)
        
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableMock as UITableView, inSection: 0, havingRowsBeforeScheme: 1, withRelativeIndex: 0)
        
        tableMock.verify()
    }
    
    func testSelectCell_whenExpanded_whenFirstRowIsSelected_animatesOldCellsOut() {
        configureSubjectWithConfigurationHandler()
        
        let tableMock : AnyObject! = OCMockObject.niceMockForClass(UITableView.self)
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableMock as UITableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        tableMock.expect().beginUpdates()
        tableMock.expect().endUpdates()
        tableMock.expect().deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: .Fade)
        tableMock.expect().reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)

        subject.selectCell(cell, inTableView: tableMock as UITableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        tableMock.verify()
    }
    
    func testSelectCell_whenExpanded_whenLastRowIsSelected_animatesOldCellsOut() {
        configureSubjectWithConfigurationHandler()
        
        let tableMock : AnyObject! = OCMockObject.niceMockForClass(UITableView.self)
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableMock as UITableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        tableMock.expect().beginUpdates()
        tableMock.expect().endUpdates()
        tableMock.expect().deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Fade)
        tableMock.expect().reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: .Automatic)
        
        subject.selectCell(cell, inTableView: tableMock as UITableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 2)
        
        tableMock.verify()
    }
    
    func testSelectCell_whenExpanded_whenMiddleRowIsSelected_animatesOldCellsOut() {
        configureSubjectWithConfigurationHandler()
        
        let tableMock : AnyObject! = OCMockObject.niceMockForClass(UITableView.self)
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableMock as UITableView, inSection: 0, havingRowsBeforeScheme: 1, withRelativeIndex: 0)
        
        tableMock.expect().beginUpdates()
        tableMock.expect().endUpdates()
        tableMock.expect().deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Fade)
        tableMock.expect().deleteRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: .Fade)
        tableMock.expect().reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: .Automatic)

        subject.selectCell(cell, inTableView: tableMock as UITableView, inSection: 0, havingRowsBeforeScheme: 1, withRelativeIndex: 1)
        
        tableMock.verify()
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
        XCTAssertEqual(subject.reuseIdentifierForRelativeIndex(0)!, ReuseIdentifier0)
    }
    
    func testReuseIdentifierForRelativeIndex_whenExpanded_isCorrectExpandedReuseIdentifier() {
        configureSubjectWithConfigurationHandler()
        
        let tableView = UITableView()
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        XCTAssertEqual(subject.reuseIdentifierForRelativeIndex(1)!, ReuseIdentifier2)
    }
    
    // MARK: Height For Relative Index
    func testHeightForRelativeIndex_usesDefinedHeight() {
        configureSubjectWithConfigurationHandler()
        subject.height = .Custom(83.0)
        XCTAssertEqual(subject.heightForRelativeIndex(0), RowHeight.Custom(83.0))
    }
    
    func testHeightForRelativeIndex_defaultsToUseTableHeight() {
        configureSubjectWithConfigurationHandler()
        XCTAssertEqual(subject.heightForRelativeIndex(0), RowHeight.UseTable)
    }
    
    func testHeightForRelativeIndex_whenExpanded_equalsAccordionHeights() {
        configureSubjectWithConfigurationHandler()
        subject.accordionHeights = [.Custom(25.0), .Custom(29.0)]
        
        let tableView = UITableView()
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        XCTAssertEqual(subject.heightForRelativeIndex(0), RowHeight.Custom(25.0))
        XCTAssertEqual(subject.heightForRelativeIndex(1), RowHeight.Custom(29.0))
        XCTAssertEqual(subject.heightForRelativeIndex(2), RowHeight.UseTable)
    }
    
    // MARK: Test Configuration
    func configureSubjectWithConfigurationHandler(configurationHandler: BasicScheme<UITableViewCell>.ConfigurationHandler = {(cell) in }, accordionConfigurationHandler: AccordionScheme<UITableViewCell, UITableViewCell>.AccordionConfigurationHandler = {(cell, index) in }) {
        subject = AccordionScheme()
        subject.reuseIdentifier = ReuseIdentifier0
        subject.accordionReuseIdentifiers = [ReuseIdentifier1, ReuseIdentifier2, ReuseIdentifier3]
        subject.configurationHandler = configurationHandler
        subject.accordionConfigurationHandler = accordionConfigurationHandler
    }
}
