//
//  BasicSchemeBuilder.swift
//  TableSchemer
//
//  Created by James Richard on 11/25/15.
//  Copyright © 2015 Weebly. All rights reserved.
//

public class BasicSchemeBuilder<CellType: UITableViewCell>: SchemeBuilder {

    public typealias SchemeType = BasicScheme<CellType>

    public required init() {}

    public func createScheme() throws -> SchemeType {
        guard let configurationHandler = configurationHandler else {
            throw SchemeBuilderError.MissingRequiredAttribute("configurationHandler")
        }

        let scheme = BasicScheme<CellType>(configurationHandler: configurationHandler)
        scheme.height = height
        scheme.selectionHandler = selectionHandler
        return scheme
    }

    public var height: RowHeight = .UseTable
    public var configurationHandler: SchemeType.ConfigurationHandler?
    public var selectionHandler: SchemeType.SelectionHandler?
    
}
