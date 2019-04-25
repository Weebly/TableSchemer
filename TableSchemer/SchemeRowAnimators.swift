//
//  SchemeRowAnimators.swift
//  TableSchemer
//
//  Created by James Richard on 11/18/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

/**
    An instance of this class is passed into the closure for explicitly animating rows of a scheme. It records the animation methods
    called and then batches them to the passed in UITableView.
*/
public class SchemeRowAnimator {
    fileprivate struct AddRemove {
        let animation: UITableView.RowAnimation
        let index: Int
    }
    
    fileprivate struct Move {
        let fromIndex: Int
        let toIndex: Int
    }
    
    private final let tableScheme: TableScheme
    private final let tableView: UITableView
    final let attributedScheme: AttributedScheme
    public final var scheme: Scheme {
        return attributedScheme.scheme
    }
    
    fileprivate var moves = [Move]()
    fileprivate var insertions = [AddRemove]()
    fileprivate var deletions = [AddRemove]()
    
    init(tableScheme: TableScheme, with attributedScheme: AttributedScheme, in tableView: UITableView) {
        self.tableScheme = tableScheme
        self.attributedScheme = attributedScheme
        self.tableView = tableView
    }
    
    /**
        Records the row at index to move to toIndex at the end of the batch closure.
        
        The indexes are relative to the scheme, and cells above or below this scheme
        should not be considered when making calls to this method.
        
        - parameter     index:       The index to move the row from.
        - parameter     toIndex:     The index to move the row to.
    */
    public final func moveObject(at index: Int, to toIndex: Int) {
        moves.append(Move(fromIndex: index, toIndex: toIndex))
    }
    
    /**
        Records the row to be removed from index using animation at the end of the batch closure.
        
        The indexes are relative to the scheme, and cells above or below this scheme
        should not be considered when making calls to this method.
        
        - parameter     index:           The index to remove.
        - parameter     rowAnimation:    The type of animation to perform.
    */
    public final func deleteObject(at index: Int, with rowAnimation: UITableView.RowAnimation = .automatic) {
        deletions.append(AddRemove(animation: rowAnimation, index: index))
    }
    
    /**
        Records the row to be inserted to index using animation at the end of the batch closure.
        
        The indexes are relative to the scheme, and cells above or below this scheme
        should not be considered when making calls to this method.
        
        - parameter     index:               The index to insert.
        - parameter     rowAnimation:        The type of animation to perform.
    */
    public final func insertObject(at index: Int, with rowAnimation: UITableView.RowAnimation = .automatic) {
        insertions.append(AddRemove(animation: rowAnimation, index: index))
    }
    
    /**
        Records a range of rows to be removed from indexes using animation at the end of the batch closure.
        
        The indexes are relative to the scheme, and cells above or below this scheme
        should not be considered when making calls to this method.
        
        - parameter     indexes:         The indexes to remove.
        - parameter     rowAnimation:    The type of animation to perform.
    */
    public final func deleteObjects(at indexes: CountableClosedRange<Int>, with rowAnimation: UITableView.RowAnimation = .automatic) {
        for i in indexes {
            deletions.append(AddRemove(animation: rowAnimation, index: i))
        }
    }
    
    /**
        Records a range of rows to be inserted to indexes using animation at the end of the batch closure.
        
        The indexes are relative to the scheme, and cells above or below this scheme
        should not be considered when making calls to this method.
        
        - parameter     indexes:         The indexes to insert.
        - parameter     rowAnimation:    The type of animation to perform.
    */
    public final func insertObjects(at indexes: CountableClosedRange<Int>, with rowAnimation: UITableView.RowAnimation = .automatic) {
        for i in indexes {
            insertions.append(AddRemove(animation: rowAnimation, index: i))
        }
    }
    
