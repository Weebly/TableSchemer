//
//  StaticScheme.swift
//  TableSchemer
//
//  Created by Jacob Berkman on 2015-03-20.
//  Copyright (c) 2015 Weebly. All rights reserved.
//

import UIKit

public class StaticScheme<T: UITableViewCell>: BasicScheme<T> {

    /** The precreated cell to use. */
    public var cell: T?

    required public init() {
        super.init()
    }

    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, relativeIndex: Int) -> UITableViewCell {
        return cell!
    }

    override public func isValid() -> Bool  {
        assert(cell != nil)
        return cell != nil
    }

}
