//
//  ArrayScheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/12/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

/** This class is used with `TableScheme` to display an array of cells.

    Use this scheme when you want to have a set of cells that are based on an `Array`. An example of this case
    is displaying a font to choose, or wifi networks.

    It's recommended that you don't create these directly, and let the
    `SchemeSetBuilder.buildScheme(handler:)` method generate them
    for you.
 */
open class ArrayScheme<ElementType: Equatable, CellType: UITableViewCell>: Scheme {
    
    public typealias ConfigurationHandler = (_ cell: CellType, _ object: ElementType) -> Void
    public typealias SelectionHandler = (_ cell: CellType, _ scheme: ArrayScheme<ElementType, CellType>, _ object: ElementType) -> Void
    public typealias HeightHandler = (_ object: ElementType) -> RowHeight
    public typealias ReorderingHandler = (_ objects: [ElementType]) -> Void

    /** The objects this scheme is representing */
    open var objects: [ElementType]
    
    /**
     The closure called to determine the height of this cell.

     Unlike other `Scheme` implementations that take predefined
     values this scheme uses a closure because the height may change
     due to the underlying objects state, and this felt like a better
     API to accomodate that.

     This closure is only used if the table view delegate asks its
     `TableScheme` for the height with `    height(tableView:forIndexPath:)
    */
    open var heightHandler: HeightHandler?
    
    /** The closure called for configuring the cell the scheme is representing. */
    open var configurationHandler: ConfigurationHandler
    
    /**
     The closure called when the cell is selected.

     NOTE: This is only called if the TableScheme is asked to handle selection
     by the table view delegate.
     */
    open var selectionHandler: SelectionHandler?

    /**
     The closure called when objects have been reordered by a drag-and-drop operation.

     If the value is `nil` the cells will not be reorderable.
     */
    open var reorderingHandler: ReorderingHandler?
    
    // MARK: Property Overrides
    open var numberOfCells: Int {
        return objects.count
    }
    
    public init(objects: [ElementType], configurationHandler: @escaping ConfigurationHandler) {
        self.objects = objects
        self.configurationHandler = configurationHandler
    }
    
    // MARK: Public Instance Methods
    open func configureCell(_ cell: UITableViewCell, withRelativeIndex relativeIndex: Int) {
        configurationHandler(cell as! CellType, objects[relativeIndex])
    }
    
    open func selectCell(_ cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int) {
        if let sh = selectionHandler {
            sh(cell as! CellType, self, objects[relativeIndex])
        }
    }
    
    open func reuseIdentifier(forRelativeIndex relativeIndex: Int) -> String {
        return String(describing: CellType.self)
    }
    
    open func height(forRelativeIndex relativeIndex: Int) -> RowHeight {
        if let hh = heightHandler {
            return hh(objects[relativeIndex])
        } else {
            return .useTable
        }
    }

    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard reorderingHandler != nil else { return [] }
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = objects[indexPath.row]
        return [dragItem]
    }

    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        guard reorderingHandler != nil, session.localDragSession != nil else {
            return UITableViewDropProposal(operation: .cancel)
        }
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {

        guard let reorderingHandler = reorderingHandler,
            coordinator.proposal.operation == .move,
            coordinator.items.count == 1,
            let item = coordinator.items.first,
            let sourceIndexPath = item.sourceIndexPath,
            let localObject = item.dragItem.localObject as? ElementType else {
                return
        }

        let destinationIndexPath: IndexPath

        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }

        tableView.performBatchUpdates({
            objects.remove(at: sourceIndexPath.row)
            objects.insert(localObject, at: destinationIndexPath.row)

            tableView.insertRows(at: [destinationIndexPath], with: .none)
            tableView.deleteRows(at: [sourceIndexPath], with: .fade)

        }, completion: { _ in
            reorderingHandler(self.objects)
        })
    }

}

extension ArrayScheme: InferrableRowAnimatableScheme {

    public typealias IdentifierType = ElementType
    
    public var rowIdentifiers: [IdentifierType] {
        return objects
    }

}

extension ArrayScheme: InferrableReuseIdentifierScheme {

    public var reusePairs: [(identifier: String, cellType: UITableViewCell.Type)] {
        return [(identifier: String(describing: CellType.self), cellType: CellType.self)]
    }

}
