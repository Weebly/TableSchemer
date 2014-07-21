//
//  SchemeSetBuilder.swift
//  TableSchemer
//
//  Created by James Richard on 6/13/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

/** This class facilitates building the contents of a WBLCellSchemeSet.
 *
 *  An instance of this object is passed into the build handler from WBLSchemeDataSourceBuilder.buildSchemeSet(handler:).
 *  It's used to set a section title and to add schemes to the scheme set.
 */
public class SchemeSetBuilder {
    /** This will be used as the SchemeSet's name. If left nil, the SchemeSet will not have a title. */
    public var name: String?
    
    /** This will be used as the SchemeSet's footer text. If left nil, it will not have a footer label */
    public var footerText: String?
    
    /** These are the Scheme objects that the SchemeSet will be instantiated with. */
    public var schemes = [Scheme]()
    
    public init() { } // Compiler won't compile without this. Not sure why.
    
    /** Build a scheme within the closure.
     *
     *  This method will instantiate a Scheme object, and then pass it into handler. The type of Scheme object
     *  that is instantiated will be inferred from the type passed into the handler.
     *
     *  The created Scheme object will be validated before being added to the list of schemes to be created. 
     *
     *  The created Scheme object will be returned if you need a reference to it, but it will be added
     *  to the TableScheme automatically.
     *
     *  @param handler The closure to configure the scheme.
     *  @return The created Scheme instance
     */
    public func buildScheme<T: Scheme>(handler: (scheme: T) -> Void) -> T {
        let scheme = T()
        handler(scheme: scheme)
        
        if scheme.isValid() {
            schemes.append(scheme)
        }
        
        return scheme
    }
    
    /** Create the SchemeSet with the currently added Schemes. This method should not be called except from TableSchemeBuilder */
    internal func createSchemeSet() -> SchemeSet {
        return SchemeSet(name: name, footerText: footerText, withSchemes: schemes)
    }
}