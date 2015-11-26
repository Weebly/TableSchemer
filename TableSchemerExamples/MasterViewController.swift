//
//  MasterViewController.swift
//  TableSchemer
//
//  Created by James Richard on 6/12/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import TableSchemer
import UIKit

class MasterViewController: UITableViewController {
    let ReuseIdentifier = "cell"
    let arrayObjects = ["Item 1", "Item 2", "A really long item to demonstrate height handling at it's finest"]
    var tableScheme: TableScheme!
    var accordionSelection = 0
    var radioSelection = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sample Schemes"

        createTableScheme()

        tableView.rowHeight = 44.0
    }

    func createTableScheme() {
        tableScheme = TableScheme(tableView: tableView) { builder in
            builder.buildSchemeSet { builder in
                builder.buildScheme { (scheme: BasicSchemeBuilder) in

                    scheme.configurationHandler = { cell in
                        cell.textLabel?.text = "Tap here for animation examples."
                        cell.accessoryType = .DisclosureIndicator
                    }
                    
                    scheme.selectionHandler = { [unowned self] cell, scheme in
                        let animationController = AnimationsViewController(style: .Grouped)
                        self.navigationController!.pushViewController(animationController, animated: true)
                    }
                }
                
                builder.buildScheme { (scheme: BasicSchemeBuilder) in
                    scheme.configurationHandler = { cell in
                        cell.textLabel?.text = "Tap here for an advanced example."
                        cell.accessoryType = .DisclosureIndicator
                    }
                    
                    scheme.selectionHandler = { [unowned self] cell, scheme in
                        let advancedController = AdvancedTableSchemeViewController(style: .Grouped)
                        self.navigationController!.pushViewController(advancedController, animated: true)
                        self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
                    }
                }
            }
            
            builder.buildSchemeSet { builder in
                builder.headerText = "Accordion Sample"
                
                builder.buildScheme { (scheme: AccordionSchemeBuilder) in
                    scheme.expandedCellTypes = [UITableViewCell.Type](count: 3, repeatedValue: UITableViewCell.self)
                    scheme.accordionHeights = [.UseTable, .Custom(88.0)] // Demonstrating that if we don't have enough heights to cover all items, it defaults to .UseTable
                    scheme.collapsedCellConfigurationHandler = { [unowned(unsafe) self] (cell) in // Be sure to use unowned(unsafe) references for the config/selection handlers
                        _ = cell.textLabel?.text = "Selected Index: \(self.accordionSelection)"
                    }
                    
                    scheme.collapsedCellSelectionHandler = { cell, scheme in
                        print("Opening Accordion!")
                    }

                    scheme.expandedCellConfigurationHandler = { [unowned self] cell, index in
                        cell.textLabel?.text = "Accordion Expanded Cell \(index + 1)"
                        if index == self.accordionSelection {
                            cell.accessoryType = .Checkmark
                        } else {
                            cell.accessoryType = .None
                        }
                    }
                    
                    scheme.expandedCellSelectionHandler = { [unowned self] cell, scheme, selectedIndex in
                        self.accordionSelection = selectedIndex
                    }
                }
            }
            
            builder.buildSchemeSet { builder in
                builder.headerText = "Array Sample"
                
                builder.buildScheme { (scheme: ArraySchemeBuilder<String, UITableViewCell>) in
                    scheme.objects = arrayObjects
                    
                    scheme.heightHandler = { object in
                        let rect = object.boundingRectWithSize(CGSize(width: 300, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: nil, context: nil)
                        let height = CGFloat(ceilf(Float(rect.size.height)) + 28.0)
                        return .Custom(height)
                    }
                    
                    scheme.configurationHandler = { cell, object in
                        cell.textLabel?.text = object
                        cell.textLabel?.numberOfLines = 0
                        cell.textLabel?.preferredMaxLayoutWidth = 300
                        cell.textLabel?.lineBreakMode = .ByWordWrapping
                        cell.textLabel?.invalidateIntrinsicContentSize() // For when this cell gets reused
                    }
                    
                    scheme.selectionHandler = { cell, scheme, object in
                        print("Selected object in ArrayScheme: \(object)")
                        self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
                    }
                }
            }
            
            builder.buildSchemeSet { builder in
                builder.headerText = "Radio Sample"
                
                builder.buildScheme { (scheme: RadioSchemeBuilder) in
                    scheme.expandedCellTypes = [UITableViewCell.Type](count: 5, repeatedValue: UITableViewCell.self)
                    
                    scheme.configurationHandler = { cell, index in
                        cell.textLabel?.text = "Radio Button \(index + 1)"
                    }
                    
                    scheme.selectionHandler = { [unowned self] cell, scheme, index in
                        print("You selected \(index)!")
                        self.radioSelection = index
                        self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
                    }
                }
            }

        }
    }
}

