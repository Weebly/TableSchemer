//
//  RadioSchemeBuilder.swift
//  TableSchemer
//
//  Created by James Richard on 11/25/15.
//  Copyright © 2015 Weebly. All rights reserved.
//

open class RadioSchemeBuilder<CellType: UITableViewCell>: SchemeBuilder {

    public typealias SchemeType = RadioScheme<CellType>

    public required init() {}

    open var configurationHandler: SchemeType.ConfigurationHandler?
    open var selectionHandler: SchemeType.SelectionHandler?
    open var appearanceHandler: SchemeType.AppearanceHandler?
    open var expandedCellTypes: [UITableViewCell.Type]?
    open var selectedIndex = 0
    open var heights: [RowHeight]?

    public func createScheme() throws -> SchemeType {
        guard let configurationHandler = configurationHandler else {
            throw SchemeBuilderError.missingRequiredAttribute("configurationHandler")
        }

        guard let expandedCellTypes = expandedCellTypes else {
            throw SchemeBuilderError.missingRequiredAttribute("expandedCellTypes")
        }

        let scheme = SchemeType(expandedCellTypes: expandedCellTypes, configurationHandler: configurationHandler)
        scheme.heights = heights
        scheme.selectedIndex = selectedIndex
        scheme.selectionHandler = selectionHandler

        if let appearanceHandler = appearanceHandler {
            scheme.appearanceHandler = appearanceHandler
        }

        return scheme
    }
    
}
