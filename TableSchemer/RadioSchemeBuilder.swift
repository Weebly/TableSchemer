//
//  RadioSchemeBuilder.swift
//  TableSchemer
//
//  Created by James Richard on 11/25/15.
//  Copyright © 2015 Weebly. All rights reserved.
//

public class RadioSchemeBuilder<CellType: UITableViewCell>: SchemeBuilder {

    public typealias SchemeType = RadioScheme<CellType>

    public required init() {}

    public var configurationHandler: SchemeType.ConfigurationHandler?
    public var selectionHandler: SchemeType.SelectionHandler?
    public var expandedCellTypes: [MultipleCellTypePair]?
    public var selectedIndex = 0
    public var heights: [RowHeight]?

    public func createScheme() throws -> SchemeType {
        guard let configurationHandler = configurationHandler else {
            throw SchemeBuilderError.MissingRequiredAttribute("configurationHandler")
        }

        guard let expandedCellTypes = expandedCellTypes else {
            throw SchemeBuilderError.MissingRequiredAttribute("expandedCellTypes")
        }

        let scheme = SchemeType(expandedCellTypes: expandedCellTypes, configurationHandler: configurationHandler)
        scheme.heights = heights
        scheme.selectedIndex = selectedIndex
        scheme.selectionHandler = selectionHandler
        return scheme
    }
    
}
