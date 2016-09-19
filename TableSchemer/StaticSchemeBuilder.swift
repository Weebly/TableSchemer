//
//  StaticSchemeBuilder.swift
//  TableSchemer
//
//  Created by James Richard on 11/25/15.
//  Copyright © 2015 Weebly. All rights reserved.
//

open class StaticSchemeBuilder<CellType: UITableViewCell>: SchemeBuilder {

    public typealias SchemeType = StaticScheme<CellType>

    public required init() {}

    public func createScheme() throws -> SchemeType {
        guard let cell = cell else {
            throw SchemeBuilderError.missingRequiredAttribute("cell")
        }

        let scheme = SchemeType(cell: cell)
        scheme.height = height
        scheme.selectionHandler = selectionHandler
        return scheme
    }

    open var cell: CellType?
    open var selectionHandler: SchemeType.SelectionHandler?
    open var height: RowHeight = .useTable
    
}
