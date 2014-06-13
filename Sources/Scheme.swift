//
//  Scheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/12/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

enum RowHeight {
    case UseTable
    case Custom(CGFloat)
}

class Scheme {
    func validate() -> Bool {
        return true
    }
    
    func numberOfCells() -> Int {
        return 1
    }
    
    func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int) {
        
    }
    
    func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int) {
        
    }
    
    func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String? {
        return nil
    }
    
    func heightForRelativeIndex(relativeIndex: Int) -> RowHeight {
        return .UseTable
    }
}