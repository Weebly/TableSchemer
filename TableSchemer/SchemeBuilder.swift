//
//  SchemeBuilder.swift
//  TableSchemer
//
//  Created by James Richard on 11/24/15.
//  Copyright © 2015 Weebly. All rights reserved.
//

public protocol SchemeBuilder: class {

    typealias SchemeType: Scheme

    init()
    func createScheme() throws -> SchemeType

}

public enum SchemeBuilderError: ErrorType {
    case MissingRequiredAttribute(String)
}
