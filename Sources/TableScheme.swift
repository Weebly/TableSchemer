//
//  TableScheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/13/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

/**
 *    This class can be used as the data source to a UITableView's dataSource. It
 *    is driven by scheme sets, which are mapped directly to a section in the table
 *    view's index paths. Inside each scheme set is an array of schemes. These
 *    schemes provide varying functionlity and allow you to encapsulate all
 *    information about a particular cell, such as a configuration block or row height, in an object.
 */
public class TableScheme: NSObject, UITableViewDataSource {
    public typealias BuildHandler = (builder: TableSchemeBuilder) -> Void
    public let schemeSets: [SchemeSet]
    
    public init(schemeSets: [SchemeSet]) {
        self.schemeSets = schemeSets
    }
    
    public convenience init(buildHandler: BuildHandler) {
        let builder = TableSchemeBuilder()
        buildHandler(builder: builder)
        self.init(schemeSets: builder.schemeSets)
    }
    
    // MARK: UITableViewDataSource methods
    public func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return countElements(schemeSets)
    }
    
    public func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        let schemeSet = schemeSets[section]
        
        return schemeSet.schemes.reduce(0) { (memo: Int, scheme: Scheme) in
            memo + scheme.numberOfCells
        }
    }
    
    public func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let scheme = schemeAtIndexPath(indexPath)!
        let configurationIndex = indexPath.row - rowsBeforeScheme(scheme)
        let reuseIdentifier = scheme.reuseIdentifierForRelativeIndex(configurationIndex)
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        if let schemeCell = cell as? SchemeCell {
            schemeCell.scheme = scheme
        }
        
        scheme.configureCell(cell, withRelativeIndex: configurationIndex)
        
        return cell
    }
    
    public func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        return schemeSets[section].name
    }
    
    // MARK: Public Instance Methods
    /**
     *    This method handles selection for the table view. It's recommended that you use this
     *    method inside your UITableViewDelegate to handle selection. It will execute the appropriate
     *    selection handler associated to the cell scheme at that index.
     *
     *    @param tableView The table view being selected.
     *    @param indexPath The index path that was selected.
     */
    public func handleSelectionInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) {
        let scheme = schemeAtIndexPath(indexPath)!
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let numberOfRowsBeforeScheme = rowsBeforeScheme(scheme)
        let newSelectedIndex = indexPath.row - numberOfRowsBeforeScheme
        scheme.selectCell(cell, inTableView: tableView, inSection: indexPath.section, havingRowsBeforeScheme: numberOfRowsBeforeScheme, withRelativeIndex: newSelectedIndex)
    }
    
    /**
     *    This method returns the height for the cell at indexPath.
     *
     *    It will ask the scheme for its height using heightForRelativeIndex(relativeIndex:)
     *
     *    @param tableView The table view asking for heights.
     *    @param indexPath The index path of the cell.
     *
     *    @return The height that the cell should be.
     */
    public func heightInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> CGFloat {
        let scheme = schemeAtIndexPath(indexPath)!
        let relativeIndex = indexPath.row - rowsBeforeScheme(scheme)
        let rowHeight = scheme.heightForRelativeIndex(relativeIndex)
        
        switch rowHeight {
            case .UseTable:
                return tableView.rowHeight
            case .Custom(let h):
                return CGFloat(h)
        }
    }
    
    /**
     *    Returns a string containing the SchemeSet's footer text, if it exists.
     *
     *    @param tableView The table view asking for the view.
     *    @param indexPath The index path of the cell.
     *
     *    @return A strin containing the SchemeSet's footer text or nil
     */
    public func tableView(tableView: UITableView!, titleForFooterInSection section: Int) -> String! {
        let schemeSet = schemeSets[section]
        
        if schemeSet.footerText == nil {
            return nil
        }
        
        return schemeSet.footerText
    }
    
    /**
     *    This method returns the scheme at a given index path. Use this method
     *    in table view delegate methods to find the scheme the cell belongs to.
     *
     *    @param indexPath The index path that will be used to find the scheme
     *
     *    @return The scheme at the index path.
     */
    public func schemeAtIndexPath(indexPath: NSIndexPath) -> Scheme? {
        let schemeSet = schemeSets[indexPath.section]
        let row = indexPath.row
        var offset = 0
        
        for (idx, scheme) in enumerate(schemeSet.schemes) {
            if (idx + offset > row) {
                break
            }
            
            if row >= (idx + offset) && row < (idx + offset + scheme.numberOfCells) {
                return scheme
            } else {
                offset += scheme.numberOfCells - 1
            }
        }
        
        return schemeSet[row - offset]
    }
    
    /**
     *      This method returns the scheme contained in a particular view. You would typically use
     *      this method when you have a UIControl sending an action for a view and you need to 
     *      determine the scheme that contains the control.
     *
     *      This view must be contained in the view hierarchey for the UITableView that this
     *      TableScheme is backing.
     *
     *      @param view The view that is contained in the view.
     *     
     *      @return The Scheme that contains the view, or nil if the view does not have a scheme.
     */
    public func schemeContainingView(view: UIView) -> Scheme? {
        if let cell = view.TSR_containingTableViewCell() {
            if let tableView = cell.TSR_containingTableView() {
                assert(tableView.dataSource === self)
                if let indexPath = tableView.indexPathForCell(cell) {
                    if let scheme = schemeAtIndexPath(indexPath) {
                        return scheme
                    }
                }
            }
        }
        
        return nil
    }
    
    /**
    *      This method returns the scheme contained in a particular view along with the offset within
    *      the scheme the chosen cell is at. Its similar to schemeContainingView(view:) -> Scheme?. 
    *
    *      You would typically use this method when you have a UIControl sending an action for a view
    *      that is part of a collection of cells within a scheme.
    *
    *      This view must be contained in the view hierarchey for the UITableView that this
    *      TableScheme is backing.
    *
    *      @param view The view that is contained in the view.
    *
    *      @return A tuple with the Scheme and Index of the cell within the scheme, or nil if 
    *              the view does not have a scheme.
    */
    public func schemeWithIndexContainingView(view: UIView) -> (scheme: Scheme, index: Int)? {
        if let cell = view.TSR_containingTableViewCell() {
            if let tableView = cell.TSR_containingTableView() {
                assert(tableView.dataSource === self)
                if let indexPath = tableView.indexPathForCell(cell) {
                    if let scheme = schemeAtIndexPath(indexPath) {
                        let numberOfRowsBeforeScheme = rowsBeforeScheme(scheme)
                        let offset = indexPath.row - numberOfRowsBeforeScheme
                        return (scheme: scheme, index: offset)
                    }
                }
            }
        }
        
        return nil
    }
    
    private func rowsBeforeScheme(scheme: Scheme) -> Int {
        let schemeSet = schemeSetWithScheme(scheme)
        
        var count = 0
        for scanScheme in schemeSet.schemes {
            if scanScheme === scheme {
                break
            }
            
            count += scanScheme.numberOfCells
        }
        
        return count
    }
    
    private func schemeSetWithScheme(scheme: Scheme) -> SchemeSet {
        var foundSet: SchemeSet?
        
        for schemeSet in schemeSets {
            for scanScheme in schemeSet.schemes {
                if scanScheme === scheme {
                    foundSet = schemeSet
                    break
                }
            }
        }
        
        assert(foundSet != nil)
        
        return foundSet!
    }
}
