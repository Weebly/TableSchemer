//
//  StaticScheme.swift
//  TableSchemer
//
//  Created by Jacob Berkman on 2015-03-20.
//  Copyright (c) 2015 Weebly. All rights reserved.
//

import UIKit

public class StaticScheme<CellType: UITableViewCell>: Scheme, InferrableReuseIdentifierScheme {

    public typealias SelectionHandler = (cell: CellType, scheme: StaticScheme) -> Void

    /// The precreated cell to use.
    public var cell: CellType

    /// The height the cell should be if asked.
    public var height: RowHeight = .UseTable

    /** The closure called when the cell is selected.

        NOTE: This is only called if the TableScheme is asked to handle selection
        by the table view delegate.
     */
    public var selectionHandler: SelectionHandler?

    /// StaticScheme's always represent a single cell
    public var numberOfCells: Int { return 1 }

    public init(cell: CellType) {
        self.cell = cell
    }

    public func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int) {
        // noop, static cells should be configured externally
    }

    public func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int)  {
        if let sh = selectionHandler {
            sh(cell: cell as! CellType, scheme: self)
        }
    }

    public func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String  {
        return String(CellType.self)
    }

    public func heightForRelativeIndex(relativeIndex: Int) -> RowHeight {
        return height
    }

    public var reusePairs: [(identifier: String, cellType: UITableViewCell.Type)] {
        return [(identifier: String(CellType.self), cellType: CellType.self)]
    }

    /// Overriding the default implementation to return our specific cell
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, relativeIndex: Int) -> UITableViewCell {
        return cell
    }
    
}
