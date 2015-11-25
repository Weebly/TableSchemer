//
//  AccordionScheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/12/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

public class AccordionScheme<CollapsedCellType: UITableViewCell, ExpandedCellType: UITableViewCell>: BasicScheme<CollapsedCellType> {
    
    public typealias AccordionConfigurationHandler = (cell: ExpandedCellType, index: Int) -> Void
    public typealias AccordionSelectionHandler = (cell: ExpandedCellType, scheme: AccordionScheme, selectedIndex: Int) -> Void

    public var expandedCellTypes: [UITableViewCell.Type]

    /** The height used for each accordion cell if asked. */
    public var accordionHeights: [RowHeight]?
    
    /** The currently selected index. */
    public var selectedIndex = 0
    
    /** The closure called to handle accordion cells when the accordion is expanded. */
    public var accordionConfigurationHandler: AccordionConfigurationHandler
    
    /** The closure called when an accordion cell is selected.
     *
     *  NOTE: This is only called if the TableScheme is asked to handle selection
     *  by the table view delegate.
     */
    public var accordionSelectionHandler: AccordionSelectionHandler?
    
    /** Whether the accordion is expanded or not. */
    public var expanded = false

    public init(expandedCellTypes: [UITableViewCell.Type], collapsedCellConfigurationHandler: ConfigurationHandler, expandedCellConfigurationHandler: AccordionConfigurationHandler) {
        accordionConfigurationHandler = expandedCellConfigurationHandler
        self.expandedCellTypes = expandedCellTypes
        super.init(configurationHandler: collapsedCellConfigurationHandler)
    }
    
    // MARK: Property Overrides
    public override var numberOfCells: Int {
        return expanded ? numberOfItems : 1
    }
    
    public var numberOfItems: Int {
        return expandedCellTypes.count
    }

    // MARK: Public Instance Methods
    override public func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int)  {
        if expanded {
            accordionConfigurationHandler(cell: cell as! ExpandedCellType, index: relativeIndex)
        } else {
            super.configureCell(cell, withRelativeIndex: relativeIndex)
        }
    }
    
    override public func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int)  {
        var prependedIndexPaths = Array<NSIndexPath>()
        var appendedIndexPaths = Array<NSIndexPath>()
        
        tableView.beginUpdates()
        
        if expanded {
            if let ash = accordionSelectionHandler {
                ash(cell: cell as! ExpandedCellType, scheme: self, selectedIndex: relativeIndex)
            }
            
            selectedIndex = relativeIndex
            
            for i in 0..<relativeIndex {
                let ip = NSIndexPath(forRow: i + rowsBeforeScheme, inSection: section)
                prependedIndexPaths.append(ip)
            }
            
            for i in (relativeIndex + 1)..<numberOfItems {
                let ip = NSIndexPath(forRow: i + rowsBeforeScheme, inSection: section)
                appendedIndexPaths.append(ip)
            }
            
            if prependedIndexPaths.count > 0 {
                tableView.deleteRowsAtIndexPaths(prependedIndexPaths, withRowAnimation: .Fade)
            }
            
            if appendedIndexPaths.count > 0 {
                tableView.deleteRowsAtIndexPaths(appendedIndexPaths, withRowAnimation: .Fade)
            }
        } else {
            super.selectCell(cell, inTableView: tableView, inSection: section, havingRowsBeforeScheme: rowsBeforeScheme, withRelativeIndex: relativeIndex)
            
            for i in 0..<selectedIndex {
                let ip = NSIndexPath(forRow: i + rowsBeforeScheme, inSection: section)
                prependedIndexPaths.append(ip)
            }
            
            for i in (selectedIndex + 1)..<numberOfItems {
                let ip = NSIndexPath(forRow: i + rowsBeforeScheme, inSection: section)
                appendedIndexPaths.append(ip)
            }
            
            if prependedIndexPaths.count > 0 {
                tableView.insertRowsAtIndexPaths(prependedIndexPaths, withRowAnimation: .Fade)
            }
            
            if appendedIndexPaths.count > 0 {
                tableView.insertRowsAtIndexPaths(appendedIndexPaths, withRowAnimation: .Fade)
            }
        }
        
        let reloadRow = NSIndexPath(forRow: rowsBeforeScheme + relativeIndex, inSection: section)
        tableView.reloadRowsAtIndexPaths([reloadRow], withRowAnimation: .Automatic)
        
        expanded = !expanded
        
        tableView.endUpdates()
    }
    
    override public func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String  {
        if expanded {
            return String(expandedCellTypes[relativeIndex])
        } else {
            return super.reuseIdentifierForRelativeIndex(relativeIndex)
        }
    }
    
    override public func heightForRelativeIndex(relativeIndex: Int) -> RowHeight {
        if expanded {
            if accordionHeights != nil && accordionHeights!.count > relativeIndex {
                return accordionHeights![relativeIndex]
            } else {
                return .UseTable
            }
        } else {
            return super.heightForRelativeIndex(relativeIndex)
        }
    }

    override public var reusePairs: [(identifier: String, cellType: UITableViewCell.Type)] {
        return [(identifier: String(CollapsedCellType.self), cellType: CollapsedCellType.self)] + expandedCellTypes.map { (identifier: String($0), cellType: $0) }
    }

}

extension AccordionScheme: InferrableRowAnimatableScheme {

    public typealias IdentifierType = String

    public var rowIdentifiers: [IdentifierType] {
        return expanded ? expandedCellTypes.map { String($0) } : [super.reuseIdentifierForRelativeIndex(0)]
    }

}

