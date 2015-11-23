//
//  SchemeSet.swift
//  TableSchemer
//
//  Created by James Richard on 6/13/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

class SchemeItem {
    let scheme: Scheme
    var hidden: Bool

    init(scheme: Scheme, hidden: Bool) {
        self.scheme = scheme
        self.hidden = hidden
    }
}


/**
 *    A SchemeSet is a container for Scheme objects.
 *
 *    This class maps to a table view's section. Its schemes property
 *    are similar to the rows in that section (though a scheme may
 *    have more than a single row), and the name property is used for the
 *    section name.
 */
public class SchemeSet {
    /** This property is the title for the table view section */
    public let name: String?
    
    /** The string returned for tableView:viewForFooterInSection */
    public var footerText: String?
    
    /** The schemes contained in the SchemeSet */
    var schemeItems: [SchemeItem]

    public var schemes: [Scheme] {
        return schemeItems.map { $0.scheme }
    }
    
    /** The number of schemes within the SchemeSet */
    public final var count: Int {
        return schemes.count
    }
    
    /// Schemes that are currently visible
    public final var visibleSchemes: [Scheme] {
        return schemeItems.flatMap { $0.hidden ? nil : $0.scheme }
    }
    
    final var finishedBuilding = false

    /**
        Identifies if the SchemeSet is hidden or not.
        
        You should not change this variable directly after initial configuration, and 
        instead use the TableScheme that this SchemeSet belongs to.
    */
    public final var hidden: Bool {
        set {
            assert(!finishedBuilding, "Setting this property after the scheme has finished building is an error. Use the methods on the TableScheme class to change visibility")
            _hidden = newValue
        }
        
        get {
            return _hidden
        }
    }
    
    final var _hidden = false
    
    public init(schemes: [Scheme]) {
        schemeItems = schemes.map { SchemeItem(scheme: $0, hidden: false) }
        footerText = nil
        name = nil
    }
    
    public init(name: String?, footerText: String?, withSchemes schemes: [Scheme]) {
        self.name = name
        self.footerText = footerText
        schemeItems = schemes.map { SchemeItem(scheme: $0, hidden: false) }
    }
    
    public init(name: String?, footerText: String?, hidden: Bool, withSchemes schemes: [Scheme]) {
        self.name = name
        self.footerText = footerText
        _hidden = hidden
        schemeItems = schemes.map { SchemeItem(scheme: $0, hidden: false) }
    }
    
    public convenience init(name: String?, withSchemes schemes: [Scheme]) {
        self.init(name: name, footerText: nil, withSchemes: schemes)
    }
    
    public convenience init(footerText: String?, withSchemes schemes: [Scheme]) {
        self.init(name: nil, footerText: footerText, withSchemes: schemes)
    }
    
    public subscript(index: Int) -> Scheme {
        return schemes[index]
    }
}

extension SchemeSet: Equatable { }

public func ==(lhs: SchemeSet, rhs: SchemeSet) -> Bool {
    if lhs === rhs {
        return true
    }
    
    return lhs.name == rhs.name && lhs.footerText == rhs.footerText && lhs.schemes == rhs.schemes
}
