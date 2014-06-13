//
//  RadioScheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/13/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

class RadioScheme: Scheme {
    typealias ConfigurationHandler = (cell: UITableViewCell, index: Int) -> Void
    typealias SelectionHandler = (cell: UITableViewCell, scheme: RadioScheme, index: Int) -> Void
    
    var selectedIndex: Int = 0
    var reuseIdentifiers: String[]?
    var heights: RowHeight[]?
    var configurationHandler: ConfigurationHandler?
    var selectionHandler: SelectionHandler?
    
    // MARK: Public Instance Methods
    func useReuseIdentifier(reuseIdentifier: String, withNumberOfOptions numberOfOptions: Int) {
        var identifiers = String[]()
        for i in 0..numberOfOptions {
            identifiers.append(reuseIdentifier)
        }
    }
    
    // MARK: Abstract Method Overrides
    override func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int)  {
        configurationHandler!(cell: cell, index: relativeIndex)
        
        if selectedIndex == relativeIndex {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
    }
    
    override func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int) {
        if let sh = selectionHandler {
            sh(cell: cell, scheme: self, index: relativeIndex)
        }
        
        let oldSelectedIndex = selectedIndex
        
        if relativeIndex == oldSelectedIndex {
            return
        }
        
        selectedIndex = relativeIndex
        
        let previouslySelectedCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowsBeforeScheme + oldSelectedIndex, inSection: section))
        previouslySelectedCell.accessoryType = .None
        cell.accessoryType = .Checkmark
    }
    
    override func numberOfCells() -> Int  {
        return countElements(reuseIdentifiers!)
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
}
