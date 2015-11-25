//
//  AccordionSchemeBuilder.swift
//  TableSchemer
//
//  Created by James Richard on 11/25/15.
//  Copyright © 2015 Weebly. All rights reserved.
//

public class AccordionSchemeBuilder<CollapsedCellType: UITableViewCell, ExpandedCellType: UITableViewCell>: SchemeBuilder {
    public typealias SchemeType = AccordionScheme<CollapsedCellType, ExpandedCellType>

    public required init() {}

    public func createScheme() throws -> SchemeType {


        guard let collapsedConfigurationHandler = collapsedCellConfigurationHandler else {
            throw SchemeBuilderError.MissingRequiredAttribute("collapsedCellConfigurationHandler")
        }

        guard let expandedConfigurationHandler = expandedCellConfigurationHandler else {
            throw SchemeBuilderError.MissingRequiredAttribute("expandedCellConfigurationHandler")
        }

        guard let expandedCellTypes = expandedCellTypes else {
            throw SchemeBuilderError.MissingRequiredAttribute("expandedCellTypes")
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

    public var expandedCellTypes: [UITableViewCell.Type]?
    public var accordionHeights: [RowHeight]?
    public var selectedIndex = 0
    public var expanded = false
    public var height: RowHeight = .UseTable
    public var collapsedCellConfigurationHandler: SchemeType.ConfigurationHandler?
    public var collapsedCellSelectionHandler: SchemeType.SelectionHandler?
    public var expandedCellConfigurationHandler: SchemeType.AccordionConfigurationHandler!
    public var expandedCellSelectionHandler: SchemeType.AccordionSelectionHandler?
    
}
