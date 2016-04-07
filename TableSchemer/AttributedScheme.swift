//
//  AttributedScheme.swift
//  TableSchemer
//
//  Created by James Richard on 11/24/15.
//  Copyright © 2015 Weebly. All rights reserved.
//

/**
Each `Scheme` contained in a `SchemeSet` requires additional attributes. This
struct contains the `Scheme` and its attributes.
*/
public struct AttributedScheme {

    public let scheme: Scheme
    public var hidden: Bool

    public init(scheme: Scheme, hidden: Bool) {
        self.scheme = scheme
        self.hidden = hidden
    }

}
