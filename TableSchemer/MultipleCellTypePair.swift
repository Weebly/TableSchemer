//
//  MultipleCellTypePair.swift
//  TableSchemer
//
//  Created by James Richard on 11/25/15.
//  Copyright © 2015 Weebly. All rights reserved.
//

public struct MultipleCellTypePair {

    public var cellType: UITableViewCell.Type
    public var identifier: String

    public init(cellType: UITableViewCell.Type, identifier: String) {
        self.cellType = cellType
        self.identifier = identifier
    }
    
}
