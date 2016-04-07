//
//  InferrableRowAnimatableScheme.swift
//  TableSchemer
//
//  Created by James Richard on 11/17/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

public protocol InferrableRowAnimatableScheme {
    associatedtype IdentifierType: Equatable
    var rowIdentifiers: [IdentifierType] { get }
}
