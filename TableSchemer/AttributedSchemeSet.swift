//
//  AttributedSchemeSet.swift
//  TableSchemer
//
//  Created by James Richard on 11/24/15.
//  Copyright © 2015 Weebly. All rights reserved.
//

/**
Each `SchemeSet` contained in a `TableScheme` requires additional attributes. This
struct contains the `SchemeSet` and its attributes.
*/
public struct AttributedSchemeSet {

    public let schemeSet: SchemeSet
    public var hidden: Bool

    public init(schemeSet: SchemeSet, hidden: Bool) {
        self.schemeSet = schemeSet
        self.hidden = hidden
    }

}
