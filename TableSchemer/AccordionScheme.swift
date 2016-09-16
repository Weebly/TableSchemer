//
//  AccordionScheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/12/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

open class AccordionScheme<CollapsedCellType: UITableViewCell, ExpandedCellType: UITableViewCell>: BasicScheme<CollapsedCellType> {
    
    public typealias AccordionConfigurationHandler = (_ cell: ExpandedCellType, _ index: Int) -> Void
    public typealias AccordionSelectionHandler = (_ cell: ExpandedCellType, _ scheme: AccordionScheme, _ selectedIndex: Int) -> Void

    open var expandedCellTypes: [UITableViewCell.Type]

    /** The height used for each accordion cell if asked. */
    open var accordionHeights: [RowHeight]?
    
    /** The currently selected index. */
    open var selectedIndex = 0
    
    /** The closure called to handle accordion cells when the accordion is expanded. */
    open var accordionConfigurationHandler: AccordionConfigurationHandler
    
    /** The closure called when an accordion cell is selected.
     *
     *  NOTE: This is only called if the TableScheme is asked to handle selection
     *  by the table view delegate.
     */
    open var accordionSelectionHandler: AccordionSelectionHandler?
    
    /** Whether the accordion is expanded or not. */
    open var expanded = false

    public init(expandedCellTypes: [UITableViewCell.Type], collapsedCellConfigurationHandler: @escaping ConfigurationHandler, expandedCellConfigurationHandler: @escaping AccordionConfigurationHandler) {
        accordionConfigurationHandler = expandedCellConfigurationHandler
        self.expandedCellTypes = expandedCellTypes
        super.init(configurationHandler: collapsedCellConfigurationHandler)
    }
    
    // MARK: Property Overrides
    open override var numberOfCells: Int {
        return expanded ? numberOfItems : 1
    }
    
    public var numberOfItems: Int {
        return expandedCellTypes.count
    }

    // MARK: Public Instance Methods
    override open func configureCell(_ cell: UITableViewCell, withRelativeIndex relativeIndex: Int)  {
        if expanded {
            accordionConfigurationHandler(cell as! ExpandedCellType, relativeIndex)
        } else {
            super.configureCell(cell, withRelativeIndex: relativeIndex)
        }
    }
    
    override open func selectCell(_ cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int)  {
        var prependedIndexPaths = Array<IndexPath>()
        var appendedIndexPaths = Array<IndexPath>()
        
        tableView.beginUpdates()
        
        if expanded {
            if let ash = accordionSelectionHandler {
                ash(cell as! ExpandedCellType, self, relativeIndex)
            }
            
            selectedIndex = relativeIndex
            
            for i in 0..<relativeIndex {
                let ip = IndexPath(row: i + rowsBeforeScheme, section: section)
                prependedIndexPaths.append(ip)
            }
            
            for i in (relativeIndex + 1)..<numberOfItems {
                let ip = IndexPath(row: i + rowsBeforeScheme, section: section)
                appendedIndexPaths.append(ip)
            }
            
            if prependedIndexPaths.count > 0 {
                tableView.deleteRows(at: prependedIndexPaths, with: .fade)
            }
            
            if appendedIndexPaths.count > 0 {
                tableView.deleteRows(at: appendedIndexPaths, with: .fade)
            }
        } else {
            super.selectCell(cell, inTableView: tableView, inSection: section, havingRowsBeforeScheme: rowsBeforeScheme, withRelativeIndex: relativeIndex)
            
            for i in 0..<selectedIndex {
                let ip = IndexPath(row: i + rowsBeforeScheme, section: section)
                prependedIndexPaths.append(ip)
            }
            
            for i in (selectedIndex + 1)..<numberOfItems {
                let ip = IndexPath(row: i + rowsBeforeScheme, section: section)
                appendedIndexPaths.append(ip)
            }
            
            if prependedIndexPaths.count > 0 {
                tableView.insertRows(at: prependedIndexPaths, with: .fade)
            }
            
            if appendedIndexPaths.count > 0 {
                tableView.insertRows(at: appendedIndexPaths, with: .fade)
            }
        }
        
        let reloadRow = IndexPath(row: rowsBeforeScheme + relativeIndex, section: section)
        tableView.reloadRows(at: [reloadRow], with: .automatic)
        
        expanded = !expanded
        
        tableView.endUpdates()
    }
    
    override open func reuseIdentifier(forRelativeIndex relativeIndex: Int) -> String  {
        if expanded {
            return String(describing: expandedCellTypes[relativeIndex])
        } else {
            return super.reuseIdentifier(forRelativeIndex: relativeIndex)
        }
    }
    
    override open func height(forRelativeIndex relativeIndex: Int) -> RowHeight {
        if expanded {
            if accordionHeights != nil && accordionHeights!.count > relativeIndex {
                return accordionHeights![relativeIndex]
            } else {
                return .useTable
            }
        } else {
            return super.height(forRelativeIndex: relativeIndex)
        }
    }

    override open var reusePairs: [(identifier: String, cellType: UITableViewCell.Type)] {
        return [(identifier: String(describing: CollapsedCellType.self), cellType: CollapsedCellType.self)] + expandedCellTypes.map { (identifier: String(describing: $0), cellType: $0) }
    }

}

extension AccordionScheme: InferrableRowAnimatableScheme {

    public typealias IdentifierType = String

    public var rowIdentifiers: [IdentifierType] {
        return expanded ? expandedCellTypes.map(String.init(describing:)) : [super.reuseIdentifier(forRelativeIndex: 0)]
    }

}

