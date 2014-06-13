//
//  AccordionScheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/12/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

class AccordionScheme: BasicScheme {
    typealias AccordionConfigurationHandler = (cell: UITableViewCell, index: Int) -> Void
    typealias AccordionSelectionHandler = (cell: UITableViewCell, scheme: AccordionScheme, selectedIndex: Int) -> Void
    
    var accordionReuseIdentifiers: String[]?
    var accordionHeights: RowHeight[]?
    var selectedIndex = 0
    var accordionConfigurationHandler: AccordionConfigurationHandler?
    var accordionSelectionHandler: AccordionSelectionHandler?
    var expanded = false
    
    func numberOfItems() -> Int {
        return countElements(accordionReuseIdentifiers!)
    }
    
    // MARK: Abstract Overrides
    override func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int)  {
        if (expanded) {
            accordionConfigurationHandler!(cell: cell, index: relativeIndex)
        } else {
            super.configureCell(cell, withRelativeIndex: relativeIndex)
        }
    }
    
    override func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int)  {
        var prependedIndexPaths = Array<NSIndexPath>()
        var appendedIndexPaths = Array<NSIndexPath>()
        
        tableView.beginUpdates()
        
        if (expanded) {
            if let ash = accordionSelectionHandler {
                ash(cell: cell, scheme: self, selectedIndex: relativeIndex)
            }
            
            selectedIndex = relativeIndex
            
            for i in 0..relativeIndex {
                let ip = NSIndexPath(forRow: i + rowsBeforeScheme, inSection: section)
                prependedIndexPaths.append(ip)
            }
            
            for i in (relativeIndex + 1)..numberOfItems() {
                let ip = NSIndexPath(forRow: i + rowsBeforeScheme, inSection: section)
                appendedIndexPaths.append(ip)
            }
            
            if countElements(prependedIndexPaths) > 0 {
                tableView.deleteRowsAtIndexPaths(prependedIndexPaths, withRowAnimation: .Fade)
            }
            
            if countElements(appendedIndexPaths) > 0 {
                tableView.deleteRowsAtIndexPaths(appendedIndexPaths, withRowAnimation: .Fade)
            }
        } else {
            super.selectCell(cell, inTableView: tableView, inSection: section, havingRowsBeforeScheme: rowsBeforeScheme, withRelativeIndex: relativeIndex)
            
            for i in 0..selectedIndex {
                let ip = NSIndexPath(forRow: i + rowsBeforeScheme, inSection: section)
                prependedIndexPaths.append(ip)
            }
            
            for i in (relativeIndex + 1)..numberOfItems() {
                let ip = NSIndexPath(forRow: i + rowsBeforeScheme, inSection: section)
                appendedIndexPaths.append(ip)
            }
            
            if countElements(prependedIndexPaths) > 0 {
                tableView.insertRowsAtIndexPaths(prependedIndexPaths, withRowAnimation: .Fade)
            }
            
            if countElements(appendedIndexPaths) > 0 {
                tableView.insertRowsAtIndexPaths(appendedIndexPaths, withRowAnimation: .Fade)
            }
        }
        
        let reloadRow = NSIndexPath(forRow: rowsBeforeScheme + relativeIndex, inSection: section)
        tableView.reloadRowsAtIndexPaths([reloadRow], withRowAnimation: .Automatic)
        
        expanded = !expanded
        
        tableView.endUpdates()
    }
    
    override func numberOfCells() -> Int  {
        return expanded ? numberOfItems() : 1
    }
    
    override func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String?  {
        if expanded {
            return accordionReuseIdentifiers![relativeIndex]
        } else {
            return super.reuseIdentifierForRelativeIndex(relativeIndex)
        }
    }
    
    override func validate() -> Bool {
        assert(accordionReuseIdentifiers != nil)
        assert(countElements(accordionReuseIdentifiers!) > 0)
        assert(accordionConfigurationHandler != nil)
        
        return super.validate() && accordionReuseIdentifiers != nil && accordionConfigurationHandler != nil
    }
}
