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
class TableScheme: NSObject, UITableViewDataSource {
    typealias BuildHandler = (builder: TableSchemeBuilder) -> Void
    let schemeSets: [SchemeSet]
    
    init(schemeSets: [SchemeSet]) {
        self.schemeSets = schemeSets
    }
    
    convenience init(buildHandler: BuildHandler) {
        let builder = TableSchemeBuilder()
        buildHandler(builder: builder)
        self.init(schemeSets: builder.schemeSets)
    }
    
    // MARK: UITableViewDataSource methods
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return countElements(schemeSets)
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        let schemeSet = schemeSets[section]
        
        return schemeSet.schemes.reduce(0) { (memo: Int, scheme: Scheme) in
            memo + scheme.numberOfCells
        }
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let scheme = schemeAtIndexPath(indexPath)
        let configurationIndex = indexPath.row - rowsBeforeScheme(scheme)
        let reuseIdentifier = scheme.reuseIdentifierForRelativeIndex(configurationIndex)
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        if let schemeCell = cell as? SchemeCell {
            schemeCell.scheme = scheme
        }
        
        scheme.configureCell(cell, withRelativeIndex: configurationIndex)
        
        return cell
    }
    
    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
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
    func handleSelectionInTableView(tableView: UITableView, forIndexPath indexPath:NSIndexPath) {
        let scheme = schemeAtIndexPath(indexPath)
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
    func heightInTableView(tableView: UITableView, forIndexPath indexPath:NSIndexPath) -> CGFloat {
        let scheme = schemeAtIndexPath(indexPath)
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
     *    This method returns the scheme at a given index path. Use this method
     *    in table view delegate methods to find the scheme the cell belongs to.
     *
     *    @param indexPath The index path that will be used to find the scheme
     *
     *    @return The scheme at the index path.
     */
    func schemeAtIndexPath(indexPath: NSIndexPath) -> Scheme {
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
    
    // MARK: Private Methods
    func rowsBeforeScheme(scheme: Scheme) -> Int {
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
    
    func schemeSetWithScheme(scheme: Scheme) -> SchemeSet {
        var foundSet: SchemeSet?
        
        for schemeSet in schemeSets {
            for scanScheme in schemeSet.schemes {
                if scanScheme === scheme {
                    foundSet = schemeSet
                    break
                }
            }
        }
        
        assert(foundSet)
        
        return foundSet!
    }
}
