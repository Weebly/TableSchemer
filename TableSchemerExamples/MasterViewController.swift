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
    let arrayObjects = ["Item 1", "Item 2", "A really long item to demonstrate height handling at its finest"]
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
        tableScheme = TableScheme(tableView: tableView, allowReordering: true) { builder in
            builder.buildSchemeSet { builder in
                builder.buildScheme { (scheme: BasicSchemeBuilder) in

                    scheme.configurationHandler = { cell in
                        cell.textLabel?.text = "Tap here for animation examples."
                        cell.accessoryType = .disclosureIndicator
                    }
                    
                    scheme.selectionHandler = { [unowned self] cell, scheme in
                        let animationController = AnimationsViewController(style: .grouped)
                        self.navigationController!.pushViewController(animationController, animated: true)
                    }
                }
                
                builder.buildScheme { (scheme: BasicSchemeBuilder) in
                    scheme.configurationHandler = { cell in
                        cell.textLabel?.text = "Tap here for an advanced example."
                        cell.accessoryType = .disclosureIndicator
                    }
                    
                    scheme.selectionHandler = { [unowned self] cell, scheme in
                        let advancedController = AdvancedTableSchemeViewController(style: .grouped)
                        self.navigationController!.pushViewController(advancedController, animated: true)
                        self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
                    }
                }
            }
            
            builder.buildSchemeSet { builder in
                builder.headerText = "Accordion Sample"
                
                builder.buildScheme { (scheme: AccordionSchemeBuilder) in
                    scheme.expandedCellTypes = [UITableViewCell.Type](repeating: UITableViewCell.self, count: 3)
                    scheme.accordionHeights = [.useTable, .custom(88.0)] // Demonstrating that if we don't have enough heights to cover all items, it defaults to .UseTable
                    scheme.collapsedCellConfigurationHandler = { [unowned(unsafe) self] (cell) in // Be sure to use unowned(unsafe) references for the config/selection handlers
                        _ = cell.textLabel?.text = "Selected Index: \(self.accordionSelection)"
                    }
                    
                    scheme.collapsedCellSelectionHandler = { cell, scheme in
                        print("Opening Accordion!")
                    }

                    scheme.expandedCellConfigurationHandler = { [unowned self] cell, index in
                        cell.textLabel?.text = "Accordion Expanded Cell \(index + 1)"
                        if index == self.accordionSelection {
                            cell.accessoryType = .checkmark
                        } else {
                            cell.accessoryType = .none
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
                        let rect = object.boundingRect(with: CGSize(width: 300, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: nil, context: nil)
                        let height = CGFloat(ceilf(Float(rect.size.height)) + 28.0)
                        return .custom(height)
                    }
                    
                    scheme.configurationHandler = { cell, object in
                        cell.textLabel?.text = object
                        cell.textLabel?.numberOfLines = 0
                        cell.textLabel?.preferredMaxLayoutWidth = 300
                        cell.textLabel?.lineBreakMode = .byWordWrapping
                        cell.textLabel?.invalidateIntrinsicContentSize() // For when this cell gets reused
                    }
                    
                    scheme.selectionHandler = { cell, scheme, object in
                        print("Selected object in ArrayScheme: \(object)")
                        self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
                    }

                    scheme.reorderingHandler = { objects in
                        print("Reordered objects in ArrayScheme: \(objects)")
                    }
                }
            }
            
            builder.buildSchemeSet { builder in
                builder.headerText = "Radio Sample"
                
                builder.buildScheme { (scheme: RadioSchemeBuilder) in
                    scheme.expandedCellTypes = [UITableViewCell.Type](repeating: UITableViewCell.self, count: 5)
                    
                    scheme.configurationHandler = { cell, index in
                        cell.textLabel?.text = "Radio Button \(index + 1)"
                    }
                    
                    scheme.selectionHandler = { [unowned self] cell, scheme, index in
                        print("You selected \(index)!")
                        self.radioSelection = index
                        self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
                    }
                }
            }

            builder.buildSchemeSet { builder in
                builder.headerText = "Custom Appearance Radio Sample"

                builder.buildScheme { (scheme: RadioSchemeBuilder) in
                    scheme.expandedCellTypes = [ColorizedTableViewCell.Type](repeating: ColorizedTableViewCell.self, count: 5)

                    scheme.configurationHandler = { cell, index in
                        cell.textLabel?.text = "Radio Button \(index + 1)"
                    }

                    scheme.selectionHandler = { [unowned self] cell, scheme, index in
                        print("You selected \(index)!")
                        self.radioSelection = index
                    }

                    scheme.stateHandler = { cell, _, _, selected in
                        cell.backgroundColor = selected ? .green : .red
                    }
                }
            }

        }
    }
}

fileprivate class ColorizedTableViewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textLabel?.backgroundColor = .clear
    }
}
