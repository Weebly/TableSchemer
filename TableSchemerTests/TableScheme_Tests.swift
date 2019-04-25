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
        
        
        tableView = UITableView()
        subject = TableScheme(tableView: tableView, schemeSets: [schemeSet1, schemeSet2, schemeSet3, schemeSet4])
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
        XCTAssertEqual(subject.numberOfSections(in: tableView), 4)
    }
    
    func testNumberOfSections_matchesNumberOfSchemeSets_excludingHiddenSections() {
        subject.hideSchemeSet(schemeSet2, in: tableView)
        XCTAssertEqual(subject.numberOfSections(in: tableView), 3)
    }
    
    // MARK: Number of Rows In Section
    func testNumberOfRowsInSection_matchesSchemeReportedCells() {
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 0), 4)
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 1), 5)
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 2), 1)
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 3), 6)
    }
    
    func testNumberOfRowsInSection_accountsForHiddenSetsAndRows() {
        subject.hideScheme(schemeSet1Scheme2, in: tableView)
        subject.hideSchemeSet(schemeSet2, in: tableView)
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 0), 3)
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 1), 1)
        XCTAssertEqual(subject.tableView(tableView, numberOfRowsInSection: 2), 6)
    }

    // MARK: Cell For Row At Index Path
    func testCellForRowAtIndex_returnsCorrectCellType() {
        let tableView = configuredTableView()
        let cell = subject.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 2))
        XCTAssertTrue(cell is SchemeCell)
    }
    
    func testCellForRowAtIndexPath_setsSchemeOnCell_whenSubclassOfSchemeCell() {
        let tableView = configuredTableView()
        let cell = subject.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 2)) as! SchemeCell
        XCTAssert(cell.scheme === schemeSet3Scheme1)
    }
    
    func testCellForRowAtIndexPath_configuresCellCorrectly_forBasicScheme() {
        let tableView = configuredTableView()
        let cell = subject.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 2))
        let configureCall = schemeSet3Scheme1.lastConfigureCall
        XCTAssert(configureCall?.cell === cell)
        XCTAssert(configureCall?.relativeIndex == 0)
    }
    
    func testCellForRowAtIndexPath_configuresCellCorrectly_forSchemeBelowLargeScheme() {
        let tableView = configuredTableView()
        let cell = subject.tableView(tableView, cellForRowAt: IndexPath(row: 3, section: 0))
        let configureCall = schemeSet1Scheme2.lastConfigureCall
        XCTAssert(configureCall?.cell === cell)
        XCTAssert(configureCall?.relativeIndex == 0)
    }
    
    func testCellForRowAtIndexPath_configuresCellCorrectly_forLargeScheme() {
        let tableView = configuredTableView()
        let cell = subject.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 0))
        let configureCall = schemeSet1Scheme1.lastConfigureCall
        XCTAssert(configureCall?.cell === cell)
        XCTAssert(configureCall?.relativeIndex == 2)
    }
    
    func testCellForRowAtIndexPath_accountsForHiddenSchemesAndSchemeSets() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet4Scheme1, in: tableView)
        subject.hideSchemeSet(schemeSet2, in: tableView)
        let cell = subject.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 2))
        let configureCall = schemeSet4Scheme3.lastConfigureCall
        XCTAssert(configureCall?.cell === cell)
        XCTAssert(configureCall?.relativeIndex == 1)
    }

    func testCellForRowAtIndexPath_accountsForMultipleHiddenSchemes() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet4Scheme1, in: tableView)
        subject.hideScheme(schemeSet4Scheme2, in: tableView)
        let cell = subject.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 3))
        let configureCall = schemeSet4Scheme3.lastConfigureCall
        XCTAssert(configureCall?.cell === cell)
        XCTAssert(configureCall?.relativeIndex == 1)
    }
    
    // MARK: Title For Header In Section
    func testTitleForHeaderInSection_whenProvided_isCorrect() {
        XCTAssert(subject.tableView(tableView, titleForHeaderInSection: 0) == schemeSet1.headerText)
    }
    
    func testTitleForHeaderInSection_whenNotProvided_isNil() {
        XCTAssert(subject.tableView(tableView, titleForHeaderInSection: 1) == nil)
    }
    
    func testTitleForHeaderInSection_accountsForHiddenSchemeSets() {
        subject.hideSchemeSet(schemeSet2, in: tableView)
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
        subject.hideSchemeSet(schemeSet2, in: tableView)
        XCTAssert(subject.tableView(tableView, titleForFooterInSection: 2) == schemeSet4.footerText)
    }

    // MARK: Handling Selection
    func testHandleSelectionInTableView_sendsCorrectSelection_forBasicScheme() {
        let tableView = configuredTableView()
        let indexPath = IndexPath(row: 0, section: 2)
        let cell = subject.tableView(tableView, cellForRowAt: indexPath)
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        _  = ((tableMock.stub() as AnyObject).andReturn(cell) as AnyObject).cellForRow(at: indexPath)

        subject.tableView(tableView, didSelectRowAt: indexPath)
        let selectCall = schemeSet3Scheme1.lastSelectCall
        
        XCTAssert(selectCall?.cell === cell)
        XCTAssert(selectCall?.tableView === tableView)
        XCTAssertEqual(selectCall?.section, 2)
        XCTAssertEqual(selectCall?.rowsBeforeScheme, 0)
        XCTAssertEqual(selectCall?.relativeIndex, 0)
    }
    
    func testHandleSelectionInTableView_sendsCorrectSelection_forSchemeBelowLargeScheme() {
        let tableView = configuredTableView()
        let indexPath = IndexPath(row: 3, section: 0)
        let cell = subject.tableView(tableView, cellForRowAt: indexPath)
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        _  = ((tableMock.stub() as AnyObject).andReturn(cell) as AnyObject).cellForRow(at: indexPath)
        
        subject.tableView(tableView, didSelectRowAt: indexPath)
        let selectCall = schemeSet1Scheme2.lastSelectCall
        
        XCTAssert(selectCall?.cell === cell)
        XCTAssert(selectCall?.tableView === tableView)
        XCTAssertEqual(selectCall?.section, 0)
        XCTAssertEqual(selectCall?.rowsBeforeScheme, 3)
        XCTAssertEqual(selectCall?.relativeIndex, 0)
    }
    
    func testHandleSelectionInTableView_sendsCorrectSelection_forLargeScheme() {
        let tableView = configuredTableView()
        let indexPath = IndexPath(row: 2, section: 0)
        let cell = subject.tableView(tableView, cellForRowAt: indexPath)
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        _  = ((tableMock.stub() as AnyObject).andReturn(cell) as AnyObject).cellForRow(at: indexPath)
        
        subject.tableView(tableView, didSelectRowAt: indexPath)
        let selectCall = schemeSet1Scheme1.lastSelectCall
        
        XCTAssert(selectCall?.cell === cell)
        XCTAssert(selectCall?.tableView === tableView)
        XCTAssertEqual(selectCall?.section, 0)
        XCTAssertEqual(selectCall?.rowsBeforeScheme, 0)
        XCTAssertEqual(selectCall?.relativeIndex, 2)
    }
    
    func testHandleSelectionInTableView_accoutsForHiddenSchemesAndSchemeSets() {
        let tableView = configuredTableView()
        subject.hideSchemeSet(schemeSet2, in: tableView)
        subject.hideScheme(schemeSet4Scheme1, in: tableView)
        let indexPath = IndexPath(row: 3, section: 2)
        let cell = subject.tableView(tableView, cellForRowAt: indexPath)
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        _  = ((tableMock.stub() as AnyObject).andReturn(cell) as AnyObject).cellForRow(at: indexPath)
        
        subject.tableView(tableView, didSelectRowAt: indexPath)
        let selectCall = schemeSet4Scheme3.lastSelectCall
        
        XCTAssert(selectCall?.cell === cell)
        XCTAssert(selectCall?.tableView === tableView)
        XCTAssertEqual(selectCall?.section, 2)
        XCTAssertEqual(selectCall?.rowsBeforeScheme, 1)
        XCTAssertEqual(selectCall?.relativeIndex, 2)
    }
    
    // MARK: Height In Table View
    func testHeightInTableView_returnsCorrectHeight() {
        let tableView = configuredTableView()
        let height = subject.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(height, CGFloat(44.0))
    }
    
    func testHeightInTableView_accountsForHiddenSchemesAndSchemeSets() {
        let tableView = configuredTableView()
        subject.hideSchemeSet(schemeSet2, in: tableView)
        subject.hideScheme(schemeSet4Scheme1, in: tableView)
        let height = subject.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 2))
        XCTAssertEqual(height, CGFloat(schemeSet4Scheme2.height))
    }
    
    // MARK: Scheme At Index Path
    func testSchemeAtIndexPath_returnsCorrectScheme() {
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 0, section: 0)) === schemeSet1Scheme1)
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 1, section: 0)) === schemeSet1Scheme1)
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 2, section: 0)) === schemeSet1Scheme1)
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 3, section: 0)) === schemeSet1Scheme2)
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 0, section: 1)) === schemeSet2Scheme1)
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 1, section: 1)) === schemeSet2Scheme1)
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 2, section: 1)) === schemeSet2Scheme1)
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 3, section: 1)) === schemeSet2Scheme1)
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 4, section: 1)) === schemeSet2Scheme1)
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 0, section: 2)) === schemeSet3Scheme1)
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 0, section: 3)) === schemeSet4Scheme1)
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 1, section: 3)) === schemeSet4Scheme2)
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 2, section: 3)) === schemeSet4Scheme3)
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 3, section: 3)) === schemeSet4Scheme3)
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 4, section: 3)) === schemeSet4Scheme3)
        XCTAssert(subject.schemeAtIndexPath(IndexPath(row: 5, section: 3)) === schemeSet4Scheme3)
    }
    
    // MARK: Finding a Scheme within a View
    func testSchemeContainingView_returnsCorrectScheme() {
        let tableView = configuredTableView()
        let subview = UIView()
        let cell = tableView.dequeueReusableCell(withIdentifier: TableSchemeTestsReuseIdentifier, for: IndexPath(row: 0, section: 2))
        cell.contentView.addSubview(subview)
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        _  = ((tableMock.stub() as AnyObject).andReturn(IndexPath(row: 0, section: 2)) as AnyObject).indexPath(for: cell)
        XCTAssert(subject.scheme(containing: subview) ===  schemeSet3Scheme1)
    }
    
    func testSchemeWithIndexContainingView_returnsCorrectTuple() {
        let tableView = configuredTableView()
        let subview = UIView()
        let cell = tableView.dequeueReusableCell(withIdentifier: TableSchemeTestsReuseIdentifier, for: IndexPath(row: 2, section: 1))
        cell.contentView.addSubview(subview)
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        _  = ((tableMock.stub() as AnyObject).andReturn(IndexPath(row: 2, section: 1)) as AnyObject).indexPath(for: cell)
        let tuple = subject.schemeWithIndex(containing: subview)
        XCTAssert(tuple?.scheme === schemeSet2Scheme1)
        XCTAssertEqual(tuple?.index, 2)
    }
    
    // MARK: Scheme Visibility

    func testIsSchemeSetHidden_whenSetDoesntBelongToTableScheme_returnsNil() {
        let schemeSet = SchemeSet(attributedSchemes: [])
        XCTAssertNil(subject.isSchemeSetHidden(schemeSet))
    }

    func testIsSchemeSetHidden_whenSchemeSetBelongsToTableScheme_andIsHidden_returnsTrue() {
        subject.hideSchemeSet(schemeSet1, in: tableView)
        XCTAssert(subject.isSchemeSetHidden(schemeSet1) == true)
    }

    func testIsSchemeSetHidden_whenSchemeSetBelongsToTableScheme_andIsNotHidden_returnsFalse() {
        XCTAssert(subject.isSchemeSetHidden(schemeSet1) == false)
    }

    func testIsSchemeHidden_whenSchemeDoesntBelongToTableScheme_returnsNil() {
        let scheme = TestableScheme()
        XCTAssertNil(subject.isSchemeHidden(scheme))
    }

    func testIsSchemeHidden_whenSchemeBelongsToTableScheme_andIsHidden_returnsTrue() {
        subject.hideScheme(schemeSet1Scheme1, in: tableView)
        XCTAssert(subject.isSchemeHidden(schemeSet1Scheme1) == true)
    }

    func testIsSchemeHidden_whenSchemeBelongsToTableScheme_andIsNotHidden_returnsFalse() {
        XCTAssert(subject.isSchemeHidden(schemeSet1Scheme1) == false)
    }

    func testHideScheme_marksSchemeHidden() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet1Scheme1, in: tableView)
        let indexes = subject.attributedSchemeIndexesWithScheme(schemeSet1Scheme1)!
        XCTAssertTrue(subject.attributedSchemeSets[indexes.schemeSetIndex].schemeSet.attributedSchemes[indexes.schemeIndex].hidden)
    }
    
    func testHideScheme_performsHideAnimationForEachCellInScheme() {
        let tableView = configuredTableView()
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        (tableMock.expect() as AnyObject).deleteRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .automatic)
        
        subject.hideScheme(schemeSet1Scheme1, in: tableView)
        
        _ = tableMock.verify()
    }
    
    func testHideScheme_performsHideAnimationForEachCellInScheme_withSpecifiedAnimation() {
        let tableView = configuredTableView()
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        (tableMock.expect() as AnyObject).deleteRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .fade)
        
        subject.hideScheme(schemeSet1Scheme1, in: tableView, with: .fade)

        _ = tableMock.verify()
    }
    
    func testHideScheme_performsHideAnimationInCorrectSection() {
        let tableView = configuredTableView()
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        (tableMock.expect() as AnyObject).deleteRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
        
        subject.hideScheme(schemeSet3Scheme1, in: tableView)
        
        _ = tableMock.verify()
    }
    
    func testHideScheme_forOffsettedScheme_performsHideAnimationInRows() {
        let tableView = configuredTableView()
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        (tableMock.expect() as AnyObject).deleteRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
        
        subject.hideScheme(schemeSet1Scheme2, in: tableView)
        
        _ = tableMock.verify()
    }
    
    func testShowScheme_marksSchemeVisible() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet1Scheme1, in: tableView)
      
        subject.showScheme(schemeSet1Scheme1, in: tableView)
        let indexes = subject.attributedSchemeIndexesWithScheme(schemeSet1Scheme1)!
        XCTAssertFalse(subject.attributedSchemeSets[indexes.schemeSetIndex].schemeSet.attributedSchemes[indexes.schemeIndex].hidden)
    }
    
    func testShowScheme_performsShowAnimationForEachCellInScheme() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet1Scheme1, in: tableView)
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        (tableMock.expect() as AnyObject).insertRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .automatic)
        
        subject.showScheme(schemeSet1Scheme1, in: tableView)
        
        _ = tableMock.verify()
    }
    
    func testShowScheme_performsHideAnimationForEachCellInScheme_withSpecifiedAnimation() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet1Scheme1, in: tableView)
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        (tableMock.expect() as AnyObject).insertRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .fade)
        
        subject.showScheme(schemeSet1Scheme1, in: tableView, with: .fade)
        
        _ = tableMock.verify()
    }
    
    func testShowScheme_performsShowAnimationInCorrectSection() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet3Scheme1, in: tableView)
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        (tableMock.expect() as AnyObject).insertRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)

        subject.showScheme(schemeSet3Scheme1, in: tableView)
        
        _ = tableMock.verify()
    }
    
    func testShowScheme_forOffsettedScheme_performsShowAnimationInRows() {
        let tableView = configuredTableView()
        subject.hideScheme(schemeSet1Scheme2, in: tableView)
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        (tableMock.expect() as AnyObject).insertRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
        
        subject.showScheme(schemeSet1Scheme2, in: tableView)
        
        _ = tableMock.verify()
    }
    
    func testReloadScheme_reloadsEachCellInScheme() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        // Hide a scheme set and scheme to test that it handles hidden objects
        subject.attributedSchemeSets[subject.attributedSchemeSetIndexForSchemeSet(schemeSet1)!].hidden = true

        let indexes = subject.attributedSchemeIndexesWithScheme(schemeSet4Scheme1)!
        subject.attributedSchemeSets[indexes.schemeSetIndex].schemeSet.attributedSchemes[indexes.schemeIndex].hidden = true
        subject.reloadScheme(schemeSet4Scheme3, in: tableView, with: .fade)
        
        XCTAssert(tableView.callsToReloadRows.count == 1)
        
        if tableView.callsToReloadRows.count == 0 {
            return
        }
        
        XCTAssert(tableView.callsToReloadRows[0].animation == .fade)
        
        let expectedIndexPaths = [IndexPath(row: 1, section: 2), IndexPath(row: 2, section: 2), IndexPath(row: 3, section: 2), IndexPath(row: 4, section: 2)]
        
        for expectedIndexPath in expectedIndexPaths {
            XCTAssert((tableView.callsToReloadRows[0].indexPaths).firstIndex(of: expectedIndexPath) != nil)
        }
    }
    
    func testReloadScheme_ifSchemeIsHidden_doesntReloadScheme() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        let indexes = subject.attributedSchemeIndexesWithScheme(schemeSet4Scheme3)!
        subject.attributedSchemeSets[indexes.schemeSetIndex].schemeSet.attributedSchemes[indexes.schemeIndex].hidden = true
        subject.reloadScheme(schemeSet4Scheme3, in: tableView, with: .fade)
        XCTAssert(tableView.callsToReloadRows.count == 0)
    }
    
    func testHideSchemeSet_marksSchemeSetHidden() {
        let tableView = configuredTableView()
        subject.hideSchemeSet(schemeSet1, in: tableView)
        XCTAssertTrue(subject.attributedSchemeSets[subject.attributedSchemeSetIndexForSchemeSet(schemeSet1)!].hidden)
    }
    
    func testHideSchemeSet_performsHideAnimationForSchemeSet() {
        let tableView = configuredTableView()
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        (tableMock.expect() as AnyObject).deleteSections(IndexSet(integer: 0), with: .automatic)
        
        subject.hideSchemeSet(schemeSet1, in: tableView)

        _ = tableMock.verify()
    }
    
    func testHideSchemeSet_performsHideAnimationForSchemeSet_withSpecifiedAnimation() {
        let tableView = configuredTableView()
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        (tableMock.expect() as AnyObject).deleteSections(IndexSet(integer: 0), with: .fade)
        
        subject.hideSchemeSet(schemeSet1, in: tableView, with: .fade)
        
        _ = tableMock.verify()
    }
    
    func testHideSchemeSet_forOffsettedSchemeSet_performsHideAnimationOnCorrectSection() {
        let tableView = configuredTableView()
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        (tableMock.expect() as AnyObject).deleteSections(IndexSet(integer: 2), with: .automatic)
        
        subject.hideSchemeSet(schemeSet3, in: tableView)
        
        _ = tableMock.verify()
    }
    
    func testShowSchemeSet_marksSchemeSetVisible() {
        let tableView = configuredTableView()
        subject.hideSchemeSet(schemeSet1, in: tableView)
        subject.showSchemeSet(schemeSet1, in: tableView)
        XCTAssertFalse(subject.attributedSchemeSets[subject.attributedSchemeSetIndexForSchemeSet(schemeSet1)!].hidden)
    }
    
    func testShowSchemeSet_performsShowAnimationForSchemeSet() {
        let tableView = configuredTableView()
        subject.hideSchemeSet(schemeSet1, in: tableView)
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        (tableMock.expect() as AnyObject).insertSections(IndexSet(integer: 0), with: .automatic)
        
        subject.showSchemeSet(schemeSet1, in: tableView)
        
        _ = tableMock.verify()
    }
    
    func testShowSchemeSet_performsShowAnimationForSchemeSet_withSpecifiedAnimation() {
        let tableView = configuredTableView()
        subject.hideSchemeSet(schemeSet1, in: tableView, with: .fade)
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        (tableMock.expect() as AnyObject).insertSections(IndexSet(integer: 0), with: .fade)
        
        subject.showSchemeSet(schemeSet1, in: tableView, with: .fade)
        
        _ = tableMock.verify()
    }
    
    func testShowSchemeSet_forOffsettedSchemeSet_performsShowAnimationOnCorrectSection() {
        let tableView = configuredTableView()
        subject.hideSchemeSet(schemeSet3, in: tableView)
        let tableMock = OCMockObject.partialMock(for: tableView) as AnyObject
        (tableMock.expect() as AnyObject).insertSections(IndexSet(integer: 2), with: .automatic)
        
        subject.showSchemeSet(schemeSet3, in: tableView)
        
        _ = tableMock.verify()
    }
    
    func testReloadSchemeSet_reloadsSection() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.attributedSchemeSets[subject.attributedSchemeSetIndexForSchemeSet(schemeSet1)!].hidden = true // Hide a scheme set to test that it handles hidden scheme sets
        subject.reloadSchemeSet(schemeSet4, in: tableView, with: .fade)
        
        XCTAssert(tableView.callsToReloadSections.count == 1)
        
        if tableView.callsToReloadSections.count == 0 {
            return
        }
        
        XCTAssert(tableView.callsToReloadSections[0].animation == .fade)
        
        XCTAssert(tableView.callsToReloadSections[0].indexSet == IndexSet(integer: 2))
    }
    
    func testReloadSchemeSet_ifSchemeSetIsHidden_doesntReloadSchemeSet() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.attributedSchemeSets[subject.attributedSchemeSetIndexForSchemeSet(schemeSet4)!].hidden = true
        subject.reloadSchemeSet(schemeSet4, in: tableView, with: .fade)
        XCTAssert(tableView.callsToReloadSections.count == 0)
    }
    
    func testBatchSchemeVisibility_updatesSchemesAccordingly() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.hideSchemeSet(schemeSet3, in: tableView)
        subject.hideScheme(schemeSet4Scheme1, in: tableView)
        subject.hideScheme(schemeSet1Scheme1, in: tableView)
        tableView.clearCounters()
        
        subject.batchSchemeVisibilityChanges(in: tableView) { animator in
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

        let expectedDeletedIndexPaths = [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 2), IndexPath(row: 2, section: 2), IndexPath(row: 3, section: 2), IndexPath(row: 1, section: 2), IndexPath(row: 2, section: 2), IndexPath(row: 4, section: 2)]
        let expectedInsertedIndexPaths = [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0), IndexPath(row: 0, section: 2)]

        for expectedDeletedIndexPath in expectedDeletedIndexPaths {
            XCTAssert((tableView.callsToDeleteRows[0].indexPaths).firstIndex(of: expectedDeletedIndexPath) != nil)
        }
        
        for expectedInsertedIndexPath in expectedInsertedIndexPaths {
            XCTAssert((tableView.callsToInsertRows[0].indexPaths).firstIndex(of: expectedInsertedIndexPath) != nil)
        }
        
        XCTAssertTrue(tableView.callsToDeleteSections[0].indexSet.contains(1))
        XCTAssertTrue(tableView.callsToInsertSections[0].indexSet.contains(1))
    }
    
    func testBatchSchemeVisibility_updatesSchemeSets_usingCorrectAnimation() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.hideSchemeSet(schemeSet1, in: tableView)
        subject.hideSchemeSet(schemeSet2, in: tableView)
        tableView.clearCounters()

        subject.batchSchemeVisibilityChanges(in: tableView) { animator in
            animator.showSchemeSet(self.schemeSet1, with: .fade)
            animator.showSchemeSet(self.schemeSet2, with: .top)
            
            animator.hideSchemeSet(self.schemeSet3, with: .bottom)
            animator.hideSchemeSet(self.schemeSet4, with: .left)
        }
        
        XCTAssertEqual(tableView.callsToInsertSections.count, 2)
        XCTAssertEqual(tableView.callsToDeleteSections.count, 2)
        
        for insert in tableView.callsToInsertSections {
            if insert.animation == .fade {
                XCTAssertEqual(insert.indexSet, IndexSet(integer: 0))
            } else if insert.animation == .top {
                XCTAssertEqual(insert.indexSet, IndexSet(integer: 1))
            } else {
                XCTFail("Unexpected animation in insertions")
            }
        }
        
        for delete in tableView.callsToDeleteSections {
            if delete.animation == .bottom {
                XCTAssertEqual(delete.indexSet, IndexSet(integer: 0))
            } else if delete.animation == .left {
                XCTAssertEqual(delete.indexSet, IndexSet(integer: 1))
            } else {
                XCTFail("Unexpected animation in deletions")
            }
        }
    }
    
    func testBatchSchemeVisibility_updatesSchemes_usingCorrectAnimation() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.hideScheme(schemeSet1Scheme1, in: tableView)
        subject.hideScheme(schemeSet4Scheme1, in: tableView)
        tableView.clearCounters()
        
        subject.batchSchemeVisibilityChanges(in: tableView) { animator in
            animator.showScheme(self.schemeSet1Scheme1, with: .fade)
            animator.showScheme(self.schemeSet4Scheme1, with: .top)

            animator.hideScheme(self.schemeSet4Scheme2, with: .bottom)
            animator.hideScheme(self.schemeSet4Scheme3, with: .left)
        }
        
        XCTAssertEqual(tableView.callsToInsertRows.count, 2)
        XCTAssertEqual(tableView.callsToDeleteRows.count, 2)
        
        for insert in tableView.callsToInsertRows {
            if insert.animation == .fade {
                // Check for all three cells in indexPaths, any order
                XCTAssert((insert.indexPaths).firstIndex(of: IndexPath(row: 0, section: 0)) != nil)
                XCTAssert((insert.indexPaths).firstIndex(of: IndexPath(row: 1, section: 0)) != nil)
                XCTAssert((insert.indexPaths).firstIndex(of: IndexPath(row: 2, section: 0)) != nil)
            } else if insert.animation == .top {
                XCTAssertEqual(insert.indexPaths[0], IndexPath(row: 0, section: 3))
            } else {
                XCTFail("Unexpected animation in insertions")
            }
        }
        
        for delete in tableView.callsToDeleteRows {
            if delete.animation == .bottom {
                XCTAssertEqual(delete.indexPaths[0], IndexPath(row: 0, section: 3))
            } else if delete.animation == .left {
                // Check for all 4 cells in indexPaths, any order
                XCTAssert((delete.indexPaths).firstIndex(of: IndexPath(row: 1, section: 3)) != nil)
                XCTAssert((delete.indexPaths).firstIndex(of: IndexPath(row: 2, section: 3)) != nil)
                XCTAssert((delete.indexPaths).firstIndex(of: IndexPath(row: 3, section: 3)) != nil)
                XCTAssert((delete.indexPaths).firstIndex(of: IndexPath(row: 4, section: 3)) != nil)
            } else {
                XCTFail("Unexpected animation in deletions")
            }
        }
    }
    
    func testBatchSchemeVisibility_reloadSchemeSet_reloadsUsingCorrectAnimation() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.hideSchemeSet(schemeSet1, in: tableView)
        tableView.clearCounters()
        
        subject.batchSchemeVisibilityChanges(in: tableView) { animator in
            animator.reloadSchemeSet(self.schemeSet2, with: .fade)
            animator.reloadSchemeSet(self.schemeSet4, with: .top)
            animator.hideSchemeSet(self.schemeSet3)
        }

        XCTAssertEqual(tableView.callsToReloadSections.count, 2)
        
        if tableView.callsToReloadSections.count != 2 {
            return
        }
        
        for reload in tableView.callsToReloadSections {
            if reload.animation == .fade {
                XCTAssert(reload.indexSet == IndexSet(integer: 0))
            } else if reload.animation == .top {
                XCTAssert(reload.indexSet == IndexSet(integer: 2))
            } else {
                XCTFail("Unexpected animation in reloads")
            }
        }
    }
    
    func testBatchSchemeVisibility_reloadScheme_reloadsUsingCorrectAnimation() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.hideSchemeSet(schemeSet1, in: tableView)
        subject.hideScheme(schemeSet4Scheme1, in: tableView)
        tableView.clearCounters()
        
        subject.batchSchemeVisibilityChanges(in: tableView) { animator in
            animator.reloadScheme(self.schemeSet4Scheme3, with: .top)
            animator.hideScheme(self.schemeSet4Scheme2)
        }
        
        XCTAssertEqual(tableView.callsToReloadRows.count, 1)
        
        if tableView.callsToReloadRows.count != 1 {
            return
        }
        
        let reload = tableView.callsToReloadRows[0]
        
        XCTAssert(reload.animation == .top)
        
        let expectedIndexPaths = [IndexPath(row: 1, section: 2), IndexPath(row: 2, section: 2), IndexPath(row: 3, section: 2), IndexPath(row: 4, section: 2)]
        
        for ip in expectedIndexPaths {
            XCTAssert((reload.indexPaths).firstIndex(of: ip) != nil)
        }
    }
    
    // MARK: - Scheme Animatability
    // MARK: Explicitly removing rows
    func testAnimateChangesToScheme_withExplicitAnimations_whenRemovingRows_performsCorrectAnimations() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView) { animator in
            animator.deleteObject(at: 0, with: .fade)
            animator.deleteObject(at: 1, with: .automatic)
            animator.deleteObject(at: 2, with: .automatic)
        }
        
        XCTAssertEqual(tableView.callsToDeleteRows.count, 2)
        
        for deletions in tableView.callsToDeleteRows {
            if deletions.animation == .fade {
                XCTAssert((deletions.indexPaths).firstIndex(of: IndexPath(row: 2, section: 3)) != nil)
            } else if deletions.animation == .automatic {
                XCTAssert((deletions.indexPaths).firstIndex(of: IndexPath(row: 3, section: 3)) != nil)
                XCTAssert((deletions.indexPaths).firstIndex(of: IndexPath(row: 4, section: 3)) != nil)
            } else {
                XCTFail("Unexpected animation")
            }
        }
    }
    
    func testAnimateChangesToScheme_withExplicitAnimations_whenRemovingRows_byRange_performsCorrectAnimations() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView) { animator in
            animator.deleteObjects(at: 0...1, with: .fade)
            animator.deleteObjects(at: 2...2, with: .automatic)
        }
        
        XCTAssertEqual(tableView.callsToDeleteRows.count, 2)
        
        for deletions in tableView.callsToDeleteRows {
            if deletions.animation == .fade {
                XCTAssert((deletions.indexPaths).firstIndex(of: IndexPath(row: 2, section: 3)) != nil)
                XCTAssert((deletions.indexPaths).firstIndex(of: IndexPath(row: 3, section: 3)) != nil)
            } else if deletions.animation == .automatic {
                XCTAssert((deletions.indexPaths).firstIndex(of: IndexPath(row: 4, section: 3)) != nil)
            } else {
                XCTFail("Unexpected animation")
            }
        }
    }
    
    // MARK: Explicitly adding rows
    
    func testAnimateChangesToScheme_withExplicitAnimations_whenInsertingRows_performsCorrectAnimations() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView) { animator in
            animator.insertObject(at: 0, with: .fade)
            animator.insertObject(at: 1, with: .automatic)
            animator.insertObject(at: 2, with: .automatic)
        }
        
        XCTAssertEqual(tableView.callsToInsertRows.count, 2)
        
        for insertions in tableView.callsToInsertRows {
            if insertions.animation == .fade {
                XCTAssert((insertions.indexPaths).firstIndex(of: IndexPath(row: 2, section: 3)) != nil)
            } else if insertions.animation == .automatic {
                XCTAssert((insertions.indexPaths).firstIndex(of: IndexPath(row: 3, section: 3)) != nil)
                XCTAssert((insertions.indexPaths).firstIndex(of: IndexPath(row: 4, section: 3)) != nil)
            } else {
                XCTFail("Unexpected animation")
            }
        }
    }
    
    func testAnimateChangesToScheme_withExplicitAnimations_whenInsertingRows_byRange_performsCorrectAnimations() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView) { animator in
            animator.insertObjects(at: 0...1, with: .fade)
            animator.insertObjects(at: 2...2, with: .automatic)
        }
        
        XCTAssertEqual(tableView.callsToInsertRows.count, 2)
        
        for insertions in tableView.callsToInsertRows {
            if insertions.animation == .fade {
                XCTAssert((insertions.indexPaths).firstIndex(of: IndexPath(row: 2, section: 3)) != nil)
                XCTAssert((insertions.indexPaths).firstIndex(of: IndexPath(row: 3, section: 3)) != nil)
            } else if insertions.animation == .automatic {
                XCTAssert((insertions.indexPaths).firstIndex(of: IndexPath(row: 4, section: 3)) != nil)
            } else {
                XCTFail("Unexpected animation")
            }
        }
    }
    
    // MARK: Explicitly moving rows
    func testAnimateChangesToScheme_withExplicitAnimations_whenMovingRows_performsCorrectAnimations() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView) { animator in
            animator.moveObject(at: 0, to: 2)
            animator.moveObject(at: 1, to: 3)
        }
        
        XCTAssertEqual(tableView.callsToMoveRow.count, 2)
        
        let expected: [(fromIndexPath: IndexPath, toIndexPath: IndexPath)] = [(fromIndexPath: IndexPath(row: 2, section: 3), toIndexPath: IndexPath(row: 4, section: 3)), (fromIndexPath: IndexPath(row: 3, section: 3), toIndexPath: IndexPath(row: 5, section: 3))]
        
        for expect in expected {
            XCTAssert(tableView.callsToMoveRow.filter { $0.fromIndexPath == expect.fromIndexPath && $0.toIndexPath == expect.toIndexPath }.count == 1)
        }
    }
    
    // MARK Inferred animations
    func testAnimateChangesToScheme_withInferredAnimations_whenRemovingAnObject_performsCorrectAnimations() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView, withAnimation: .fade) {
            _ = self.schemeSet4Scheme3.definedNumberOfCells = 3
        }
        
        XCTAssertEqual(tableView.callsToDeleteRows.count, 1)
        XCTAssertEqual(tableView.callsToInsertRows.count, 0)
        XCTAssertEqual(tableView.callsToMoveRow.count, 0)
        
        let deletion = tableView.callsToDeleteRows[0]
        
        XCTAssert(deletion.indexPaths == [IndexPath(row: 5, section: 3)])
        XCTAssert(deletion.animation == .fade)
    }
    
    func testAnimateChangesToScheme_withInferredAnimations_whenAddingAnObject_performsCorrectAnimations() {
        let tableView: AnimationRecordingTableView = configuredTableView()
        subject.animateChangesToScheme(schemeSet4Scheme3, inTableView: tableView, withAnimation: .fade) {
            _ = self.schemeSet4Scheme3.definedNumberOfCells = 5
        }
        
        XCTAssertEqual(tableView.callsToDeleteRows.count, 0)
        XCTAssertEqual(tableView.callsToInsertRows.count, 1)
        XCTAssertEqual(tableView.callsToMoveRow.count, 0)
        
        let insertion = tableView.callsToInsertRows[0]
        
        XCTAssert(insertion.indexPaths == [IndexPath(row: 6, section: 3)])
        XCTAssert(insertion.animation == .fade)
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
        
        let orderedMoves = tableView.callsToMoveRow.sorted { $0.fromIndexPath.row < $1.fromIndexPath.row }
        
        let move1 = orderedMoves[0]
        let move2 = orderedMoves[1]
        
        XCTAssert(move1.fromIndexPath == IndexPath(row: 2, section: 3))
        XCTAssert(move1.toIndexPath == IndexPath(row: 3, section: 3))
        XCTAssert(move2.fromIndexPath == IndexPath(row: 3, section: 3))
        XCTAssert(move2.toIndexPath == IndexPath(row: 2, section: 3))
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
        
        XCTAssert(deletion.indexPaths == [IndexPath(row: 5, section: 3)])
        XCTAssert(deletion.animation == .automatic)
        XCTAssert(insertion.indexPaths == [IndexPath(row: 3, section: 3)])
        XCTAssert(insertion.animation == .automatic)
        XCTAssert(move.fromIndexPath == IndexPath(row: 3, section: 3))
        XCTAssert(move.toIndexPath == IndexPath(row: 5, section: 3))
    }
    
    // MARK: Handlers
    
    func testScrollViewDidScrollHandler() {
        let expectation = self.expectation(description: "scroll view handler called")
        subject.scrollViewDidScrollHandler = { scrollView in
            XCTAssert(scrollView === self.tableView)
            expectation.fulfill()
        }
        
        subject.scrollViewDidScroll(tableView)
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // MARK: Test Helpers
    func configuredTableView<T: UITableView>(_ cellClass: AnyObject.Type = SchemeCell.self) -> T {
        let tableView = T()
        tableView.register(cellClass, forCellReuseIdentifier: TableSchemeTestsReuseIdentifier)
        tableView.dataSource = subject
        
        return tableView
    }
}

