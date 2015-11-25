//
//  InferrableReuseIdentifierScheme.swift
//  TableSchemer
//
//  Created by James Richard on 11/24/15.
//  Copyright © 2015 Weebly. All rights reserved.
//

public protocol InferrableReuseIdentifierScheme: Scheme {
    var reusePairs: [(identifier: String, cellType: UITableViewCell.Type)] { get }
}
