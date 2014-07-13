//
//  RadioScheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/13/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

/*
 *    This class is used with a TableScheme to display a radio group of cells.
 *
 *    Use this scheme when you want to have a set of cells that represent
 *    a single selection, similar to a radio group would in HTML.
 *
 *    In order for this scheme to handle changing selection be sure that your 
 *    table view delegate calls TableScheme.handleSelectionInTableView(tableView:forIndexPath:).
 *
 *    It's recommended that you don't create these directly, and let the
 *    SchemeSetBuilder.buildScheme(handler:) method generate them
 *    for you.
 */
class RadioScheme<T: UITableViewCell>: Scheme {
    typealias ConfigurationHandler = (cell: T, index: Int) -> Void
    typealias SelectionHandler = (cell: T, scheme: RadioScheme, index: Int) -> Void
    
    /** The currently selected index. */
    var selectedIndex = 0
    
    /** The reuse identifiers that each cell will use. */
    var reuseIdentifiers: [String]?
    
    /** The heights that the cells should have if asked. */
    var heights: [RowHeight]?
    
    /** The closure called for configuring the cell the scheme is representing. */
    var configurationHandler: ConfigurationHandler?
    
    /** The closure called when the cell is selected.
    *
    *  NOTE: This is only called if the TableScheme is asked to handle selection
    *  by the table view delegate.
    */
    var selectionHandler: SelectionHandler?
    
    @required init() {
        super.init()
    }
    
    // MARK: Property Overrides
    override var numberOfCells: Int {
        return countElements(reuseIdentifiers!)
    }
    
    // MARK: Public Instance Methods
    func useReuseIdentifier(reuseIdentifier: String, withNumberOfOptions numberOfOptions: Int) {
        reuseIdentifiers = [String](count: numberOfOptions, repeatedValue: reuseIdentifier)
    }
    
    // MARK: Abstract Method Overrides
    override func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int)  {
        configurationHandler!(cell: cell as T, index: relativeIndex)
        
        if selectedIndex == relativeIndex {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
    }
    
    override func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int) {
        if let sh = selectionHandler {
            sh(cell: cell as T, scheme: self, index: relativeIndex)
        }
        
        let oldSelectedIndex = selectedIndex
        
        if relativeIndex == oldSelectedIndex {
            return
        }
        
        selectedIndex = relativeIndex
        
        if let previouslySelectedCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowsBeforeScheme + oldSelectedIndex, inSection: section)) {
            previouslySelectedCell.accessoryType = .None
        }
        
        cell.accessoryType = .Checkmark
    }
    
    override func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String?  {
        return reuseIdentifiers![relativeIndex]
    }
    
    override func heightForRelativeIndex(relativeIndex: Int) -> RowHeight  {
        var height = RowHeight.UseTable
        
        if let rowHeights = heights {
            if countElements(rowHeights) > relativeIndex {
                height = rowHeights[relativeIndex]
            }
        }
        
        return height
    }
    
    override func isValid() -> Bool {
        assert(reuseIdentifiers? != nil)
        assert(configurationHandler?)

        return reuseIdentifiers? != nil && configurationHandler?
    }
}

func ==<T: UITableViewCell>(lhs: RadioScheme<T>, rhs: RadioScheme<T>) -> Bool {
    let selectedIndexesEqual = lhs.selectedIndex == rhs.selectedIndex
    var reuseIdentifiersEqual = false
    var heightsEqual = false
    
    if let lrh = lhs.reuseIdentifiers {
        if let rrh = rhs.reuseIdentifiers {
            reuseIdentifiersEqual = lrh == rrh
        }
    }
    
    if let lh = lhs.heights {
        if let rh = rhs.heights {
            heightsEqual = lh == rh
        }
    }
    
    return selectedIndexesEqual && reuseIdentifiersEqual && heightsEqual
}
