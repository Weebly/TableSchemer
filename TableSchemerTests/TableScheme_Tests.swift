//
//  TableScheme_Tests.swift
//  TableSchemer
//
//  Created by James Richard on 7/2/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import XCTest
@testable import TableSchemer
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
        
        schemeSet1 = SchemeSet(schemes: [schemeSet1Scheme1, schemeSet1Scheme2], headerText: "Test Scheme Set")
        schemeSet2 = SchemeSet(schemes: [schemeSet2Scheme1])
        schemeSet3 = SchemeSet(schemes: [schemeSet3Scheme1])
        schemeSet4 = SchemeSet(schemes: [schemeSet4Scheme1, schemeSet4Scheme2, schemeSet4Scheme3], headerText: "Second Test Scheme Set", footerText: "Foo Bar")
        
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
        let cell = subject.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as! SchemeCell
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

    func testCellForRowAtIndexPath_accountsForMultipleHiddenSchemes() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet4Scheme1, inTableView: tableView)
        subject.hideScheme(schemeSet4Scheme2, inTableView: tableView)
        let cell = subject.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 3))
        let configureCall = schemeSet4Scheme3.lastConfigureCall
        XCTAssert(configureCall.cell === cell)
        XCTAssert(configureCall.relativeIndex == 1)
    }
    
    // MARK: Title For Header In Section
    func testTitleForHeaderInSection_whenProvided_isCorrect() {
        XCTAssert(subject.tableView(tableView, titleForHeaderInSection: 0) == schemeSet1.headerText)
    }
    
    func testTitleForHeaderInSection_whenNotProvided_isNil() {
        XCTAssert(subject.tableView(tableView, titleForHeaderInSection: 1) == nil)
    }
    
    func testTitleForHeaderInSection_accountsForHiddenSchemeSets() {
        subject.hideSchemeSet(schemeSet2, inTableView: tableView)
        XCTAssert(subject.tableView(tableView, titleForHeaderInSection: 2) == schemeSet4.headerText)
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
        let cell = tableView.dequeueReusableCellWithIdentifier(TableSchemeTestsReuseIdentifier, forIndexPath: NSIndexPath(forRow: 0, inSection: 2))
        cell.contentView.addSubview(subview)
        let tableMock : AnyObject! = OCMockObject.partialMockForObject(tableView)
        tableMock.stub().andReturn(NSIndexPath(forRow: 0, inSection: 2)).indexPathForCell(cell)
        XCTAssert(subject.schemeContainingView(subview) ===  schemeSet3Scheme1)
    }
    
    func testSchemeWithIndexContainingView_returnsCorrectTuple() {
        let tableView = configuredTableView()
        let subview = UIView()
        let cell = tableView.dequeueReusableCellWithIdentifier(TableSchemeTestsReuseIdentifier, forIndexPath: NSIndexPath(forRow: 2, inSection: 1))
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
        let indexes = subject.attributedSchemeIndexesWithScheme(schemeSet1Scheme1)!
        XCTAssertTrue(subject.attributedSchemeSets[indexes.schemeSetIndex].schemeSet.attributedSchemes[indexes.schemeIndex].hidden)
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
        let indexes = subject.attributedSchemeIndexesWithScheme(schemeSet1Scheme1)!
        XCTAssertFalse(subject.attributedSchemeSets[indexes.schemeSetIndex].schemeSet.attributedSchemes[indexes.schemeIndex].hidden)
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
    
    func testReloadScheme_reloadsEachCellInScheme() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        // Hide a scheme set and scheme to test that it handles hidden objects
        subject.attributedSchemeSets[subject.attributedSchemeSetIndexForSchemeSet(schemeSet1)!].hidden = true

        let indexes = subject.attributedSchemeIndexesWithScheme(schemeSet4Scheme1)!
        subject.attributedSchemeSets[indexes.schemeSetIndex].schemeSet.attributedSchemes[indexes.schemeIndex].hidden = true
        subject.reloadScheme(schemeSet4Scheme3, inTableView: tableView, withRowAnimation: .Fade)
        
        XCTAssert(tableView.callsToReloadRows.count == 1)
        
        if tableView.callsToReloadRows.count == 0 {
            return
        }
        
        XCTAssert(tableView.callsToReloadRows[0].animation == .Fade)
        
        let expectedIndexPaths = [NSIndexPath(forRow: 1, inSection: 2), NSIndexPath(forRow: 2, inSection: 2), NSIndexPath(forRow: 3, inSection: 2), NSIndexPath(forRow: 4, inSection: 2)]
        
        for expectedIndexPath in expectedIndexPaths {
            XCTAssert((tableView.callsToReloadRows[0].indexPaths).indexOf(expectedIndexPath) != nil)
        }
    }
    
    func testReloadScheme_ifSchemeIsHidden_doesntReloadScheme() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        let indexes = subject.attributedSchemeIndexesWithScheme(schemeSet4Scheme3)!
        subject.attributedSchemeSets[indexes.schemeSetIndex].schemeSet.attributedSchemes[indexes.schemeIndex].hidden = true
        subject.reloadScheme(schemeSet4Scheme3, inTableView: tableView, withRowAnimation: .Fade)
        XCTAssert(tableView.callsToReloadRows.count == 0)
    }
    
    func testHideSchemeSet_marksSchemeSetHidden() {
        let tableView = configuredTableView()
        subject.hideSchemeSet(schemeSet1, inTableView: tableView)
        XCTAssertTrue(subject.attributedSchemeSets[subject.attributedSchemeSetIndexForSchemeSet(schemeSet1)!].hidden)
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
        XCTAssertFalse(subject.attributedSchemeSets[subject.attributedSchemeSetIndexForSchemeSet(schemeSet1)!].hidden)
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
    
    func testReloadSchemeSet_reloadsSection() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.attributedSchemeSets[subject.attributedSchemeSetIndexForSchemeSet(schemeSet1)!].hidden = true // Hide a scheme set to test that it handles hidden scheme sets
        subject.reloadSchemeSet(schemeSet4, inTableView: tableView, withRowAnimation: .Fade)
        
        XCTAssert(tableView.callsToReloadSections.count == 1)
        
        if tableView.callsToReloadSections.count == 0 {
            return
        }
        
        XCTAssert(tableView.callsToReloadSections[0].animation == .Fade)
        
        XCTAssert(tableView.callsToReloadSections[0].indexSet == NSIndexSet(index: 2))
    }
    
    func testReloadSchemeSet_ifSchemeSetIsHidden_doesntReloadSchemeSet() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.attributedSchemeSets[subject.attributedSchemeSetIndexForSchemeSet(schemeSet4)!].hidden = true
        subject.reloadSchemeSet(schemeSet4, inTableView: tableView, withRowAnimation: .Fade)
        XCTAssert(tableView.callsToReloadSections.count == 0)
    }
    
    func testBatchSchemeVisibility_updatesSchemesAccordingly() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.hideSchemeSet(schemeSet3, inTableView: tableView)
        subject.hideScheme(schemeSet4Scheme1, inTableView: tableView)
        subject.hideScheme(schemeSet1Scheme1, inTableView: tableView)
        tableView.clearCounters()
        
        subject.batchSchemeVisibilityChangesInTableView(tableView) { animator in
            animator.showScheme(self.schemeSet4Scheme1)
            animator.showScheme(self.schemeSet1Scheme1)
            animator.showSchemeSet(self.schemeSet3)
            
            animator.hideSchemeSet(self.schemeSet2)
            animator.hideScheme(self.schemeSet1Scheme2)
            animator.hideScheme(self.schemeSet4Scheme3)
        }

        XCTAssertEqual(tableView.callsToBeginUpdates, 1)
        XCTAssertEqual(tableView.callsToEndUpdates, 1)
        XCTAssertEqual(tableView.callsToInsertRows.count, 1)
        XCTAssertEqual(tableView.callsToDeleteRows.count, 1)
        XCTAssertEqual(tableView.callsToInsertSections.count, 1)
        XCTAssertEqual(tableView.callsToDeleteSections.count, 1)

        let expectedDeletedIndexPaths = [NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 2), NSIndexPath(forRow: 2, inSection: 2), NSIndexPath(forRow: 3, inSection: 2), NSIndexPath(forRow: 1, inSection: 2), NSIndexPath(forRow: 2, inSection: 2), NSIndexPath(forRow: 4, inSection: 2)]
        let expectedInsertedIndexPaths = [NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 2, inSection: 0), NSIndexPath(forRow: 0, inSection: 2)]

        for expectedDeletedIndexPath in expectedDeletedIndexPaths {
            XCTAssert((tableView.callsToDeleteRows[0].indexPaths).indexOf(expectedDeletedIndexPath) != nil)
        }
        
        for expectedInsertedIndexPath in expectedInsertedIndexPaths {
            XCTAssert((tableView.callsToInsertRows[0].indexPaths).indexOf(expectedInsertedIndexPath) != nil)
        }
        
        XCTAssertTrue(tableView.callsToDeleteSections[0].indexSet.containsIndex(1))
        XCTAssertTrue(tableView.callsToInsertSections[0].indexSet.containsIndex(1))
    }
    
    func testBatchSchemeVisibility_updatesSchemeSets_usingCorrectAnimation() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.hideSchemeSet(schemeSet1, inTableView: tableView)
        subject.hideSchemeSet(schemeSet2, inTableView: tableView)
        tableView.clearCounters()

        subject.batchSchemeVisibilityChangesInTableView(tableView) { animator in
            animator.showSchemeSet(self.schemeSet1, withRowAnimation: .Fade)
            animator.showSchemeSet(self.schemeSet2, withRowAnimation: .Top)
            
            animator.hideSchemeSet(self.schemeSet3, withRowAnimation: .Bottom)
            animator.hideSchemeSet(self.schemeSet4, withRowAnimation: .Left)
        }
        
        XCTAssertEqual(tableView.callsToInsertSections.count, 2)
        XCTAssertEqual(tableView.callsToDeleteSections.count, 2)
        
        for insert in tableView.callsToInsertSections {
            if insert.animation == .Fade {
                XCTAssertEqual(insert.indexSet, NSIndexSet(index: 0))
            } else if insert.animation == .Top {
                XCTAssertEqual(insert.indexSet, NSIndexSet(index: 1))
            } else {
                XCTFail("Unexpected animation in insertions")
            }
        }
        
        for delete in tableView.callsToDeleteSections {
            if delete.animation == .Bottom {
                XCTAssertEqual(delete.indexSet, NSIndexSet(index: 0))
            } else if delete.animation == .Left {
                XCTAssertEqual(delete.indexSet, NSIndexSet(index: 1))
            } else {
                XCTFail("Unexpected animation in deletions")
            }
        }
    }
    
    func testBatchSchemeVisibility_updatesSchemes_usingCorrectAnimation() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.hideScheme(schemeSet1Scheme1, inTableView: tableView)
        subject.hideScheme(schemeSet4Scheme1, inTableView: tableView)
        tableView.clearCounters()
        
        subject.batchSchemeVisibilityChangesInTableView(tableView) { animator in
            animator.showScheme(self.schemeSet1Scheme1, withRowAnimation: .Fade)
            animator.showScheme(self.schemeSet4Scheme1, withRowAnimation: .Top)
            
            animator.hideScheme(self.schemeSet4Scheme2, withRowAnimation: .Bottom)
            animator.hideScheme(self.schemeSet4Scheme3, withRowAnimation: .Left)
        }
        
        XCTAssertEqual(tableView.callsToInsertRows.count, 2)
        XCTAssertEqual(tableView.callsToDeleteRows.count, 2)
        
        for insert in tableView.callsToInsertRows {
            if insert.animation == .Fade {
                // Check for all three cells in indexPaths, any order
                XCTAssert((insert.indexPaths).indexOf(NSIndexPath(forRow: 0, inSection: 0)) != nil)
                XCTAssert((insert.indexPaths).indexOf(NSIndexPath(forRow: 1, inSection: 0)) != nil)
                XCTAssert((insert.indexPaths).indexOf(NSIndexPath(forRow: 2, inSection: 0)) != nil)
            } else if insert.animation == .Top {
                XCTAssertEqual(insert.indexPaths[0], NSIndexPath(forRow: 0, inSection: 3))
            } else {
                XCTFail("Unexpected animation in insertions")
            }
        }
        
        for delete in tableView.callsToDeleteRows {
            if delete.animation == .Bottom {
                XCTAssertEqual(delete.indexPaths[0], NSIndexPath(forRow: 0, inSection: 3))
            } else if delete.animation == .Left {
                // Check for all 4 cells in indexPaths, any order
                XCTAssert((delete.indexPaths).indexOf(NSIndexPath(forRow: 1, inSection: 3)) != nil)
                XCTAssert((delete.indexPaths).indexOf(NSIndexPath(forRow: 2, inSection: 3)) != nil)
                XCTAssert((delete.indexPaths).indexOf(NSIndexPath(forRow: 3, inSection: 3)) != nil)
                XCTAssert((delete.indexPaths).indexOf(NSIndexPath(forRow: 4, inSection: 3)) != nil)
            } else {
                XCTFail("Unexpected animation in deletions")
            }
        }
    }
    
    func testBatchSchemeVisibility_reloadSchemeSet_reloadsUsingCorrectAnimation() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.hideSchemeSet(schemeSet1, inTableView: tableView)
        tableView.clearCounters()
        
        subject.batchSchemeVisibilityChangesInTableView(tableView) { animator in
            animator.reloadSchemeSet(self.schemeSet2, withRowAnimation: .Fade)
            animator.reloadSchemeSet(self.schemeSet4, withRowAnimation: .Top)
            animator.hideSchemeSet(self.schemeSet3)
        }

        XCTAssertEqual(tableView.callsToReloadSections.count, 2)
        
        if tableView.callsToReloadSections.count != 2 {
            return
        }
        
        for reload in tableView.callsToReloadSections {
            if reload.animation == .Fade {
                XCTAssert(reload.indexSet == NSIndexSet(index: 0))
            } else if reload.animation == .Top {
                XCTAssert(reload.indexSet == NSIndexSet(index: 2))
            } else {
                XCTFail("Unexpected animation in reloads")
            }
        }
    }
    
    func testBatchSchemeVisibility_reloadScheme_reloadsUsingCorrectAnimation() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.hideSchemeSet(schemeSet1, inTableView: tableView)
        subject.hideScheme(schemeSet4Scheme1, inTableView: tableView)
        tableView.clearCounters()
        
        subject.batchSchemeVisibilityChangesInTableView(tableView) { animator in
            animator.reloadScheme(self.schemeSet4Scheme3, withRowAnimation: .Top)
            animator.hideScheme(self.schemeSet4Scheme2)
        }
        
        XCTAssertEqual(tableView.callsToReloadRows.count, 1)
        
        if tableView.callsToReloadRows.count != 1 {
            return
        }
        
        let reload = tableView.callsToReloadRows[0]
        
        XCTAssert(reload.animation == .Top)
        
        let expectedIndexPaths = [NSIndexPath(forRow: 1, inSection: 2), NSIndexPath(forRow: 2, inSection: 2), NSIndexPath(forRow: 3, inSection: 2), NSIndexPath(forRow: 4, inSection: 2)]
        
        for ip in expectedIndexPaths {
            XCTAssert((reload.indexPaths).indexOf(ip) != nil)
        }
    }
    
    // MARK: - Scheme Animatability
    // MARK: Explicitly removing rows
    func testAnimateChangesToScheme_withExplicitAnimations_whenRemovingRows_performsCorrectAnimations() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView) { animator in
            animator.deleteObjectAtIndex(0, withRowAnimation: .Fade)
            animator.deleteObjectAtIndex(1, withRowAnimation: .Automatic)
            animator.deleteObjectAtIndex(2, withRowAnimation: .Automatic)
        }
        
        XCTAssertEqual(tableView.callsToDeleteRows.count, 2)
        
        for deletions in tableView.callsToDeleteRows {
            if deletions.animation == .Fade {
                XCTAssert((deletions.indexPaths).indexOf(NSIndexPath(forRow: 2, inSection: 3)) != nil)
            } else if deletions.animation == .Automatic {
                XCTAssert((deletions.indexPaths).indexOf(NSIndexPath(forRow: 3, inSection: 3)) != nil)
                XCTAssert((deletions.indexPaths).indexOf(NSIndexPath(forRow: 4, inSection: 3)) != nil)
            } else {
                XCTFail("Unexpected animation")
            }
        }
    }
    
    func testAnimateChangesToScheme_withExplicitAnimations_whenRemovingRows_byRange_performsCorrectAnimations() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView) { animator in
            animator.deleteObjectsAtIndexes(0...1, withRowAnimation: .Fade)
            animator.deleteObjectsAtIndexes(2...2, withRowAnimation: .Automatic)
        }
        
        XCTAssertEqual(tableView.callsToDeleteRows.count, 2)
        
        for deletions in tableView.callsToDeleteRows {
            if deletions.animation == .Fade {
                XCTAssert((deletions.indexPaths).indexOf(NSIndexPath(forRow: 2, inSection: 3)) != nil)
                XCTAssert((deletions.indexPaths).indexOf(NSIndexPath(forRow: 3, inSection: 3)) != nil)
            } else if deletions.animation == .Automatic {
                XCTAssert((deletions.indexPaths).indexOf(NSIndexPath(forRow: 4, inSection: 3)) != nil)
            } else {
                XCTFail("Unexpected animation")
            }
        }
    }
    
    // MARK: Explicitly adding rows
    
    func testAnimateChangesToScheme_withExplicitAnimations_whenInsertingRows_performsCorrectAnimations() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView) { animator in
            animator.insertObjectAtIndex(0, withRowAnimation: .Fade)
            animator.insertObjectAtIndex(1, withRowAnimation: .Automatic)
            animator.insertObjectAtIndex(2, withRowAnimation: .Automatic)
        }
        
        XCTAssertEqual(tableView.callsToInsertRows.count, 2)
        
        for insertions in tableView.callsToInsertRows {
            if insertions.animation == .Fade {
                XCTAssert((insertions.indexPaths).indexOf(NSIndexPath(forRow: 2, inSection: 3)) != nil)
            } else if insertions.animation == .Automatic {
                XCTAssert((insertions.indexPaths).indexOf(NSIndexPath(forRow: 3, inSection: 3)) != nil)
                XCTAssert((insertions.indexPaths).indexOf(NSIndexPath(forRow: 4, inSection: 3)) != nil)
            } else {
                XCTFail("Unexpected animation")
            }
        }
    }
    
    func testAnimateChangesToScheme_withExplicitAnimations_whenInsertingRows_byRange_performsCorrectAnimations() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView) { animator in
            animator.insertObjectsAtIndexes(0...1, withRowAnimation: .Fade)
            animator.insertObjectsAtIndexes(2...2, withRowAnimation: .Automatic)
        }
        
        XCTAssertEqual(tableView.callsToInsertRows.count, 2)
        
        for insertions in tableView.callsToInsertRows {
            if insertions.animation == .Fade {
                XCTAssert((insertions.indexPaths).indexOf(NSIndexPath(forRow: 2, inSection: 3)) != nil)
                XCTAssert((insertions.indexPaths).indexOf(NSIndexPath(forRow: 3, inSection: 3)) != nil)
            } else if insertions.animation == .Automatic {
                XCTAssert((insertions.indexPaths).indexOf(NSIndexPath(forRow: 4, inSection: 3)) != nil)
            } else {
                XCTFail("Unexpected animation")
            }
        }
    }
    
    // MARK: Explicitly moving rows
    func testAnimateChangesToScheme_withExplicitAnimations_whenMovingRows_performsCorrectAnimations() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView) { animator in
            animator.moveObjectAtIndex(0, toIndex: 2)
            animator.moveObjectAtIndex(1, toIndex: 3)
        }
        
        XCTAssertEqual(tableView.callsToMoveRow.count, 2)
        
        let expected: [(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)] = [(fromIndexPath: NSIndexPath(forRow: 2, inSection: 3), toIndexPath: NSIndexPath(forRow: 4, inSection: 3)), (fromIndexPath: NSIndexPath(forRow: 3, inSection: 3), toIndexPath: NSIndexPath(forRow: 5, inSection: 3))]
        
        for expect in expected {
            XCTAssert(tableView.callsToMoveRow.filter { $0.fromIndexPath == expect.fromIndexPath && $0.toIndexPath == expect.toIndexPath }.count == 1)
        }
    }
    
    // MARK Inferred animations
    func testAnimateChangesToScheme_withInferredAnimations_whenRemovingAnObject_performsCorrectAnimations() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView, withAnimation: .Fade) {
            _ = self.schemeSet4Scheme3.definedNumberOfCells = 3
        }
        
        XCTAssertEqual(tableView.callsToDeleteRows.count, 1)
        XCTAssertEqual(tableView.callsToInsertRows.count, 0)
        XCTAssertEqual(tableView.callsToMoveRow.count, 0)
        
        let deletion = tableView.callsToDeleteRows[0]
        
        XCTAssert(deletion.indexPaths == [NSIndexPath(forRow: 5, inSection: 3)])
        XCTAssert(deletion.animation == .Fade)
    }
    
    func testAnimateChangesToScheme_withInferredAnimations_whenAddingAnObject_performsCorrectAnimations() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView, withAnimation: .Fade) {
            _ = self.schemeSet4Scheme3.definedNumberOfCells = 5
        }
        
        XCTAssertEqual(tableView.callsToDeleteRows.count, 0)
        XCTAssertEqual(tableView.callsToInsertRows.count, 1)
        XCTAssertEqual(tableView.callsToMoveRow.count, 0)
        
        let insertion = tableView.callsToInsertRows[0]
        
        XCTAssert(insertion.indexPaths == [NSIndexPath(forRow: 6, inSection: 3)])
        XCTAssert(insertion.animation == .Fade)
    }
    
    func testAnimateChangesToScheme_withInferredAnimations_whenMovingAnObject_performsCorrectAnimations() {
        schemeSet4Scheme3.identifiers = [0,1,2,3]
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView) {
            _ = self.schemeSet4Scheme3.identifiers = [1,0,2,3]
        }
        
        XCTAssertEqual(tableView.callsToDeleteRows.count, 0)
        XCTAssertEqual(tableView.callsToInsertRows.count, 0)
        XCTAssertEqual(tableView.callsToMoveRow.count, 2)
        
        let orderedMoves = tableView.callsToMoveRow.sort { $0.fromIndexPath.row < $1.fromIndexPath.row }
        
        let move1 = orderedMoves[0]
        let move2 = orderedMoves[1]
        
        XCTAssert(move1.fromIndexPath == NSIndexPath(forRow: 2, inSection: 3))
        XCTAssert(move1.toIndexPath == NSIndexPath(forRow: 3, inSection: 3))
        XCTAssert(move2.fromIndexPath == NSIndexPath(forRow: 3, inSection: 3))
        XCTAssert(move2.toIndexPath == NSIndexPath(forRow: 2, inSection: 3))
    }
    
    func testAnimateChangesToScheme_withInferredAnimations_withEqualObjects_performsCorrectAnimations() {
        schemeSet4Scheme3.identifiers = [1,1,2,3]
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView) {
            _ = self.schemeSet4Scheme3.identifiers = [1,0,2,1]
        }
        
        XCTAssertEqual(tableView.callsToDeleteRows.count, 1)
        XCTAssertEqual(tableView.callsToInsertRows.count, 1)
        XCTAssertEqual(tableView.callsToMoveRow.count, 1)
        
        let deletion = tableView.callsToDeleteRows[0]
        let insertion = tableView.callsToInsertRows[0]
        let move = tableView.callsToMoveRow[0]
        
        XCTAssert(deletion.indexPaths == [NSIndexPath(forRow: 5, inSection: 3)])
        XCTAssert(deletion.animation == .Automatic)
        XCTAssert(insertion.indexPaths == [NSIndexPath(forRow: 3, inSection: 3)])
        XCTAssert(insertion.animation == .Automatic)
        XCTAssert(move.fromIndexPath == NSIndexPath(forRow: 3, inSection: 3))
        XCTAssert(move.toIndexPath == NSIndexPath(forRow: 5, inSection: 3))
    }
    
    // MARK: Test Helpers
    func configuredTableView<T: UITableView>(cellClass: AnyObject.Type = SchemeCell.self) -> T {
        let tableView = T()
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
    var identifiers: [Int]?
    
    public var numberOfCells: Int {
        return definedNumberOfCells
    }
    
    public required init() { }
    
    public func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int)  {
        lastConfigureCall = (cell: cell, relativeIndex: relativeIndex)
    }
    
    public func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int)  {
        lastSelectCall = (cell: cell, tableView: tableView, section: section, rowsBeforeScheme: rowsBeforeScheme, relativeIndex: relativeIndex)
    }
    
    public func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String {
        return TableSchemeTestsReuseIdentifier
    }
    
    public func heightForRelativeIndex(relativeIndex: Int) -> RowHeight {
        return .Custom(height)
    }
}

