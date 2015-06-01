//
//  AdvancedTableSchemeViewController.swift
//  TableSchemer
//
//  Created by James Richard on 7/2/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

class AdvancedTableSchemeViewController: UITableViewController {
    let SwitchReuseIdentifier = "SwitchCell"
    let InputReuseIdentifier = "InputCell"
    let BasicReuseIdentifier = "BasicCell"
    var tableScheme: TableScheme!
    var firstSwitchScheme: Scheme!
    var secondSwitchScheme: Scheme!
    var firstFieldScheme: Scheme!
    var secondFieldScheme: Scheme!
    var buttonsScheme: ArrayScheme<String, SchemeCell>!
    
    var wifiEnabled = false
    var bluetoothEnabled = false
    
    var firstFieldValue = ""
    var secondFieldValue = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Advanced"
        tableView.rowHeight = 44.0
        tableView.registerClass(SchemeCell.self, forCellReuseIdentifier: SwitchReuseIdentifier)
        tableView.registerClass(InputFieldCell.self, forCellReuseIdentifier: InputReuseIdentifier)
        tableView.registerClass(SchemeCell.self, forCellReuseIdentifier: BasicReuseIdentifier)
        buildAndSetTableScheme()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableScheme.heightInTableView(tableView, forIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableScheme.handleSelectionInTableView(tableView, forIndexPath: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func buildAndSetTableScheme() {
        tableScheme = TableScheme { builder in
            builder.buildSchemeSet { builder in
                builder.name = "Switches"
                
                firstSwitchScheme = builder.buildScheme { (scheme: BasicScheme) in
                    scheme.reuseIdentifier = SwitchReuseIdentifier
                    
                    scheme.configurationHandler = { [unowned(unsafe) self] cell in
                        cell.textLabel?.text = "First Switch"
                        cell.selectionStyle = .None
                        let switchView = UISwitch()
                        switchView.on = self.wifiEnabled
                        switchView.addTarget(self, action: "switcherUpdated:", forControlEvents: .ValueChanged) // Don't worry about this being reapplied on reuse; it has checks =)
                        cell.accessoryView = switchView
                    }
                }
                
                secondSwitchScheme = builder.buildScheme { (scheme: BasicScheme) in
                    scheme.reuseIdentifier = SwitchReuseIdentifier
                    
                    scheme.configurationHandler = { [unowned(unsafe) self] cell in
                        cell.textLabel?.text = "Second Switch"
                        cell.selectionStyle = .None
                        let switchView = UISwitch()
                        switchView.on = self.bluetoothEnabled
                        switchView.addTarget(self, action: "switcherUpdated:", forControlEvents: .ValueChanged)
                        cell.accessoryView = switchView
                    }
                }
                
            }
            
            builder.buildSchemeSet { builder in
                builder.name = "Text Input"
                builder.footerText = "Section footer text"
                
                firstFieldScheme = builder.buildScheme { (scheme: BasicScheme<InputFieldCell>) in
                    scheme.reuseIdentifier = InputReuseIdentifier
                    
                    scheme.configurationHandler = { [unowned(unsafe) self] cell in
                        cell.selectionStyle = .None
                        cell.label.text = "First Input:"
                        cell.input.text = self.firstFieldValue
                        cell.input.keyboardType = .Default // Since the other input cell changes this value, this cell must define what it wants to avoid reuse issues.
                        cell.input.addTarget(self, action: "controlResigned:", forControlEvents: .EditingDidEndOnExit)
                        cell.input.addTarget(self, action: "textFieldUpdated:", forControlEvents: .EditingDidEnd)
                    }
                }
                
                secondFieldScheme = builder.buildScheme { (scheme: BasicScheme<InputFieldCell>) in
                    scheme.reuseIdentifier = InputReuseIdentifier
                    
                    scheme.configurationHandler = { [unowned(unsafe) self] cell in
                        cell.selectionStyle = .None
                        cell.label.text = "Email:"
                        cell.input.text = self.secondFieldValue
                        cell.input.keyboardType = .EmailAddress
                        cell.input.addTarget(self, action: "controlResigned:", forControlEvents: .EditingDidEndOnExit)
                        cell.input.addTarget(self, action: "textFieldUpdated:", forControlEvents: .EditingDidEnd)
                    }
                }
            }
            
            builder.buildSchemeSet { builder in
                builder.name = "Buttons!"
                
                buttonsScheme = builder.buildScheme { (scheme: ArrayScheme<String, SchemeCell>) in
                    scheme.reuseIdentifier = self.BasicReuseIdentifier
                    scheme.objects = ["First", "Second", "Third", "Fourth"]
                    
                    scheme.configurationHandler = { [unowned(unsafe) self] cell, object in
                        cell.selectionStyle = .None
                        cell.textLabel?.text = object
                        let button = UIButton.buttonWithType(.InfoDark) as! UIButton
                        button.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
                        cell.accessoryView = button
                    }
                }
            }
        }
        
        tableView.dataSource = tableScheme
    }

    // MARK: Target-Action
    func switcherUpdated(switcher: UISwitch) {
        if let scheme = tableScheme.schemeContainingView(switcher) {
            if scheme === self.firstSwitchScheme {
                println("Toggle some feature, like allowing wifi!")
                self.wifiEnabled = switcher.on
            } else if scheme === self.secondSwitchScheme {
                println("Toggle some other feature, like bluetooth!")
                self.bluetoothEnabled = switcher.on
            }
        }
    }
    
    func textFieldUpdated(textField: UITextField) {
        if let scheme = tableScheme.schemeContainingView(textField) {
            if scheme === self.firstFieldScheme {
                println("Storing \"\(textField.text)\" for first text field!")
                self.firstFieldValue = textField.text
            } else if scheme === self.secondFieldScheme {
                println("Storing \"\(textField.text)\" for the email!")
                self.secondFieldValue = textField.text
            }
        }
    }
    
    func buttonPressed(button: UIButton) {
        if let tuple = tableScheme.schemeWithIndexContainingView(button) {
            if tuple.scheme === buttonsScheme {
                let object = buttonsScheme.objects![tuple.index]
                println("You pressed the button with object: \(object)")
            }
        }
    }
    
    func controlResigned(control: UIResponder) {
        control.resignFirstResponder()
    }
}

class InputFieldCell: SchemeCell {
    let label = UILabel()
    let input = UITextField()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        input.setTranslatesAutoresizingMaskIntoConstraints(false)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(input)
        setNeedsUpdateConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        let views = ["label": label, "input": input]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[label]-5-|", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[input]-5-|", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[label]", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[input(150)]-20-|", options: nil, metrics: nil, views: views))
        
        super.updateConstraints()
    }
}
