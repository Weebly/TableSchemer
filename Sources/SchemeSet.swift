//
//  SchemeSet.swift
//  TableSchemer
//
//  Created by James Richard on 6/13/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

/**
 *    A SchemeSet is a container for Scheme objects.
 *
 *    This class maps to a table view's section. It's schemes property
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
    public let schemes: [Scheme]
    
    /** The number of schemes within the SchemeSet */
    public final var count: Int {
        return schemes.count
    }
    
    /// Schemes that are currently visible
    public final var visibleSchemes: [Scheme] {
        return schemes.filter { !$0.hidden }
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
        self.schemes = schemes
        footerText = nil
        name = nil
    }
    
    public init(name: String?, footerText: String?, withSchemes schemes: [Scheme]) {
        self.name = name
        self.footerText = footerText
        self.schemes = schemes
    }
    
    public init(name: String?, footerText: String?, hidden: Bool, withSchemes schemes: [Scheme]) {
        self.name = name
        self.footerText = footerText
        _hidden = hidden
        self.schemes = schemes
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
