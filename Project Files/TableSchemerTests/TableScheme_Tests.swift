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
    var schemeSet4: SchemeSet!
    
    var schemeSet1Scheme1: TestableScheme!
    var schemeSet1Scheme2: TestableScheme!
    var schemeSet2Scheme1: TestableScheme!
    var schemeSet3Scheme1: TestableScheme!
    var schemeSet4Scheme1: TestableScheme!
    var schemeSet4Scheme2: TestableScheme!
    var schemeSet4Scheme3: TestableScheme!
    
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
        schemeSet4Scheme1 = TestableScheme()
        schemeSet4Scheme2 = TestableScheme()
        schemeSet4Scheme2.height = 88.0
        schemeSet4Scheme3 = TestableScheme()
        schemeSet4Scheme3.definedNumberOfCells = 4
        
        schemeSet1 = SchemeSet(name: "Test Scheme Set", withSchemes: [schemeSet1Scheme1, schemeSet1Scheme2])
        schemeSet2 = SchemeSet(schemes: [schemeSet2Scheme1])
        schemeSet3 = SchemeSet(schemes: [schemeSet3Scheme1])
        schemeSet4 = SchemeSet(name: "Second Test Scheme Set", footerText: "Foo Bar", withSchemes: [schemeSet4Scheme1, schemeSet4Scheme2, schemeSet4Scheme3])
        
        subject = TableScheme(schemeSets: [schemeSet1, schemeSet2, schemeSet3, schemeSet4])
        tableView = UITableView()
    }
    
    override func tearDown() {
        subject = nil
        
        schemeSet1 = nil
        schemeSet2 = nil
        schemeSet3 = nil
        schemeSet4 = nil
        
        schemeSet1Scheme1 = nil
        schemeSet1Scheme2 = nil
        schemeSet2Scheme1 = nil
        schemeSet3Scheme1 = nil
        schemeSet4Scheme1 = nil
        schemeSet4Scheme2 = nil
        
        super.tearDown()
    }
    
    // MARK: Number Of Sections In Table View
    func testNumberOfSections_matchesNumberOfSchemeSets() {
        XCTAssertEqual(subject.numberOfSectionsInTableView(tableView), 4)
    }
    
    func testNumberOfSections_matchesNumberOfSchemeSets_excludingHiddenSections() {
        subject.hideSchemeSet(schemeSet2, inTableView: tableView)
        XCTAssertEqual(subject.numberOfSectionsInTableView(tableView), 3)
    }
    
    // MARK: Number of Rows In Section
    func testNumberOfRowsInSection_matchesSchemeReportedCells() {
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 0), 4)
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 1), 5)
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 2), 1)
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 3), 6)
    }
    
    func testNumberOfRowsInSection_accountsForHiddenSetsAndRows() {
        subject.hideScheme(schemeSet1Scheme2, inTableView: tableView)
        subject.hideSchemeSet(schemeSet2, inTableView: tableView)
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 0), 3)
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 1), 1)
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 2), 6)
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
    
    func testCellForRowAtIndexPath_accountsForHiddenSchemesAndSchemeSets() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet4Scheme1, inTableView: tableView)
        subject.hideSchemeSet(schemeSet2, inTableView: tableView)
        let cell = subject.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 2))
        let configureCall = schemeSet4Scheme3.lastConfigureCall
        XCTAssert(configureCall.cell === cell)
        XCTAssert(configureCall.relativeIndex == 1)
    }
    
    // MARK: Title For Header In Section
    func testTitleForHeaderInSection_whenProvided_isCorrect() {
        XCTAssert(subject.tableView(tableView, titleForHeaderInSection: 0) == schemeSet1.name)
    }
    
    func testTitleForHeaderInSection_whenNotProvided_isNil() {
        XCTAssert(subject.tableView(tableView, titleForHeaderInSection: 1) == nil)
    }
    
    func testTitleForHeaderInSection_accountsForHiddenSchemeSets() {
        subject.hideSchemeSet(schemeSet2, inTableView: tableView)
        XCTAssert(subject.tableView(tableView, titleForHeaderInSection: 2) == schemeSet4.name)
    }
    
    // MARK: Title For Footer In Section
    func testTitleForFooterInSection_whenProvided_isCorrect() {
        XCTAssert(subject.tableView(tableView, titleForFooterInSection: 3) == schemeSet4.footerText)
    }
    
    func testTitleForFooterInSection_whenNotProvided_isNil() {
        XCTAssert(subject.tableView(tableView, titleForFooterInSection: 1) == nil)
    }
    
    func testTitleForFooterInSection_accountsForHiddenSchemeSets() {
        subject.hideSchemeSet(schemeSet2, inTableView: tableView)
        XCTAssert(subject.tableView(tableView, titleForFooterInSection: 2) == schemeSet4.footerText)
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
    
    func testHandleSelectionInTableView_accoutsForHiddenSchemesAndSchemeSets() {
        let tableView = configuredTableView()
        subject.hideSchemeSet(schemeSet2, inTableView: tableView)
        subject.hideScheme(schemeSet4Scheme1, inTableView: tableView)
        let indexPath = NSIndexPath(forRow: 3, inSection: 2)
        let cell = subject.tableView(tableView, cellForRowAtIndexPath: indexPath)
        let tableMock : AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.stub().andReturn(cell).cellForRowAtIndexPath(indexPath)
        
        subject.handleSelectionInTableView(tableView, forIndexPath: indexPath)
        let selectCall = schemeSet4Scheme3.lastSelectCall
        
        XCTAssert(selectCall.cell === cell)
        XCTAssert(selectCall.tableView === tableView)
        XCTAssertEqual(selectCall.section, 2)
        XCTAssertEqual(selectCall.rowsBeforeScheme, 1)
        XCTAssertEqual(selectCall.relativeIndex, 2)
    }
    
    // MARK: Height In Table View
    func testHeightInTableView_returnsCorrectHeight() {
        let tableView = configuredTableView()
        let height = subject.heightInTableView(tableView, forIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(height, CGFloat(44.0))
    }
    
    func testHeightInTableView_accountsForHiddenSchemesAndSchemeSets() {
        let tableView = configuredTableView()
        subject.hideSchemeSet(schemeSet2, inTableView: tableView)
        subject.hideScheme(schemeSet4Scheme1, inTableView: tableView)
        let height = subject.heightInTableView(tableView, forIndexPath: NSIndexPath(forRow: 0, inSection: 2))
        XCTAssertEqual(height, CGFloat(schemeSet4Scheme2.height))
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
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 0, inSection: 3)) === schemeSet4Scheme1)
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 1, inSection: 3)) === schemeSet4Scheme2)
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 2, inSection: 3)) === schemeSet4Scheme3)
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 3, inSection: 3)) === schemeSet4Scheme3)
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 4, inSection: 3)) === schemeSet4Scheme3)
        XCTAssert(subject.schemeAtIndexPath(NSIndexPath(forRow: 5, inSection: 3)) === schemeSet4Scheme3)
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
    
    // MARK: Scheme Visibility
    func testHideScheme_marksSchemeHidden() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet1Scheme1, inTableView: tableView)
        XCTAssertTrue(schemeSet1Scheme1.hidden)
    }
    
    func testHideScheme_performsHideAnimationForEachCellInScheme() {
        let tableView = configuredTableView()
        let tableMock: AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.expect().deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: .Automatic)
        
        subject.hideScheme(schemeSet1Scheme1, inTableView: tableView)
        
        tableMock.verify()
    }
    
    func testHideScheme_performsHideAnimationForEachCellInScheme_withSpecifiedAnimation() {
        let tableView = configuredTableView()
        let tableMock : AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.expect().deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: .Fade)
        
        subject.hideScheme(schemeSet1Scheme1, inTableView: tableView, withRowAnimation: .Fade)
        
        tableMock.verify()
    }
    
    func testHideScheme_performsHideAnimationInCorrectSection() {
        let tableView = configuredTableView()
        let tableMock: AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.expect().deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 2)], withRowAnimation: .Automatic)
        
        subject.hideScheme(schemeSet3Scheme1, inTableView: tableView)
        
        tableMock.verify()
    }
    
    func testHideScheme_forOffsettedScheme_performsHideAnimationInRows() {
        let tableView = configuredTableView()
        let tableMock: AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.expect().deleteRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: .Automatic)
        
        subject.hideScheme(schemeSet1Scheme2, inTableView: tableView)
        
        tableMock.verify()
    }
    
    func testShowScheme_marksSchemeVisible() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet1Scheme1, inTableView: tableView)
      
        subject.showScheme(schemeSet1Scheme1, inTableView: tableView)
        
        XCTAssertFalse(schemeSet1Scheme1.hidden)
    }
    
    func testShowScheme_performsShowAnimationForEachCellInScheme() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet1Scheme1, inTableView: tableView)
        let tableMock: AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.expect().insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: .Automatic)
        
        subject.showScheme(schemeSet1Scheme1, inTableView: tableView)
        
        tableMock.verify()
    }
    
    func testShowScheme_performsHideAnimationForEachCellInScheme_withSpecifiedAnimation() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet1Scheme1, inTableView: tableView)
        let tableMock: AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.expect().insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: .Fade)
        
        subject.showScheme(schemeSet1Scheme1, inTableView: tableView, withRowAnimation: .Fade)
        
        tableMock.verify()
    }
    
    func testShowScheme_performsShowAnimationInCorrectSection() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet3Scheme1, inTableView: tableView)
        let tableMock: AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.expect().insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 2)], withRowAnimation: .Automatic)
        
        subject.showScheme(schemeSet3Scheme1, inTableView: tableView)
        
        tableMock.verify()
    }
    
    func testShowScheme_forOffsettedScheme_performsShowAnimationInRows() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet1Scheme2, inTableView: tableView)
        let tableMock: AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.expect().insertRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: .Automatic)
        
        subject.showScheme(schemeSet1Scheme2, inTableView: tableView)
        
        tableMock.verify()
    }
    
    func testHideSchemeSet_marksSchemeSetHidden() {
        let tableView = configuredTableView()
        subject.hideSchemeSet(schemeSet1, inTableView: tableView)
        XCTAssertTrue(schemeSet1.hidden)
    }
    
    func testHideSchemeSet_performsHideAnimationForSchemeSet() {
        let tableView = configuredTableView()
        let tableMock: AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.expect().deleteSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        
        subject.hideSchemeSet(schemeSet1, inTableView: tableView)
        
        tableMock.verify()
    }
    
    func testHideSchemeSet_performsHideAnimationForSchemeSet_withSpecifiedAnimation() {
        let tableView = configuredTableView()
        let tableMock: AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.expect().deleteSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        
        subject.hideSchemeSet(schemeSet1, inTableView: tableView, withRowAnimation: .Fade)
        
        tableMock.verify()
    }
    
    func testHideSchemeSet_forOffsettedSchemeSet_performsHideAnimationOnCorrectSection() {
        let tableView = configuredTableView()
        let tableMock: AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.expect().deleteSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
        
        subject.hideSchemeSet(schemeSet3, inTableView: tableView)
        
        tableMock.verify()
    }
    
    func testShowSchemeSet_marksSchemeSetVisible() {
        let tableView = configuredTableView()
        subject.hideSchemeSet(schemeSet1, inTableView: tableView)
        subject.showSchemeSet(schemeSet1, inTableView: tableView)
        XCTAssertFalse(schemeSet1.hidden)
    }
    
    func testShowSchemeSet_performsShowAnimationForSchemeSet() {
        let tableView = configuredTableView()
        subject.hideSchemeSet(schemeSet1, inTableView: tableView)
        let tableMock: AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.expect().insertSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        
        subject.showSchemeSet(schemeSet1, inTableView: tableView)
        
        tableMock.verify()
    }
    
    func testShowSchemeSet_performsShowAnimationForSchemeSet_withSpecifiedAnimation() {
        let tableView = configuredTableView()
        subject.hideSchemeSet(schemeSet1, inTableView: tableView, withRowAnimation: .Fade)
        let tableMock: AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.expect().insertSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        
        subject.showSchemeSet(schemeSet1, inTableView: tableView, withRowAnimation: .Fade)
        
        tableMock.verify()
    }
    
    func testShowSchemeSet_forOffsettedSchemeSet_performsShowAnimationOnCorrectSection() {
        let tableView = configuredTableView()
        subject.hideSchemeSet(schemeSet3, inTableView: tableView)
        let tableMock: AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.expect().insertSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
        
        subject.showSchemeSet(schemeSet3, inTableView: tableView)
        
        tableMock.verify()
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
    var height: CGFloat = 44.0
    
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
        return .Custom(height)
    }
}
