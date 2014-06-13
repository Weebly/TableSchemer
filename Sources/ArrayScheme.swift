//
//  ArrayScheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/12/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

class ArrayScheme<T>: Scheme {
    typealias ConfigurationHandler = (cell: UITableViewCell, object: T) -> Void
    typealias SelectionHandler = (cell: UITableViewCell, scheme: ArrayScheme<T>, object: T) -> Void
    typealias HeightHandler = (object: T) -> CGFloat
    
    var reuseIdentifier: String?
    var objects: T[]?
    var heightHandler: HeightHandler?
    var configurationHandler: ConfigurationHandler?
    var selectionHandler: SelectionHandler?
    
    init() {
        super.init()
    }
    
    // MARK: Abstract Method Overrides
    override func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int) {
        configurationHandler!(cell: cell, object: objects![relativeIndex])
    }
    
    override func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int) {
        if let sh = selectionHandler {
            sh(cell: cell, scheme: self, object: objects![relativeIndex])
        }
    }
    
    override func numberOfCells() -> Int {
        return countElements(objects!)
    }
    
    override func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String? {
        return reuseIdentifier!
    }
    
    override func heightForRelativeIndex(relativeIndex: Int) -> RowHeight {
        if let hh = heightHandler {
            let calculatedHeight = hh(object: objects![relativeIndex])
            return .Custom(calculatedHeight)
        } else {
            return .UseTable
        }
    }
    
    override func validate() -> Bool {
        assert(objects != nil)
        assert(configurationHandler != nil)
        return super.validate() && objects != nil && configurationHandler != nil
    }
}
