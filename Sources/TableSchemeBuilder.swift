//
//  TableSchemeBuilder.swift
//  TableSchemer
//
//  Created by James Richard on 6/13/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

/** This class facilitates building the contents of a TableScheme.
 *
 * An instance of this object is passed into the build handler from TableScheme(buildHandler:).
 * It's used to create SchemeSet objects, which correspond directly to table view sections.
 */
public final class TableSchemeBuilder {
    /** The scheme sets that have been added to the builder. */
    public var schemeSets = [SchemeSet]();
    
    /** Builds a SchemeSet object with the configured builder passed into the handler.
     *
     *  This method will instantiate a SchemeSetBuilder object and then pass it into handler.
     *  The method will take the builder object you configure and create a SchemeSet object, which
     *  will be added to the data sources array of scheme sets.
     *
     *  The created SchemeSet object will be returned if you need a reference to it, but it will
     *  be added to the data source automatically.
     *
     *  @param handler The block to configure the builder.
     *  @return The created SchemeSet object.
     */
    public func buildSchemeSet(@noescape handler: (builder: SchemeSetBuilder) -> Void) -> SchemeSet {
        let builder = SchemeSetBuilder()
        handler(builder: builder)
        let schemeSet = builder.createSchemeSet()
        schemeSets.append(schemeSet)
        return schemeSet
    }
}
