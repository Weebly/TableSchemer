//
//  BasicScheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/12/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

class BasicScheme: Scheme {
    typealias ConfigurationHandler = (cell: UITableViewCell) -> Void
    typealias SelectionHandler = (cell: UITableViewCell, scheme: BasicScheme) -> Void
    
    var reuseIdentifier: String?
    var height: RowHeight = .UseTable
    var configurationHandler: ConfigurationHandler?
    var selectionHandler: SelectionHandler?
    
    // MARK: Abstract method overrides
    override func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int) {
        configurationHandler!(cell: cell)
    }
    
    override func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int)  {
        if let sh = selectionHandler {
            sh(cell: cell, scheme: self)
        }
    }
    
    override func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String?  {
        return reuseIdentifier!
    }
    
    override func heightForRelativeIndex(relativeIndex: Int) -> RowHeight {
        return height
    }
    
    override func validate() -> Bool  {
        assert(reuseIdentifier != nil)
        assert(configurationHandler != nil)
        return reuseIdentifier != nil && configurationHandler != nil
    }
}
