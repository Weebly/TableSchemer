//
//  RadioScheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/13/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

/** This class is used with a `TableScheme` to display a radio group of cells.

    Use this scheme when you want to have a set of cells that represent
    a single selection, similar to a radio group would in HTML.

    In order for this scheme to handle changing selection be sure that your
    table view delegate calls `TableScheme.handleSelectionInTableView(tableView:forIndexPath:)`.

    It's recommended that you don't create these directly, and let the
    `SchemeSetBuilder.buildScheme(handler:)` method generate them
    for you.
 */
open class RadioScheme<CellType: UITableViewCell>: Scheme {
    
    public typealias ConfigurationHandler = (_ cell: CellType, _ index: Int) -> Void
    public typealias SelectionHandler = (_ cell: CellType, _ scheme: RadioScheme, _ index: Int) -> Void
    public typealias StateHandler = (_ cell: CellType, _ scheme: RadioScheme, _ index: Int, _ selected: Bool) -> Void
    
    /** The currently selected index. */
    open var selectedIndex = 0
    
    /** The reuse identifiers that each cell will use. */
    open var expandedCellTypes: [UITableViewCell.Type]
    
    /** The heights that the cells should have if asked. */
    open var heights: [RowHeight]?
    
    /** The closure called for configuring the cell the scheme is representing. */
    open var configurationHandler: ConfigurationHandler
    
    /** 
     The closure called when the cell is selected.
     
     NOTE: This is only called if the TableScheme is asked to handle selection
     by the table view delegate.
     */
    open var selectionHandler: SelectionHandler?

    /**
     The closure called when a cells selection state should be updated. By
     default, this will update the accessory type to `.checkmark` for the selected
     cell, and `.none` for a deselected cell.

     Do not use this closure as a way to handle selection; assign a selectionHandler
     instead as this closure is called during configuration as well.
     */
    open var stateHandler: StateHandler = { cell, _, _, selected in
        cell.accessoryType = selected ? .checkmark : .none
    }

    public init(expandedCellTypes: [UITableViewCell.Type], configurationHandler: @escaping ConfigurationHandler) {
        self.expandedCellTypes = expandedCellTypes
        self.configurationHandler = configurationHandler
    }
    
    // MARK: Property Overrides
    open var numberOfCells: Int {
        return reusePairs.count
    }
    
    // MARK: Public Instance Methods
    
    open func configureCell(_ cell: UITableViewCell, withRelativeIndex relativeIndex: Int)  {
        configurationHandler(cell as! CellType, relativeIndex)
        stateHandler(cell as! CellType, self, relativeIndex, selectedIndex == relativeIndex)
    }
    
    open func selectCell(_ cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int) {
        if let sh = selectionHandler {
            sh(cell as! CellType, self, relativeIndex)
        }
        
        let oldSelectedIndex = selectedIndex
        
        if relativeIndex == oldSelectedIndex {
            return
        }
        
        selectedIndex = relativeIndex
        
        if let previouslySelectedCell = tableView.cellForRow(at: IndexPath(row: rowsBeforeScheme + oldSelectedIndex, section: section)) {
            stateHandler(previouslySelectedCell as! CellType, self, oldSelectedIndex, false)
        }

        stateHandler(cell as! CellType, self, relativeIndex, true)
    }
    
    open func reuseIdentifier(forRelativeIndex relativeIndex: Int) -> String {
        return String(describing: expandedCellTypes[relativeIndex])
    }
    
    open func height(forRelativeIndex relativeIndex: Int) -> RowHeight {
        var height = RowHeight.useTable
        
        if let rowHeights = heights , rowHeights.count > relativeIndex {
            height = rowHeights[relativeIndex]
        }
        
        return height
    }

}

extension RadioScheme: InferrableReuseIdentifierScheme {

    public var reusePairs: [(identifier: String, cellType: UITableViewCell.Type)] {
        return expandedCellTypes.map { (identifier: String(describing: $0), cellType: $0) }
    }

}
