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
    }
    
    func createTableScheme() {
        tableScheme = TableScheme(tableView: tableView) { builder in
            builder.buildSchemeSet { builder in
                // Demonstrate cell reloading by using a random number in each configuration
                randomNumberScheme = builder.buildScheme { (scheme: BasicSchemeBuilder<SchemeCell>) in
                    scheme.configurationHandler = { [unowned self] cell in
                        self.removeSubviewsInView(cell.contentView)
                        cell.selectionStyle = .none
                        let randomNumber = arc4random() % 100
                        cell.textLabel?.text = "Random number: \(randomNumber)"
                    }
                    
                    scheme.selectionHandler = { [unowned(unsafe) self] cell, scheme in
                        self.tableScheme.reloadScheme(self.randomNumberScheme, in: self.tableView, with: .fade)
                    }
                }
                
                self.toggleHiddenSchemeSetScheme = builder.buildScheme { (scheme: BasicSchemeBuilder<SchemeCell>) in
                    scheme.configurationHandler = { [unowned(unsafe) self] cell in
                        self.removeSubviewsInView(cell.contentView)
                        cell.textLabel?.text = nil
                        cell.selectionStyle = .none
                        let button = UIButton(frame: CGRect(x: 10, y: 0, width: 300, height: 44))
                        button.setTitle("Tap to toggle hidden scheme set", for: .normal)
                        button.setTitleColor(UIColor.black, for: .normal)
                        button.addTarget(self, action: #selector(AnimationsViewController.buttonPressed(_:)), for: .touchUpInside)
                        cell.contentView.addSubview(button)
                    }
                }
            }
            
            hiddenSchemeSet = builder.buildSchemeSet { builder in
                builder.headerText = "Hidden Sample"
                builder.hidden = true
                
                toggleHiddenSchemesScheme = builder.buildScheme { (scheme: BasicSchemeBuilder) in

                    scheme.configurationHandler = { [unowned self] cell in
                        self.removeSubviewsInView(cell.contentView)
                        cell.textLabel?.text = nil
                        cell.selectionStyle = .none
                        let button = UIButton(frame: CGRect(x: 10, y: 0, width: 300, height: 44))
                        button.setTitle("Tap to toggle other schemes visibility", for: .normal)
                        button.setTitleColor(UIColor.black, for: .normal)
                        button.addTarget(self, action: #selector(AnimationsViewController.buttonPressed(_:)), for: .touchUpInside)
                        cell.contentView.addSubview(button)
                    }
                }
                
                hiddenScheme1 = builder.buildScheme { (scheme: BasicSchemeBuilder, hidden: inout Bool) in
                    hidden = true
                    
                    scheme.configurationHandler = { [unowned self] cell in
                        self.removeSubviewsInView(cell.contentView)
                        cell.textLabel?.text = nil
                        cell.selectionStyle = .none
                        cell.textLabel?.text = "First"
                        cell.accessoryView = nil
                    }
                }
                
                hiddenScheme2 = builder.buildScheme { (scheme: BasicSchemeBuilder, hidden: inout Bool) in
                    hidden = true
                    
                    scheme.configurationHandler = { [unowned self] cell in
                        self.removeSubviewsInView(cell.contentView)
                        cell.selectionStyle = .none
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
                builder.buildScheme { (scheme: BasicSchemeBuilder) in
                    scheme.configurationHandler = { [unowned self] cell in
                        self.removeSubviewsInView(cell.contentView)
                        cell.selectionStyle = .none
                        cell.textLabel?.text = "Tap to toggle preset array"
                    }
                    
                    scheme.selectionHandler = { [unowned self] cell, scheme in
                        if !self.toggledArrayToggled {
                            self.tableScheme.animateChangesToScheme(self.toggledArrayScheme, inTableView: self.tableView) { animator in
                                animator.deleteObject(at: 1, with: .left)
                                animator.deleteObject(at: 3, with: .right)
                                animator.deleteObject(at: 5, with: .left)
                                animator.deleteObject(at: 7, with: .right)
                                animator.deleteObject(at: 8, with: .top)
                                animator.moveObject(at: 4, to: 3)
                                animator.moveObject(at: 6, to: 2)
                                animator.insertObject(at: 4, with: .top)
                                self.toggledArrayScheme.objects = [1,3,7,5,11]
                            }
                        } else {
                            self.tableScheme.animateChangesToScheme(self.toggledArrayScheme, inTableView: self.tableView) { animator in
                                animator.insertObject(at: 1, with: .left)
                                animator.insertObject(at: 3, with: .right)
                                animator.insertObject(at: 5, with: .left)
                                animator.insertObject(at: 7, with: .right)
                                animator.insertObject(at: 8, with: .top)
                                animator.moveObject(at: 2, to: 6)
                                animator.moveObject(at: 3, to: 4)
                                animator.deleteObject(at: 4, with: .top)
                                self.toggledArrayScheme.objects = [1,2,3,4,5,6,7,8,9]
                            }
                        }
                        
                        self.toggledArrayToggled = !self.toggledArrayToggled
                    }
                }
                
                toggledArrayScheme = builder.buildScheme { (scheme: ArraySchemeBuilder<Int, SchemeCell>) in
                    scheme.objects = [1,2,3,4,5,6,7,8,9]
                    
                    scheme.configurationHandler = { [unowned self] cell, object in
                        self.removeSubviewsInView(cell.contentView)
                        cell.selectionStyle = .none
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
                builder.buildScheme { (scheme: BasicSchemeBuilder) in

                    scheme.configurationHandler = { [unowned self] cell in
                        self.removeSubviewsInView(cell.contentView)
                        cell.selectionStyle = .none
                        cell.textLabel?.text = "Tap to toggle random inferred array"
                    }
                    
                    scheme.selectionHandler = { [unowned self] cell, object in
                        self.tableScheme.animateChangesToScheme(self.randomizedArrayScheme, inTableView: self.tableView, withAnimation: .fade) {
                            self.randomizedArrayScheme.objects = self.generateRandomizedArray()
                        }
                    }
                }
                
                randomizedArrayScheme = builder.buildScheme { (scheme: ArraySchemeBuilder<Int, SchemeCell>) in
                    scheme.objects = generateRandomizedArray()
                    
                    scheme.configurationHandler = { [unowned self] cell, object in
                        self.removeSubviewsInView(cell.contentView)
                        cell.selectionStyle = .none
                        cell.textLabel?.text = "\(object)"
                    }
                }
            }
        }
    }
    
    private func removeSubviewsInView(_ view: UIView) {
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
        
        items.sort { _, _ in
            arc4random() % 2 == 1 ? true : false
        }
        
        return items
    }
    
    func buttonPressed(_ button: UIButton) {
        if let tuple = tableScheme.schemeWithIndex(containing: button) {
            if tuple.scheme === toggleHiddenSchemeSetScheme {
                guard let index = tableScheme.attributedSchemeSets.index(where: { $0.schemeSet === self.hiddenSchemeSet }) else {
                    return
                }

                if tableScheme.attributedSchemeSets[index].hidden {
                    tableScheme.showSchemeSet(hiddenSchemeSet, in: tableView, with: .bottom)
                } else {
                    tableScheme.hideSchemeSet(hiddenSchemeSet, in: tableView, with: .top)
                }
            } else if tuple.scheme === toggleHiddenSchemesScheme {
                tableScheme.batchSchemeVisibilityChanges(in: tableView) { animator in
                    if schemesHidden {
                        animator.showScheme(hiddenScheme1, with: .left)
                        animator.showScheme(hiddenScheme2, with: .right)
                    } else {
                        animator.hideScheme(hiddenScheme2, with: .left)
                        animator.hideScheme(hiddenScheme1, with: .right)
                    }
                }
                
                schemesHidden = !schemesHidden
            }
        }
    }
}