    final func performAnimations() {
        let schemeSet = tableScheme.schemeSetWithScheme(scheme)
        let section = tableScheme.sectionForSchemeSet(schemeSet)
        let rowsBeforeScheme = tableScheme.rowsBeforeScheme(scheme)
        
        tableView.beginUpdates()
        
        // Compact our insertions/deletions so we do as few table view animation calls as necessary
        let insertRows = insertions.reduce([UITableView.RowAnimation: [IndexPath]]()) { memo, animation in
            var memo = memo
            if memo[animation.animation] == nil {
                memo[animation.animation] = [IndexPath]()
            }
            
            memo[animation.animation]!.append(IndexPath(row: rowsBeforeScheme + animation.index, section: section))
            
            return memo
        }
        
        let deleteRows = deletions.reduce([UITableView.RowAnimation: [IndexPath]]()) { memo, animation in
            var memo = memo
            if memo[animation.animation] == nil {
                memo[animation.animation] = [IndexPath]()
            }
            
            memo[animation.animation]!.append(IndexPath(row: rowsBeforeScheme + animation.index, section: section))
            
            return memo
        }
        
        // Perform the animations
        for move in moves {
            tableView.moveRow(at: IndexPath(row: rowsBeforeScheme + move.fromIndex, section: section), to: IndexPath(row: rowsBeforeScheme + move.toIndex, section: section))
        }
        
        for (animation, insertions) in insertRows {
            tableView.insertRows(at: insertions, with: animation)
        }
        
        for (animation, deletions) in deleteRows {
            tableView.deleteRows(at: deletions, with: animation)
        }
        
        tableView.endUpdates()
    }
}

final class InferringRowAnimator<AnimatableScheme: Scheme>: SchemeRowAnimator where AnimatableScheme: InferrableRowAnimatableScheme {
    private let originalRowIdentifiers: [AnimatableScheme.IdentifierType]
    private var animatableScheme: AnimatableScheme {
        return scheme as! AnimatableScheme
    }

    init(tableScheme: TableScheme, with scheme: AnimatableScheme, ownedBy attributedScheme: AttributedScheme, in tableView: UITableView) {
        assert(scheme === attributedScheme.scheme)
        originalRowIdentifiers = scheme.rowIdentifiers
        super.init(tableScheme: tableScheme, with: attributedScheme, in: tableView)
    }
    
    func guessRowAnimations(with animation: UITableView.RowAnimation) {
        let updatedRowIdentifiers = animatableScheme.rowIdentifiers
        var addedIdentifiers = updatedRowIdentifiers // Will remove objects when they are found in the original identifiers
        var immovableIndexes = Dictionary<Array<AnimatableScheme.IdentifierType>.Index, Void>() // To help with multiple equal objects
        
        for (index, identifier) in originalRowIdentifiers.enumerated() {
            if let newIndex = findIdentifier(identifier, in: updatedRowIdentifiers, excluding: immovableIndexes) {
                // Handle possibility of it moved
                if index != newIndex {
                    // Object was moved
                    moves.append(Move(fromIndex: index, toIndex: newIndex))
                    
                } // No animations performed if the index is the same
                
                // Prevent this index from being considered moved in the future
                immovableIndexes[newIndex] = ()
                
                // Object was in both original and updated, so we can remove it from our list of added identifiers
                addedIdentifiers.remove(at: addedIdentifiers.firstIndex(of: updatedRowIdentifiers[newIndex])!)
            } else {
                // Object was deleted, so mark this row deleted
                deletions.append(AddRemove(animation: animation, index: index))
            }
        }
        
        for added in addedIdentifiers {
            insertions.append(AddRemove(animation: animation, index: updatedRowIdentifiers.firstIndex(of: added)!))
        }
    }
    
    private func findIdentifier(_ identifier: AnimatableScheme.IdentifierType, in identifiers: [AnimatableScheme.IdentifierType], excluding excludedIndexes: Dictionary<Array<AnimatableScheme.IdentifierType>.Index, Void>) -> Array<AnimatableScheme.IdentifierType>.Index? {
        var foundIndex: Array<AnimatableScheme.IdentifierType>.Index?
        
        for (index, ident) in identifiers.enumerated() {
            if excludedIndexes[index] == nil && ident == identifier {
                foundIndex = index
                break
            }
        }
        
        return foundIndex
    }
}
