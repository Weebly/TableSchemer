//
//  StaticScheme.swift
//  TableSchemer
//
//  Created by Jacob Berkman on 2015-03-20.
//  Copyright (c) 2015 Weebly. All rights reserved.
//

import UIKit

public class StaticScheme<CellType: UITableViewCell>: BasicScheme<CellType> {

    /** The precreated cell to use. */
    public var cell: CellType

    public init(cell: CellType, configurationHandler: ConfigurationHandler) {
        self.cell = cell
        super.init(configurationHandler: configurationHandler)
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, relativeIndex: Int) -> UITableViewCell {
        return cell
    }
    
}
