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
    var tableScheme: TableScheme!
    var firstSwitch: UISwitch!
    var secondSwitch: UISwitch!
    var firstField: UITextField!
    var secondField: UITextField!
    
    var wifiEnabled = false
    var bluetoothEnabled = false
    
    var firstFieldValue = ""
    var secondFieldValue = ""
    
    init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Advanced"
        tableView.rowHeight = 44.0
        tableView.registerClass(SchemeCell.self, forCellReuseIdentifier: SwitchReuseIdentifier)
        tableView.registerClass(InputFieldCell.self, forCellReuseIdentifier: InputReuseIdentifier)
        buildAndSetTableScheme()
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return tableScheme.heightInTableView(tableView, forIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableScheme.handleSelectionInTableView(tableView, forIndexPath: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func buildAndSetTableScheme() {
        tableScheme = TableScheme() { (builder) in
            builder.buildSchemeSet { (builder) in
                builder.name = "Switches"
                
                builder.buildScheme { (scheme: BasicScheme) in
                    scheme.reuseIdentifier = self.SwitchReuseIdentifier
                    
                    scheme.configurationHandler = { [unowned(unsafe) self] (cell) in
                        cell.textLabel.text = "First Switch"
                        cell.selectionStyle = .None
                        self.firstSwitch = UISwitch()
                        self.firstSwitch.on = self.wifiEnabled
                        self.firstSwitch.addTarget(self, action: "switcherUpdated:", forControlEvents: .ValueChanged) // Don't worry about this being reapplied on reuse; it has checks =)
                        cell.accessoryView = self.firstSwitch
                    }
                }
                
                builder.buildScheme { (scheme: BasicScheme) in
                    scheme.reuseIdentifier = self.SwitchReuseIdentifier
                    
                    scheme.configurationHandler = { [unowned(unsafe) self] (cell) in
                        cell.textLabel.text = "Second Switch"
                        cell.selectionStyle = .None
                        self.secondSwitch = UISwitch()
                        self.secondSwitch.on = self.bluetoothEnabled
                        self.secondSwitch.addTarget(self, action: "switcherUpdated:", forControlEvents: .ValueChanged)
                        cell.accessoryView = self.secondSwitch
                    }
                }
                
            }
            
            builder.buildSchemeSet { (builder) in
                builder.name = "Text Input"
                builder.buildScheme { (scheme: BasicScheme) in
                    scheme.reuseIdentifier = self.InputReuseIdentifier
                    
                    scheme.configurationHandler = { [unowned(unsafe) self] (uncastedCell) in // I feel like this is an incorrect compiler warning. We should be able to cast it in the closure :/
                        let cell = uncastedCell as InputFieldCell
                        cell.selectionStyle = .None
                        cell.label.text = "First Input:"
                        cell.input.text = self.firstFieldValue
                        cell.input.keyboardType = .Default // Since the other input cell changes this value, this cell must define what it wants to avoid reuse issues.
                        cell.input.addTarget(self, action: "controlResigned:", forControlEvents: .EditingDidEndOnExit)
                        cell.input.addTarget(self, action: "textFieldUpdated:", forControlEvents: .EditingDidEnd)
                        self.firstField = cell.input
                    }
                }
                
                builder.buildScheme { (scheme: BasicScheme) in
                    scheme.reuseIdentifier = self.InputReuseIdentifier
                    
                    scheme.configurationHandler = { [unowned(unsafe) self] (uncastedCell) in
                        let cell = uncastedCell as InputFieldCell
                        cell.selectionStyle = .None
                        cell.label.text = "Email:"
                        cell.input.text = self.secondFieldValue
                        cell.input.keyboardType = .EmailAddress
                        cell.input.addTarget(self, action: "controlResigned:", forControlEvents: .EditingDidEndOnExit)
                        cell.input.addTarget(self, action: "textFieldUpdated:", forControlEvents: .EditingDidEnd)
                        self.secondField = cell.input
                    }
                }
            }

        }
        
        tableView.dataSource = tableScheme
    }

    // MARK: Target-Action
    func switcherUpdated(switcher: UISwitch) {
        if switcher === self.firstSwitch {
            println("Toggle some feature, like allowing wifi!")
            self.wifiEnabled = switcher.on
        } else if switcher === self.secondSwitch {
            println("Toggle some other feature, like bluetooth!")
            self.bluetoothEnabled = switcher.on
        }
    }
    
    func textFieldUpdated(textField: UITextField) {
        if textField == self.firstField {
            println("Storing \"\(textField.text)\" for first text field!")
            self.firstFieldValue = textField.text
        } else if textField == self.secondField {
            println("Storing \"\(textField.text)\" for the email!")
            self.secondFieldValue = textField.text
        }
    }
    
    func controlResigned(control: UIResponder) {
        control.resignFirstResponder()
    }
}

class InputFieldCell: SchemeCell {
    let label = UILabel()
    let input = UITextField()
    
    init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        input.setTranslatesAutoresizingMaskIntoConstraints(false)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(input)
        setNeedsUpdateConstraints()
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
