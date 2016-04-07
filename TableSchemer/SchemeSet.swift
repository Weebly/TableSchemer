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
 *    This class maps to a table view's section. Its schemes property
 *    are similar to the rows in that section (though a scheme may
 *    have more than a single row), and the name property is used for the
 *    section name.
 */
public class SchemeSet {

    /** This property is the title for the table view section */
    public let headerText: String?
    
    /** The string returned for tableView:viewForFooterInSection */
    public var footerText: String?
    
    /** The schemes contained in the SchemeSet */
    var attributedSchemes: [AttributedScheme]

    public var schemes: [Scheme] {
        return attributedSchemes.map { $0.scheme }
    }
    
    /** The number of schemes within the SchemeSet */
    public final var count: Int {
        return schemes.count
    }
    
    /// Schemes that are currently visible
    public final var visibleSchemes: [Scheme] {
        return attributedSchemes.flatMap { $0.hidden ? nil : $0.scheme }
    }
    
    public init(attributedSchemes: [AttributedScheme], headerText: String? = nil, footerText: String? = nil) {
        self.attributedSchemes = attributedSchemes
        self.headerText = headerText
        self.footerText = footerText
    }

    public convenience init(schemes: [Scheme], headerText: String? = nil, footerText: String? = nil) {
        self.init(attributedSchemes: schemes.map { AttributedScheme(scheme: $0, hidden: false) }, headerText: headerText, footerText: footerText)
    }

    public subscript(index: Int) -> Scheme {
        return schemes[index]
    }

}