open class TestableScheme: Scheme {
    var lastConfigureCall: (cell: UITableViewCell, relativeIndex: Int)!
    var lastSelectCall: (cell: UITableViewCell, tableView: UITableView, section: Int, rowsBeforeScheme: Int, relativeIndex: Int)!
    
    var definedNumberOfCells = 1
    var height: CGFloat = 44.0
    var identifiers: [Int]?
    
    open var numberOfCells: Int {
        return definedNumberOfCells
    }
    
    public required init() { }
    
    open func configureCell(_ cell: UITableViewCell, withRelativeIndex relativeIndex: Int)  {
        lastConfigureCall = (cell: cell, relativeIndex: relativeIndex)
    }
    
    open func selectCell(_ cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int)  {
        lastSelectCall = (cell: cell, tableView: tableView, section: section, rowsBeforeScheme: rowsBeforeScheme, relativeIndex: relativeIndex)
    }
    
    open func reuseIdentifier(forRelativeIndex relativeIndex: Int) -> String {
        return TableSchemeTestsReuseIdentifier
    }
    
    open func height(forRelativeIndex relativeIndex: Int) -> RowHeight {
        return .custom(height)
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
    var callsToInsertRows = Array<(indexPaths: [IndexPath], animation: UITableView.RowAnimation)>()
    var callsToDeleteRows = Array<(indexPaths: [IndexPath], animation: UITableView.RowAnimation)>()
    var callsToInsertSections = Array<(indexSet: IndexSet, animation: UITableView.RowAnimation)>()
    var callsToDeleteSections = Array<(indexSet: IndexSet, animation: UITableView.RowAnimation)>()
    var callsToMoveRow = Array<(fromIndexPath: IndexPath, toIndexPath: IndexPath)>()
    var callsToReloadRows = Array<(indexPaths: [IndexPath], animation: UITableView.RowAnimation)>()
    var callsToReloadSections = Array<(indexSet: IndexSet, animation: UITableView.RowAnimation)>()
    
    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        callsToInsertRows.append((indexPaths: indexPaths, animation: animation))
        super.insertRows(at: indexPaths, with: animation)
    }
    
    override func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        callsToDeleteRows.append((indexPaths: indexPaths, animation: animation))
        super.deleteRows(at: indexPaths, with: animation)
    }
    
    override func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        callsToInsertSections.append((indexSet: sections, animation: animation))
        super.insertSections(sections, with: animation)
    }
    
    override func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        callsToDeleteSections.append((indexSet: sections, animation: animation))
        super.deleteSections(sections, with: animation)
    }
    
    override func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        callsToMoveRow.append((fromIndexPath: indexPath, toIndexPath: newIndexPath))
        super.moveRow(at: indexPath, to: newIndexPath)
    }
    
    override func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        callsToReloadRows.append((indexPaths: indexPaths, animation: animation))
        super.reloadRows(at: indexPaths, with: animation)
    }
    
    override func reloadSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        callsToReloadSections.append((indexSet: sections, animation: animation))
        super.reloadSections(sections, with: animation)
    }
    
    override func beginUpdates() {
        callsToBeginUpdates += 1
        super.beginUpdates()
    }
    
    override func endUpdates() {
        callsToEndUpdates += 1
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
