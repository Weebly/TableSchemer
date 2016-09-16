//
//  ArraySchemeBuilder.swift
//  TableSchemer
//
//  Created by James Richard on 11/25/15.
//  Copyright © 2015 Weebly. All rights reserved.
//

open class ArraySchemeBuilder<ElementType: Equatable, CellType: UITableViewCell>: SchemeBuilder {
    
    public typealias SchemeType = ArrayScheme<ElementType, CellType>

    public required init() {}

    public func createScheme() throws -> SchemeType {
        guard let objects = objects else {
            throw SchemeBuilderError.missingRequiredAttribute("objects")
        }

        guard let configurationHandler = configurationHandler else {
            throw SchemeBuilderError.missingRequiredAttribute("configurationHandler")
        }

        let scheme = SchemeType(objects: objects, configurationHandler: configurationHandler)
        scheme.selectionHandler = selectionHandler
        scheme.heightHandler = heightHandler

        return scheme
    }

    open var objects: [ElementType]?
    open var heightHandler: SchemeType.HeightHandler?
    open var configurationHandler: SchemeType.ConfigurationHandler?
    open var selectionHandler: SchemeType.SelectionHandler?
    
}
