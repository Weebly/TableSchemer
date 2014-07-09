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
import UIKit

class SchemeSet {
    /** This property is the title for the table view section */
    let name: String?
    
    /** The view returned for tableView:viewForFooterInSection */
    let footerView: UIView?
    
    /** The schemes contained in the SchemeSet */
    let schemes: [Scheme]
    
    /** The number of schemes within the SchemeSet */
    var count: Int {
        return countElements(schemes)
    }
    
    init(schemes: [Scheme]) {
        self.schemes = schemes
    }
    
    init(name: String?, footerView: UIView?, withSchemes schemes: [Scheme]) {
        self.name = name
        self.footerView = footerView
        self.schemes = schemes
    }
    
    subscript(index: Int) -> Scheme {
        return schemes[index]
    }
}