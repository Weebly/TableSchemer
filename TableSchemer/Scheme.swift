//
//  Scheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/12/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

public enum RowHeight: Equatable {
    case UseTable
    case Custom(CGFloat)
}

public func ==(lhs: RowHeight, rhs: RowHeight) -> Bool {
    switch lhs {
        case .UseTable:
            switch rhs {
                case .UseTable:
                    return true
                case .Custom(_):
                    return false
            }
        case .Custom(let lhsHeight):
            switch rhs {
                case .UseTable:
                    return false
                case .Custom(let rhsHeight):
                    return lhsHeight == rhsHeight
        }
    }
}

/** A Scheme defines one or many rows of a static table view, depending on the type of scheme.

    This protocol can be used as a type of placeholder object for `UITableViewCell`'s. It's used in
    conjunction with a `TableScheme`, which takes an array of `SchemeSet` objects and for each
    row will ask the `Scheme` for its reuseIdentifier to dequeue a cell, and then call the
    configurationHandler to allow setup of the cell based on the scheme of the cell.
 */
public protocol Scheme: class {
    /** This property determines how many cells should be represented by this `Scheme`.
     *  This is used to determine the size of the table view.
     */
    var numberOfCells: Int { get }

    /**
        This method is called by `TableScheme` when the cell needs
        to be configured. It will be passed the cell being created and
        the relative index the cell is from the start of the scheme. For
        example, if your scheme has 3 different cells, this will be called
        three times with relativeIndexes 0, 1 and 2.

        - parameter   cell:          The UITableViewCell being created.
        - parameter   relativeIndex: The cell index from the start of the scheme being configured.
     */
    func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int)
    
    /**
        This method is called by a `TableScheme` when the cell
        is selected, providing the delegate asks the data source
        to handle the selection. This is passed the `UITableView`, section,
        and rowsBeforeScheme so that the selection handler may alter
        the table views state if needed. An example of a scheme that
        needs this functionality is the accordion scheme.

        - parameter                 cell:               The UITableViewCell that was selected.
        - parameter                 tableView:          The UITableView the cell belongs to.
        - parameter                 section:            The section that the cell belongs to.
        - parameter                 rowsBeforeScheme:   The number of rows before the scheme's first cell.
        - parameter                 relativeIndex:      The index of the row from the scheme's first cell.
     */
    func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int)
    
    /**
        This method is called by `TableScheme` when the cell
        is being configured to determine which reuseIdentifier should
        be used to query the table view. By default, this will return a unique
        identifier for each scheme.

        - parameter relativeIndex:    The index of the row from the schemes first cell.
        - returns:                    The reuse identifier to pass into the table views dequeue method.
     */
    func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String
    
    /**
        This method is called by `TableScheme` when the cell's
        height is requested, providing the delegate asks the data source
        to handle the height. It should be overriden by subclasses.

        - parameter relativeIndex:      The index of the row from the scheme's first cell.
        - returns:                      The height to be used for the cell. Use TableHeight.UseTable to use the
                                        tableView's height, otherwise provide TableHeight.Custom(CGFloat) to use
                                        a custom height.
     */
    func heightForRelativeIndex(relativeIndex: Int) -> RowHeight
}

private var uniqueSchemeIdentifier = 0

extension Scheme {

    public final func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, relativeIndex: Int) -> UITableViewCell {
        let reuseIdentifier = reuseIdentifierForRelativeIndex(relativeIndex)
        return tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
    }

    public func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String {
        return "ts-def-id-\(uniqueSchemeIdentifier++)"
    }

    public func heightForRelativeIndex(relativeIndex: Int) -> RowHeight {
        return .UseTable
    }

}
