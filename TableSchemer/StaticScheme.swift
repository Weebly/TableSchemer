//
//  StaticScheme.swift
//  TableSchemer
//
//  Created by Jacob Berkman on 2015-03-20.
//  Copyright (c) 2015 Weebly. All rights reserved.
//

import UIKit

open class StaticScheme<CellType: UITableViewCell>: Scheme, InferrableReuseIdentifierScheme {

    public typealias SelectionHandler = (_ cell: CellType, _ scheme: StaticScheme) -> Void

    /// The precreated cell to use.
    open var cell: CellType

    /// The height the cell should be if asked.
    open var height: RowHeight = .useTable

    /** 
     The closure called when the cell is selected.
     
     NOTE: This is only called if the TableScheme is asked to handle selection
     by the table view delegate.
     */
    open var selectionHandler: SelectionHandler?

    /// StaticScheme's always represent a single cell
    open var numberOfCells: Int { return 1 }

    public init(cell: CellType) {
        self.cell = cell
    }

    open func configureCell(_ cell: UITableViewCell, withRelativeIndex relativeIndex: Int) {
        // noop, static cells should be configured externally
    }

    open func selectCell(_ cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int)  {
        if let sh = selectionHandler {
            sh(cell as! CellType, self)
        }
    }

    open func reuseIdentifier(forRelativeIndex relativeIndex: Int) -> String  {
        return String(describing: CellType.self)
    }

    open func height(forRelativeIndex relativeIndex: Int) -> RowHeight {
        return height
    }

    open var reusePairs: [(identifier: String, cellType: UITableViewCell.Type)] {
        return [(identifier: String(describing: CellType.self), cellType: CellType.self)]
    }

    /// Overriding the default implementation to return our specific cell
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, relativeIndex: Int) -> UITableViewCell {
        return cell
    }
    
}
