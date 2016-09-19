//
//  AccordionSchemeBuilder.swift
//  TableSchemer
//
//  Created by James Richard on 11/25/15.
//  Copyright © 2015 Weebly. All rights reserved.
//

open class AccordionSchemeBuilder<CollapsedCellType: UITableViewCell, ExpandedCellType: UITableViewCell>: SchemeBuilder {
    public typealias SchemeType = AccordionScheme<CollapsedCellType, ExpandedCellType>

    public required init() {}

    public func createScheme() throws -> SchemeType {


        guard let collapsedConfigurationHandler = collapsedCellConfigurationHandler else {
            throw SchemeBuilderError.missingRequiredAttribute("collapsedCellConfigurationHandler")
        }

        guard let expandedConfigurationHandler = expandedCellConfigurationHandler else {
            throw SchemeBuilderError.missingRequiredAttribute("expandedCellConfigurationHandler")
        }

        guard let expandedCellTypes = expandedCellTypes else {
            throw SchemeBuilderError.missingRequiredAttribute("expandedCellTypes")
        }

        let scheme = AccordionScheme<CollapsedCellType, ExpandedCellType>(expandedCellTypes: expandedCellTypes, collapsedCellConfigurationHandler: collapsedConfigurationHandler, expandedCellConfigurationHandler: expandedConfigurationHandler)
        scheme.expanded = expanded
        scheme.height = height
        scheme.selectionHandler = collapsedCellSelectionHandler
        scheme.accordionSelectionHandler = expandedCellSelectionHandler
        scheme.selectedIndex = selectedIndex
        scheme.accordionHeights = accordionHeights

        return scheme
    }

    open var expandedCellTypes: [UITableViewCell.Type]?
    open var accordionHeights: [RowHeight]?
    open var selectedIndex = 0
    open var expanded = false
    open var height: RowHeight = .useTable
    open var collapsedCellConfigurationHandler: SchemeType.ConfigurationHandler?
    open var collapsedCellSelectionHandler: SchemeType.SelectionHandler?
    open var expandedCellConfigurationHandler: SchemeType.AccordionConfigurationHandler!
    open var expandedCellSelectionHandler: SchemeType.AccordionSelectionHandler?
    
}
