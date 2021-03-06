//
//  BasicScheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/12/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

/** This class is used with a `TableScheme` as a single cell.

    Use this scheme when you want to have a single cell.

    It's recommended that you don't create these directly, and let the
    `SchemeSetBuilder.buildScheme(handler:)` method generate them
    for you.
 */
open class BasicScheme<CellType: UITableViewCell>: Scheme, InferrableReuseIdentifierScheme {

    public typealias ConfigurationHandler = (_ cell: CellType) -> Void
    public typealias SelectionHandler = (_ cell: CellType, _ scheme: BasicScheme) -> Void

    /** The height the cell should be if asked. */
    open var height: RowHeight = .useTable
    
    /** The closure called to configure the cell the scheme is representing. */
    open var configurationHandler: ConfigurationHandler
    
    /**
     The closure called when the cell is selected.

     NOTE: This is only called if the TableScheme is asked to handle selection 
     by the table view delegate.
    */
    open var selectionHandler: SelectionHandler?

    open var numberOfCells: Int { return 1 }

    public init(configurationHandler: @escaping ConfigurationHandler) {
        self.configurationHandler = configurationHandler
    }
    
    // MARK: Public Instance Methods
    open func configureCell(_ cell: UITableViewCell, withRelativeIndex relativeIndex: Int) {
        configurationHandler(cell as! CellType)
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

}
