//
//  MasterViewController.swift
//  TableSchemer
//
//  Created by James Richard on 6/12/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    let ReuseIdentifier = "cell"
    let arrayObjects = ["Item 1", "Item 2", "A really long item to demonstrate height handling at it's finest"]
    var tableScheme: TableScheme!
    var accordionSelection = 0
    var radioSelection = 0
    
    init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // TODO: Change handler capture blocks to unowned. Currently causes a crash on Beta2
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sample Schemes"
        createTableScheme()
        
        tableView.rowHeight = 44.0
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifier)
        tableView.dataSource = tableScheme
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return tableScheme.heightInTableView(tableView, forIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableScheme.handleSelectionInTableView(tableView, forIndexPath: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func createTableScheme() {
        tableScheme = TableScheme() { (builder) in
            builder.buildSchemeSet { (builder) in
                builder.buildScheme { (scheme: BasicScheme) in
                    scheme.reuseIdentifier = self.ReuseIdentifier
                    
                    scheme.configurationHandler = { (cell) in
                        cell.textLabel.text = "Tap here for an advanced example."
                        cell.accessoryType = .DisclosureIndicator
                    }
                    
                    scheme.selectionHandler = { [unowned(unsafe) self] (cell, scheme) in
                        let advancedController = AdvancedTableSchemeViewController(style: .Grouped)
                        self.navigationController.pushViewController(advancedController, animated: true)
                    }
                }
                return // Trailing closures will attempt to retun the SchemeSet without this since it's a "one line" expression
            }
            
            builder.buildSchemeSet { (builder) in
                builder.name = "Accordion Sample"
                
                builder.buildScheme { (scheme: AccordionScheme) in
                    scheme.reuseIdentifier = self.ReuseIdentifier
                    scheme.accordionReuseIdentifiers = [String](count: 3, repeatedValue: self.ReuseIdentifier)
                    scheme.accordionHeights = [.UseTable, .Custom(88.0)] // Demonstrating that if we don't have enough heights to cover all items, it defaults to .UseTable
                    scheme.configurationHandler = { [weak self] (cell) in // Be sure to use unowned references for the config/selection handlers
                        cell.textLabel.text = "Selected Index: \(self!.accordionSelection)"
                    }
                    
                    scheme.selectionHandler = { (cell, scheme) in
                        println("Opening Accordion!")
                    }
                    
                    scheme.accordionConfigurationHandler = { [unowned(unsafe) self] (cell, index) in
                        cell.textLabel.text = "Accordion Expanded Cell \(index + 1)"
                        if index == self.accordionSelection {
                            cell.accessoryType = .Checkmark
                        } else {
                            cell.accessoryType = .None
                        }
                    }
                    
                    scheme.accordionSelectionHandler = { [unowned(unsafe) self] (cell, scheme, selectedIndex) in
                        self.accordionSelection = selectedIndex
                    }
                }
            }
            
            builder.buildSchemeSet { (builder) in
                builder.name = "Array Sample"
                
                builder.buildScheme { (scheme: ArrayScheme<String, UITableViewCell>) in
                    scheme.reuseIdentifier = self.ReuseIdentifier
                    scheme.objects = self.arrayObjects
                    
                    scheme.heightHandler = { (object) in
                        let rect = object.bridgeToObjectiveC().boundingRectWithSize(CGSize(width: 300, height: CGFLOAT_MAX), options: .UsesLineFragmentOrigin, attributes: nil, context: nil)
                        let height = CGFloat(ceilf(Float(rect.size.height)) + 28.0)
                        return .Custom(height)
                    }
                    
                    scheme.configurationHandler = { (cell, object) in
                        cell.textLabel.text = object
                        cell.textLabel.numberOfLines = 0
                        cell.textLabel.preferredMaxLayoutWidth = 300
                        cell.textLabel.lineBreakMode = .ByWordWrapping
                        cell.textLabel.invalidateIntrinsicContentSize() // For when this cell gets reused
                    }
                    
                    scheme.selectionHandler = { (cell, scheme, object) in
                        println("Selected object in ArrayScheme: \(object)")
                    }
                }
            }
            
            builder.buildSchemeSet { (builder) in
                builder.name = "Radio Sample"
                
                builder.buildScheme { (scheme: RadioScheme) in
                    scheme.useReuseIdentifier(self.ReuseIdentifier, withNumberOfOptions: 5)
                    
                    scheme.configurationHandler = { (cell, index) in
                        cell.textLabel.text = "Radio Button \(index + 1)"
                    }
                    
                    scheme.selectionHandler = { [unowned(unsafe) self] (cell, scheme, index) in
                        println("You selected \(index)!")
                        self.radioSelection = index
                    }
                }
            }

        }
    }
}

