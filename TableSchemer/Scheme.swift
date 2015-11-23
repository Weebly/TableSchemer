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
 *
 *  This class can be used as a type of placeholder object for UITableViewCell's. It's used in
 *  conjunction with a TableScheme, which takes an array of SchemeSet objects and for each
 *  row will ask the Scheme for its reuseIdentifier to dequeue a cell, and then call the
 *  configurationHandler to allow setup of the cell based on the scheme of the cell.
 *
 *  This class is an abstract class, and can not be used. You must use a concret subclass for it.
 */
public class Scheme: Equatable {
    /** This property determines how many cells should be represented by this Scheme.
     *  
     *  This is used to determine the size of the table view.
     */
    public var numberOfCells: Int {
        return 1
    }
    
    required public init() { }
    
    /** This method verifies that the Scheme has all the required properties to be used in a TableScheme
     *
     *  This method is used by SchemeSetBuilder. You should not call this method yourself.
     *
     *  @return true if the Scheme is configured with the minimally required properties, or false.
     */
    public func isValid() -> Bool {
        return true
    }

    /**
     *    This method is called by TableScheme when the cell needs
     *    to be created. It will be passed the table creating the cell and
     *    the relative index the cell is from the start of the scheme. For
     *    example, if your scheme has 3 different cells, this will be called
     *    three times with relativeIndexes 0, 1 and 2.
     *
     *    @param cell          The UITableViewCell being created.
     *    @param relativeIndex The cell index from the start of the scheme being configured.
     */
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, relativeIndex: Int) -> UITableViewCell {
        let reuseIdentifier = reuseIdentifierForRelativeIndex(relativeIndex)!
        return tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
    }

    /**
     *    This method is called by TableScheme when the cell needs
     *    to be configured. It will be passed the cell being created and
     *    the relative index the cell is from the start of the scheme. For
     *    example, if your scheme has 3 different cells, this will be called
     *    three times with relativeIndexes 0, 1 and 2. It should be overriden by subclasses.
     *
     *    @param cell          The UITableViewCell being created.
     *    @param relativeIndex The cell index from the start of the scheme being configured.
     */
    public func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int) {
        
    }
    
    /**
     *    This method is called by a TableScheme when the cell
     *    is selected, providing the delegate asks the data source
     *    to handle the selection. This is passed the UITableView, section,
     *    and rowsBeforeScheme so that the selection handler may alter
     *    the table views state if needed. An example of a scheme that
     *    needs this functionality is the accordion scheme. It should be overriden
     *    by subclasses.
     *
     *    @param cell             The UITableViewCell that was selected.
     *    @param tableView        The UITableView the cell belongs to.
     *    @param section          The section that the cell belongs to.
     *    @param rowsBeforeScheme The number of rows before the scheme's first cell.
     *    @param relativeIndex    The index of the row from the scheme's first cell.
     */
    public func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int) {
        
    }
    
    /**
     *    This method is called by TableScheme when the cell
     *    is being configured to determine which reuseIdentifier should
     *    be used to query the table view. It should be overriden by subclasses.
     *
     *    @param relativeIndex The index of the row from the schemes first cell.
     *
     *    @return The reuse identifier to pass into the table views dequeue method.
     */
    public func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String? {
        return nil
    }
    
    /*!
     *    This method is called by TableScheme when the cell's
     *    height is requested, providing the delegate asks the data source
     *    to handle the height. It should be overriden by subclasses.
     *
     *    @param relativeIndex The index of the row from the scheme's first cell.
     *
     *    @return The height to be used for the cell. Use TableHeight.UseTable to use the
     *            tableView's height, otherwise provide TableHeight.Custom(CGFloat) to use 
     *            a custom height
     */
    public func heightForRelativeIndex(relativeIndex: Int) -> RowHeight {
        return .UseTable
    }
}

public func ==(lhs: Scheme, rhs: Scheme) -> Bool {
    return lhs === rhs
}