extension TestableScheme: InferrableRowAnimatableScheme {
    public typealias IdentifierType = Int
    public var rowIdentifiers: [IdentifierType] {
        if let identifiers = identifiers {
            assert(identifiers.count == definedNumberOfCells)
            return identifiers
        }
        
        var inferredIdentifiers = [Int]()
        for i in 0..<definedNumberOfCells {
            inferredIdentifiers.append(i)
        }
        
        return inferredIdentifiers
    }
}

class AnimationRecordingTableView: UITableView {
    var callsToBeginUpdates = 0
    var callsToEndUpdates = 0
    var callsToInsertRows = Array<(indexPaths: [NSIndexPath], animation: UITableViewRowAnimation)>()
    var callsToDeleteRows = Array<(indexPaths: [NSIndexPath], animation: UITableViewRowAnimation)>()
    var callsToInsertSections = Array<(indexSet: NSIndexSet, animation: UITableViewRowAnimation)>()
    var callsToDeleteSections = Array<(indexSet: NSIndexSet, animation: UITableViewRowAnimation)>()
    var callsToMoveRow = Array<(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)>()
    var callsToReloadRows = Array<(indexPaths: [NSIndexPath], animation: UITableViewRowAnimation)>()
    var callsToReloadSections = Array<(indexSet: NSIndexSet, animation: UITableViewRowAnimation)>()
    
