//
//  AnimationsViewController.swift
//  TableSchemer
//
//  Created by James Richard on 11/19/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import TableSchemer
import UIKit

class AnimationsViewController: UITableViewController {
    let ReuseIdentifier = "cell"
    var tableScheme: TableScheme!
    var toggleHiddenSchemeSetScheme: Scheme!
    var randomNumberScheme: Scheme!
    var hiddenSchemeSet: SchemeSet!
    var toggleHiddenSchemesScheme: Scheme!
    var hiddenScheme1: Scheme!
    var hiddenScheme2: Scheme!
    var randomizedArrayScheme: ArrayScheme<Int, SchemeCell>!
    var toggledArrayScheme: ArrayScheme<Int, SchemeCell>!
    
    var toggledArrayToggled = false
    var schemesHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Schemes Animations and More"
        createTableScheme()
        
        tableView.rowHeight = 44.0
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifier)
        tableView.dataSource = tableScheme
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableScheme.heightInTableView(tableView, forIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableScheme.handleSelectionInTableView(tableView, forIndexPath: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func createTableScheme() {
        tableScheme = TableScheme { builder in
            builder.buildSchemeSet { builder in
                // Demonstrate cell reloading by using a random number in each configuration
                randomNumberScheme = builder.buildScheme { (scheme: BasicScheme<SchemeCell>) in
                    scheme.reuseIdentifier = ReuseIdentifier
                    
                    scheme.configurationHandler = { [unowned self] cell in
                        self.removeSubviewsInView(cell.contentView)
                        cell.selectionStyle = .None
                        let randomNumber = arc4random() % 100
                        cell.textLabel?.text = "Random number: \(randomNumber)"
                    }
                    
                    scheme.selectionHandler = { [unowned(unsafe) self] cell, scheme in
                        _ = self.tableScheme.reloadScheme(self.randomNumberScheme, inTableView: self.tableView, withRowAnimation: .Fade)
                    }
                }
                
                self.toggleHiddenSchemeSetScheme = builder.buildScheme { (scheme: BasicScheme<SchemeCell>) in
                    scheme.reuseIdentifier = ReuseIdentifier
                    
                    scheme.configurationHandler = { [unowned(unsafe) self] cell in
                        self.removeSubviewsInView(cell.contentView)
                        cell.textLabel?.text = nil
                        cell.selectionStyle = .None
                        let button = UIButton(frame: CGRect(x: 10, y: 0, width: 300, height: 44))
                        button.setTitle("Tap to toggle hidden scheme set", forState: .Normal)
                        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
                        button.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
                        cell.contentView.addSubview(button)
                    }
                }
            }
            
            hiddenSchemeSet = builder.buildSchemeSet { builder in
                builder.headerText = "Hidden Sample"
                builder.hidden = true
                
                toggleHiddenSchemesScheme = builder.buildScheme { (scheme: BasicScheme) in
                    scheme.reuseIdentifier = ReuseIdentifier
                    
                    scheme.configurationHandler = { [unowned self] cell in
                        self.removeSubviewsInView(cell.contentView)
                        cell.textLabel?.text = nil
                        cell.selectionStyle = .None
                        let button = UIButton(frame: CGRect(x: 10, y: 0, width: 300, height: 44))
                        button.setTitle("Tap to toggle other schemes visibility", forState: .Normal)
                        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
                        button.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
                        cell.contentView.addSubview(button)
                    }
                }
                
                hiddenScheme1 = builder.buildScheme { (scheme: BasicScheme, inout hidden: Bool) in
                    scheme.reuseIdentifier = ReuseIdentifier
                    hidden = true
                    
                    scheme.configurationHandler = { [unowned self] cell in
                        self.removeSubviewsInView(cell.contentView)
                        cell.textLabel?.text = nil
                        cell.selectionStyle = .None
                        cell.textLabel?.text = "First"
                        cell.accessoryView = nil
                    }
                }
                
                hiddenScheme2 = builder.buildScheme { (scheme: BasicScheme, inout hidden: Bool) in
                    scheme.reuseIdentifier = ReuseIdentifier
                    hidden = true
                    
                    scheme.configurationHandler = { [unowned self] cell in
                        self.removeSubviewsInView(cell.contentView)
                        cell.selectionStyle = .None
                        cell.textLabel?.text = "Second"
                        cell.accessoryView = nil
                    }
                }
            }
        
        
            builder.buildSchemeSet { builder in
                builder.headerText = "Intrascheme Animations"
                
                /* 
                The following two schemes are an example of explicitly giving the animations the table view
                should be performing. Note that all of the indexes used are relative to the objects
                positions inside of the scheme itself. The rest of the table view isn't a concern when creating
                these animations.
                
                Note that you still need to update the objects array, otherwise you'll get errors when the cells
                get configured.
                */
                builder.buildScheme { (scheme: BasicScheme) in
                    scheme.reuseIdentifier = ReuseIdentifier
                    
                    scheme.configurationHandler = { [unowned self] cell in
                        self.removeSubviewsInView(cell.contentView)
                        cell.selectionStyle = .None
                        cell.textLabel?.text = "Tap to toggle preset array"
                    }
                    
                    scheme.selectionHandler = { [unowned self] cell, scheme in
                        if !self.toggledArrayToggled {
                            self.tableScheme.animateChangesToScheme(self.toggledArrayScheme, inTableView: self.tableView) { animator in
                                animator.deleteObjectAtIndex(1, withRowAnimation: .Left)
                                animator.deleteObjectAtIndex(3, withRowAnimation: .Right)
                                animator.deleteObjectAtIndex(5, withRowAnimation: .Left)
                                animator.deleteObjectAtIndex(7, withRowAnimation: .Right)
                                animator.deleteObjectAtIndex(8, withRowAnimation: .Top)
                                animator.moveObjectAtIndex(4, toIndex: 3)
                                animator.moveObjectAtIndex(6, toIndex: 2)
                                animator.insertObjectAtIndex(4, withRowAnimation: .Top)
                                self.toggledArrayScheme.objects = [1,3,7,5,11]
                            }
                        } else {
                            self.tableScheme.animateChangesToScheme(self.toggledArrayScheme, inTableView: self.tableView) { animator in
                                animator.insertObjectAtIndex(1, withRowAnimation: .Left)
                                animator.insertObjectAtIndex(3, withRowAnimation: .Right)
                                animator.insertObjectAtIndex(5, withRowAnimation: .Left)
                                animator.insertObjectAtIndex(7, withRowAnimation: .Right)
                                animator.insertObjectAtIndex(8, withRowAnimation: .Top)
                                animator.moveObjectAtIndex(2, toIndex: 6)
                                animator.moveObjectAtIndex(3, toIndex: 4)
                                animator.deleteObjectAtIndex(4, withRowAnimation: .Top)
                                self.toggledArrayScheme.objects = [1,2,3,4,5,6,7,8,9]
                            }
                        }
                        
                        self.toggledArrayToggled = !self.toggledArrayToggled
                    }
                }
                
                toggledArrayScheme = builder.buildScheme { (scheme: ArrayScheme<Int, SchemeCell>) in
                    scheme.reuseIdentifier = self.ReuseIdentifier
                    scheme.objects = [1,2,3,4,5,6,7,8,9]
                    
                    scheme.configurationHandler = { [unowned self] cell, object in
                        self.removeSubviewsInView(cell.contentView)
                        cell.selectionStyle = .None
                        cell.textLabel?.text = "\(object)"
                    }
                }
            
                /*
                The following two schemes are an example of letting TableSchemer decide the animations that are needed. I personally
                like the way the Fade animation works for inferred animations like this, and generally recommend this method unless
                you care about the animations on a specific row.
                
                The one requirement to support inferred animations is that the scheme conform to InferrableRowAnimatableScheme. The builtin 
                ArrayScheme conforms to it, so for most cases it should be free to use!
                */
                builder.buildScheme { (scheme: BasicScheme) in
                    scheme.reuseIdentifier = ReuseIdentifier
                    
                    scheme.configurationHandler = { [unowned self] cell in
                        self.removeSubviewsInView(cell.contentView)
                        cell.selectionStyle = .None
                        cell.textLabel?.text = "Tap to toggle random inferred array"
                    }
                    
                    scheme.selectionHandler = { [unowned self] cell, object in
                        self.tableScheme.animateChangesToScheme(self.randomizedArrayScheme, inTableView: self.tableView, withAnimation: .Fade) {
                            self.randomizedArrayScheme.objects = self.generateRandomizedArray()
                        }
                    }
                }
                
                randomizedArrayScheme = builder.buildScheme { (scheme: ArrayScheme<Int, SchemeCell>) in
                    scheme.reuseIdentifier = ReuseIdentifier
                    scheme.objects = generateRandomizedArray()
                    
                    scheme.configurationHandler = { [unowned self] cell, object in
                        self.removeSubviewsInView(cell.contentView)
                        cell.selectionStyle = .None
                        cell.textLabel?.text = "\(object)"
                    }
                }
            }
        }
    }
    
    private func removeSubviewsInView(view: UIView) {
        for v in view.subviews {
            v.removeFromSuperview()
        }
    }
    
    private func generateRandomizedArray() -> [Int] {
        let itemCount = Int(arc4random() % 20)
        var items = [Int]()
        
        for i in 0..<itemCount {
            items.append(i)
        }
        
        items.sortInPlace { _, _ in
            arc4random() % 2 == 1 ? true : false
        }
        
        return items
    }
    
    func buttonPressed(button: UIButton) {
        if let tuple = tableScheme.schemeWithIndexContainingView(button) {
            if tuple.scheme === toggleHiddenSchemeSetScheme {
                guard let index = tableScheme.attributedSchemeSets.indexOf({ $0.schemeSet === self.hiddenSchemeSet }) else {
                    return
                }

                if tableScheme.attributedSchemeSets[index].hidden {
                    tableScheme.showSchemeSet(hiddenSchemeSet, inTableView: tableView, withRowAnimation: .Bottom)
                } else {
                    tableScheme.hideSchemeSet(hiddenSchemeSet, inTableView: tableView, withRowAnimation: .Top)
                }
            } else if tuple.scheme === toggleHiddenSchemesScheme {
                tableScheme.batchSchemeVisibilityChangesInTableView(tableView) { animator in
                    if schemesHidden {
                        animator.showScheme(hiddenScheme1, withRowAnimation: .Left)
                        animator.showScheme(hiddenScheme2, withRowAnimation: .Right)
                    } else {
                        animator.hideScheme(hiddenScheme2, withRowAnimation: .Left)
                        animator.hideScheme(hiddenScheme1, withRowAnimation: .Right)
                    }
                }
                
                schemesHidden = !schemesHidden
            }
        }
    }
}
