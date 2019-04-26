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
    public var headerText: String?
    
    /** The string returned for tableView:viewForFooterInSection */
    public var footerText: String?
    
    /** The view to use as the header for the table view section */
    public var headerView: UIView?
    
    /** The height of the custom header view */
    public var headerViewHeight: RowHeight
    
    /** The view to use as the footer for the table view section */
    public var footerView: UIView?
    
    /** The height of the custom footer view */
    public var footerViewHeight: RowHeight
    
    /** The schemes contained in the SchemeSet */
    var attributedSchemes: [AttributedScheme]

    public var schemes: [Scheme] {
        return attributedSchemes.map { $0.scheme }
    }
    
    /** The number of schemes within the SchemeSet */
    public var count: Int {
        return schemes.count
    }
    
    /// Schemes that are currently visible
    public var visibleSchemes: [Scheme] {
        return attributedSchemes.compactMap { $0.hidden ? nil : $0.scheme }
    }
    
    public init(attributedSchemes: [AttributedScheme],
                headerText: String? = nil,
                footerText: String? = nil,
                headerView: UIView? = nil,
                headerViewHeight: RowHeight = .useTable,
                footerView: UIView? = nil,
                footerViewHeight: RowHeight = .useTable) {
        self.attributedSchemes = attributedSchemes
        self.headerText = headerText
        self.footerText = footerText
        self.headerView = headerView
        self.headerViewHeight = headerViewHeight
        self.footerView = footerView
        self.footerViewHeight = footerViewHeight
    }

    public convenience init(schemes: [Scheme],
                            headerText: String? = nil,
                            footerText: String? = nil,
                            headerView: UIView? = nil,
                            headerViewHeight: RowHeight = .useTable,
                            footerView: UIView? = nil,
                            footerViewHeight: RowHeight = .useTable) {
        self.init(attributedSchemes: schemes.map { AttributedScheme(scheme: $0, hidden: false) }, headerText: headerText, footerText: footerText, headerView: headerView, headerViewHeight: headerViewHeight, footerView: footerView, footerViewHeight: footerViewHeight)
    }

    public subscript(index: Int) -> Scheme {
        return schemes[index]
    }

}