    override func insertRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        callsToInsertRows.append((indexPaths: indexPaths, animation: animation))
        super.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
    }
    
    override func deleteRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        callsToDeleteRows.append((indexPaths: indexPaths, animation: animation))
        super.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
    }
    
    override func insertSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
        callsToInsertSections.append((indexSet: sections, animation: animation))
        super.insertSections(sections, withRowAnimation: animation)
    }
    
    override func deleteSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
        callsToDeleteSections.append((indexSet: sections, animation: animation))
        super.deleteSections(sections, withRowAnimation: animation)
    }
    
    override func moveRowAtIndexPath(indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
        callsToMoveRow.append((fromIndexPath: indexPath, toIndexPath: newIndexPath))
        super.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
    }
    
    override func reloadRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        callsToReloadRows.append((indexPaths: indexPaths, animation: animation))
        super.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
    }
    
    override func reloadSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
        callsToReloadSections.append((indexSet: sections, animation: animation))
        super.reloadSections(sections, withRowAnimation: animation)
    }
    
    override func beginUpdates() {
        callsToBeginUpdates++
        super.beginUpdates()
    }
    
    override func endUpdates() {
        callsToEndUpdates++
        super.endUpdates()
    }
    
    func clearCounters() {
        callsToBeginUpdates = 0
        callsToEndUpdates = 0
        callsToInsertRows.removeAll()
        callsToDeleteRows.removeAll()
        callsToInsertSections.removeAll()
        callsToDeleteSections.removeAll()
    }
}
