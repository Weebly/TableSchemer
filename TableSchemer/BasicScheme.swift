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
public class BasicScheme<T: UITableViewCell>: Scheme, InferrableReuseIdentifierScheme {

    public typealias ConfigurationHandler = (cell: T) -> Void
    public typealias SelectionHandler = (cell: T, scheme: BasicScheme) -> Void
    
    /** The reuseIdentifier for this scheme. */
    public var reuseIdentifier: String!
    
    /** The height the cell should be if asked. */
    public var height: RowHeight = .UseTable
    
    /** The closure called to configure the cell the scheme is representing. */
    public var configurationHandler: ConfigurationHandler!
    
    /** The closure called when the cell is selected. 

        NOTE: This is only called if the TableScheme is asked to handle selection
        by the table view delegate.
     */
    public var selectionHandler: SelectionHandler?

    public var numberOfCells: Int { return 1 }

    public init(configurationHandler: ConfigurationHandler) {
        self.configurationHandler = configurationHandler
    }
    
    // MARK: Public Instance Methods
    public func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int) {
        configurationHandler(cell: cell as! T)
    }
    
    public func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int)  {
        if let sh = selectionHandler {
            sh(cell: cell as! T, scheme: self)
        }
    }
    
    public func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String  {
        return String(T.self)
    }
    
    public func heightForRelativeIndex(relativeIndex: Int) -> RowHeight {
        return height
    }

    public var reusePairs: [(identifier: String, cellType: UITableViewCell.Type)] {
        return [(identifier: String(T.self), cellType: T.self)]
    }

}
