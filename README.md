TableSchemer is a framework for building static interactive table views. Interface Builder provides a great way to build out static table views, but not everyone uses interface builder, and adding interactivity to these table views is difficult. Writing interactive static table views traditionally is a tiresome task due to working with index paths, and having multiple delegate methods to handle configuration, sizing, and selection handling. They're also a huge pain to maintain when the need to reorder them comes as you need to update the index paths in all those locations.

## Features

### Closure-based Table Views

Build your table view using closures, and have all of your cell(s) logic in one place. Forget index path comparisons, and focus on writing your logic. Thanks to Generics in Swift you can just work with your cell type and not worry about casting. 

### Built-in Schemes

TableSchemer comes with a variety of powerful schemes already built-in. Included is a basic scheme (for when you just need to render one cell), a radio scheme (for when you need a single cell in a group of cells selected at once), an array scheme (for when you need a dynamic set of cells backed by specific objects), and an accordion scheme (for when you need one cell to expand into many for a collapsed selection). Check out how to use them

### Extendable

You can easily create your own Schemes and add them into your tables. With a few method overrides you can start creating unique, intuitive controls for your users.

## Getting Started

* Download TableSchemer and see it in action using the example app
* Start building your own tables by installing it in your own app. See [Using Table Schemer](wiki/Using-Table-Schemer) for more information on how to use Table Schemer.

## Requirements

TableSchemer is built using Swift. It's also taking advantage of advanced features, so it requires that you use Xcode 6 and build them using Swift. It supports iOS 7.0+.

## Usage

TableSchemer works by creating a TableScheme object and setting it as your UITableView's dataSource property. Here's an example of using it with a UITableViewController:

```swift
class MasterViewController: UITableViewController {
    let ReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                return // Trailing closures will attempt to return the SchemeSet without this since it's a "one line" expression
            }
        }
    }
}

```

TableSchemer supports configuring selection handlers and height, but you need to be sure to forward delegate methods to the tableScheme object. Check out the [Using Table Schemer](wiki/Using-Table-Schemer) page for how to do that and more, and be sure to check out our sample app!

## Contributing

We love to have your help to make TableSchemer better. Feel free to

 - open an issue if you run into any problem.
 - fork the project and submit pull request. Before the pull requests can be accepted, a Contributors Licensing Agreement must be signed.

## License

Copyright (c) 2014, Weebly All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. Neither the name of Weebly nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Weebly, Inc BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
