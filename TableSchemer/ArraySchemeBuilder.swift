//
//  ArraySchemeBuilder.swift
//  TableSchemer
//
//  Created by James Richard on 11/25/15.
//  Copyright © 2015 Weebly. All rights reserved.
//

public class ArraySchemeBuilder<ElementType: Equatable, CellType: UITableViewCell>: SchemeBuilder {
    
    public typealias SchemeType = ArrayScheme<ElementType, CellType>

    public required init() {}

    public func createScheme() throws -> SchemeType {
        guard let objects = objects else {
            throw SchemeBuilderError.MissingRequiredAttribute("objects")
        }

        guard let configurationHandler = configurationHandler else {
            throw SchemeBuilderError.MissingRequiredAttribute("configurationHandler")
        }

        let scheme = SchemeType(objects: objects, configurationHandler: configurationHandler)
        scheme.selectionHandler = selectionHandler
        scheme.heightHandler = heightHandler

        return scheme
    }

    public var objects: [ElementType]?
    public var heightHandler: SchemeType.HeightHandler?
    public var configurationHandler: SchemeType.ConfigurationHandler?
    public var selectionHandler: SchemeType.SelectionHandler?
    
}
