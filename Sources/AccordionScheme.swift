//
//  AccordionScheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/12/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

class AccordionScheme<T: UITableViewCell, U: UITableViewCell>: BasicScheme<T> {
    typealias AccordionConfigurationHandler = (cell: U, index: Int) -> Void
    typealias AccordionSelectionHandler = (cell: U, scheme: AccordionScheme, selectedIndex: Int) -> Void
    
    /** The reuse identifiers used by the accordion cells. */
    var accordionReuseIdentifiers: [String]?
    
    /** The height used for each accordion cell if asked. */
    var accordionHeights: [RowHeight]?
    
    /** The currently selected index. */
    var selectedIndex = 0
    
    /** The closure called to handle accordion cells when the accordion is expanded. */
    var accordionConfigurationHandler: AccordionConfigurationHandler?
    
    /** The closure called when an accordion cell is selected.
     *
     *  NOTE: This is only called if the TableScheme is asked to handle selection
     *  by the table view delegate.
     */
    var accordionSelectionHandler: AccordionSelectionHandler?
    
    /** Whether the accordion is expanded or not. */
    var expanded = false
    
    @required init() {
        super.init()
    }
    
    // MARK: Property Overrides
    override var numberOfCells: Int {
        return expanded ? numberOfItems : 1
    }
    
    var numberOfItems: Int {
        return countElements(accordionReuseIdentifiers!)
    }
    
    // MARK: Abstract Overrides
    override func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int)  {
        if (expanded) {
            accordionConfigurationHandler!(cell: cell as U, index: relativeIndex)
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
                ash(cell: cell as U, scheme: self, selectedIndex: relativeIndex)
            }
            
            selectedIndex = relativeIndex
            
            for i in 0..<relativeIndex {
                let ip = NSIndexPath(forRow: i + rowsBeforeScheme, inSection: section)
                prependedIndexPaths.append(ip)
            }
            
            for i in (relativeIndex + 1)..<numberOfItems {
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
            
            for i in 0..<selectedIndex {
                let ip = NSIndexPath(forRow: i + rowsBeforeScheme, inSection: section)
                prependedIndexPaths.append(ip)
            }
            
            for i in (selectedIndex + 1)..<numberOfItems {
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
    
    override func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String?  {
        if expanded {
            return accordionReuseIdentifiers![relativeIndex]
        } else {
            return super.reuseIdentifierForRelativeIndex(relativeIndex)
        }
    }
    
    override func heightForRelativeIndex(relativeIndex: Int) -> RowHeight {
        if expanded {
            if accordionHeights && countElements(accordionHeights!) > relativeIndex {
                return accordionHeights![relativeIndex]
            } else {
                return .UseTable
            }
        } else {
            return super.heightForRelativeIndex(relativeIndex)
        }
    }
    
    override func isValid() -> Bool {
        assert(accordionReuseIdentifiers)
        assert(countElements(accordionReuseIdentifiers!) > 0)
        assert(accordionConfigurationHandler)
        
        return super.isValid() && accordionReuseIdentifiers && accordionConfigurationHandler
    }
}

func ==<T: UITableViewCell, U: UITableViewCell>(lhs: AccordionScheme<T, U>, rhs: AccordionScheme<T, U>) -> Bool {
    let reuseIdentifiersEqual = lhs.reuseIdentifier == rhs.reuseIdentifier
    let heightsEqual = lhs.height == rhs.height
    let selectedIndexesEqual = lhs.selectedIndex == rhs.selectedIndex
    var expandedEqual = lhs.expanded == rhs.expanded
    var accordionReuseIdentifiersEqual = false
    
    if let larh = lhs.accordionReuseIdentifiers {
        if let rarh = rhs.accordionReuseIdentifiers {
            accordionReuseIdentifiersEqual = larh == rarh
        }
    }

    return reuseIdentifiersEqual && heightsEqual && selectedIndexesEqual && expandedEqual && accordionReuseIdentifiersEqual
}
