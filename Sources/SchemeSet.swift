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
class SchemeSet {
    /** This property is the title for the table view section */
    let name: String?
    
    /** The text for the UILabel in tableView:viewForFooterInSection */
    let footerText: String?
    
    /** The schemes contained in the SchemeSet */
    let schemes: [Scheme]
    
    /** The number of schemes within the SchemeSet */
    var count: Int {
        return countElements(schemes)
    }
    
    init(schemes: [Scheme]) {
        self.schemes = schemes
    }
    
    init(name: String?, footerText: String?, withSchemes schemes: [Scheme]) {
        self.name = name
        self.footerText = footerText
        self.schemes = schemes
    }
    
    subscript(index: Int) -> Scheme {
        return schemes[index]
    }
}