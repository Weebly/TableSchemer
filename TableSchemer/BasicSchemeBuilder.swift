//
//  BasicSchemeBuilder.swift
//  TableSchemer
//
//  Created by James Richard on 11/25/15.
//  Copyright © 2015 Weebly. All rights reserved.
//

open class BasicSchemeBuilder<CellType: UITableViewCell>: SchemeBuilder {

    public typealias SchemeType = BasicScheme<CellType>

    public required init() {}

    public func createScheme() throws -> SchemeType {
        guard let configurationHandler = configurationHandler else {
            throw SchemeBuilderError.missingRequiredAttribute("configurationHandler")
        }

        let scheme = BasicScheme<CellType>(configurationHandler: configurationHandler)
        scheme.height = height
        scheme.selectionHandler = selectionHandler
        return scheme
    }

    open var height: RowHeight = .useTable
    open var configurationHandler: SchemeType.ConfigurationHandler?
    open var selectionHandler: SchemeType.SelectionHandler?
    
}
