//
//  ArrayScheme_Tests.swift
//  TableSchemer
//
//  Created by James Richard on 6/14/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import XCTest
import UIKit
import TableSchemer

class ArrayScheme_Tests: XCTestCase {
    let ReuseIdentifier = "ReuseIdentifier"
    var subject: ArrayScheme<String>!
    
    // MARK: Setup and Teardown
    override func tearDown() {
        subject = nil
        super.tearDown()
    }
    
    // MARK: Validation
    func testValidate_withAllRequiredProperties_returnsYES() {
        configureSubjectWithObjects()
        XCTAssertTrue(subject.isValid())
    }
    
    // MARK: Abstract Method Overrides
    func testConfigureCell_callsConfigurationBlockWithCellAndObject() {
        var passedCell1: UITableViewCell?
        var passedCell2: UITableViewCell?
        
        configureSubjectWithObjects(["One", "Two"], configurationHandler: {(cell, object) in
            if object == "One" {
                passedCell1 = cell
            } else if object == "Two" {
                passedCell2 = cell
            }
        })
        
        let configureCell1 = UITableViewCell()
        let configureCell2 = UITableViewCell()
        
        subject.configureCell(configureCell1, withRelativeIndex: 0)
        subject.configureCell(configureCell2, withRelativeIndex: 1)
        
        XCTAssert(passedCell1 === configureCell1)
        XCTAssert(passedCell2 === configureCell2)
    }
    
    func testSelectCell_callsSelectBlockWithCellAndSelfAndObject() {
        var passedCell: UITableViewCell?
        var passedScheme: ArrayScheme<String>?
        var passedObject: String?
        
        let string1 = "One"
        let string2 = "Two"
        
        configureSubjectWithObjects([string1, string2], selectionHandler: { (cell, scheme, object) in
            passedCell = cell
            passedScheme = scheme
            passedObject = object
        })
        
        let tableView = UITableView()
        let cell = UITableViewCell()
        
        subject.selectCell(cell, inTableView: tableView, inSection: 0, havingRowsBeforeScheme: 0, withRelativeIndex: 0)
        
        XCTAssert(passedCell === cell)
        XCTAssert(passedScheme === subject)
        XCTAssert(passedObject == string1)
    }
    
    func testNumberOfCells_matchesObjectCount() {
        configureSubjectWithObjects(["One", "Two"])
        XCTAssert(subject.numberOfCells == 2)
    }
    
    func testReuseIdentifierForRelativeIndex_isReuseIdentifier() {
        configureSubjectWithObjects()
        XCTAssertEqual(subject.reuseIdentifierForRelativeIndex(0)!, ReuseIdentifier)
    }
    
    func testHeightForRelativeIndex_usesCallbackHeight() {
        let string1 = "One"
        let string2 = "Two"
        
        configureSubjectWithObjects([string1, string2])
        subject.heightHandler = {(object) in
            if object == string1 {
                return .Custom(44.0)
            } else if object == string2 {
                return .Custom(80.0)
            }
            
            return .UseTable
        }
        
        XCTAssertEqual(subject.heightForRelativeIndex(0), RowHeight.Custom(44))
        XCTAssertEqual(subject.heightForRelativeIndex(1), RowHeight.Custom(80.0))
    }
    
    // MARK: Test Configuration
    func configureSubjectWithObjects(_ objects: [String] = [], configurationHandler: ArrayScheme<String>.ConfigurationHandler = {(cell, object) in}, selectionHandler: ArrayScheme<String>.SelectionHandler = {(cell, scheme, object) in})  {
        subject = ArrayScheme<String>()
        subject.reuseIdentifier = ReuseIdentifier
        subject.objects = objects
        subject.configurationHandler = configurationHandler
        subject.selectionHandler = selectionHandler
    }
}
