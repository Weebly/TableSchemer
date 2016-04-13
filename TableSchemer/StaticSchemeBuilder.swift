//
//  StaticSchemeBuilder.swift
//  TableSchemer
//
//  Created by James Richard on 11/25/15.
//  Copyright © 2015 Weebly. All rights reserved.
//

public class StaticSchemeBuilder<CellType: UITableViewCell>: SchemeBuilder {

    public typealias SchemeType = StaticScheme<CellType>

    public required init() {}

    public func createScheme() throws -> SchemeType {
        guard let cell = cell else {
            throw SchemeBuilderError.MissingRequiredAttribute("cell")
        }

        let scheme = SchemeType(cell: cell)
        scheme.height = height
        scheme.selectionHandler = selectionHandler
        return scheme
    }

    public var cell: CellType?
    public var selectionHandler: SchemeType.SelectionHandler?
    public var height: RowHeight = .UseTable
    
}
