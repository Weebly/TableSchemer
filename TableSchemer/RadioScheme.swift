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
public class RadioScheme<T: UITableViewCell>: Scheme {
    public typealias ConfigurationHandler = (cell: T, index: Int) -> Void
    public typealias SelectionHandler = (cell: T, scheme: RadioScheme, index: Int) -> Void
    
    /** The currently selected index. */
    public var selectedIndex = 0
    
    /** The reuse identifiers that each cell will use. */
    public var reuseIdentifiers: [String]!
    
    /** The heights that the cells should have if asked. */
    public var heights: [RowHeight]?
    
    /** The closure called for configuring the cell the scheme is representing. */
    public var configurationHandler: ConfigurationHandler!
    
    /** The closure called when the cell is selected.
    *
    *  NOTE: This is only called if the TableScheme is asked to handle selection
    *  by the table view delegate.
    */
    public var selectionHandler: SelectionHandler?
    
    required public init() {
        super.init()
    }
    
    // MARK: Property Overrides
    override public var numberOfCells: Int {
        return count(reuseIdentifiers)
    }
    
    // MARK: Public Instance Methods
    public func useReuseIdentifier(reuseIdentifier: String, withNumberOfOptions numberOfOptions: Int) {
        reuseIdentifiers = [String](count: numberOfOptions, repeatedValue: reuseIdentifier)
    }
    
    // MARK: Abstract Method Overrides
    override public func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int)  {
        configurationHandler(cell: cell as! T, index: relativeIndex)
        
        if selectedIndex == relativeIndex {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
    }
    
    override public func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int) {
        if let sh = selectionHandler {
            sh(cell: cell as! T, scheme: self, index: relativeIndex)
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
    
    override public func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String?  {
        return reuseIdentifiers[relativeIndex]
    }
    
    override public func heightForRelativeIndex(relativeIndex: Int) -> RowHeight  {
        var height = RowHeight.UseTable
        
        if let rowHeights = heights {
            if count(rowHeights) > relativeIndex {
                height = rowHeights[relativeIndex]
            }
        }
        
        return height
    }
    
    override public func isValid() -> Bool {
        assert(reuseIdentifiers != nil)
        assert(configurationHandler != nil)

        return reuseIdentifiers != nil && configurationHandler != nil
    }
}

public func ==<T: UITableViewCell>(lhs: RadioScheme<T>, rhs: RadioScheme<T>) -> Bool {
    let selectedIndexesEqual = lhs.selectedIndex == rhs.selectedIndex
    var reuseIdentifiersEqual = lhs.reuseIdentifiers == rhs.reuseIdentifiers
    var heightsEqual = true
    
    if let lh = lhs.heights {
        if let rh = rhs.heights {
            heightsEqual = lh == rh
        } else {
            heightsEqual = false
        }
    } else {
        if rhs.heights != nil {
            heightsEqual = false
        }
    }
    
    return selectedIndexesEqual && reuseIdentifiersEqual && heightsEqual
}
