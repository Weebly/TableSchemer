//
//  ViewExtensions.swift
//  TableSchemer
//
//  Created by James Richard on 7/30/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

extension UIView {
    public func TSR_containingTableViewCell() -> UITableViewCell? {
        var view: UIView? = self
        while let v = view {
            if v is UITableViewCell {
                break
            }
            
            view = v.superview
        }
        
        return view as? UITableViewCell
    }
}

extension UITableViewCell {
    public func TSR_containingTableView() -> UITableView? {
        var view: UIView? = self
        while let v = view {
            if v is UITableView {
                break
            }
            
            view = v.superview
        }
        
        return view as? UITableView
    }
}
