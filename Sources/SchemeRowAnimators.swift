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
    private struct AddRemove {
        let animation: UITableViewRowAnimation
        let index: Int
    }
    
    private struct Move {
        let fromIndex: Int
        let toIndex: Int
    }
    
    private final let tableScheme: TableScheme
    private final let tableView: UITableView
    public final let scheme: Scheme
    
    private var moves = [Move]()
    private var insertions = [AddRemove]()
    private var deletions = [AddRemove]()
    
    init(tableScheme: TableScheme, withScheme scheme: Scheme, inTableView tableView: UITableView) {
        self.tableScheme = tableScheme
        self.scheme = scheme
        self.tableView = tableView
    }
    
    /**
        Records the row at index to move to toIndex at the end of the batch closure.
        
        The indexes are relative to the scheme, and cells above or below this scheme
        should not be considered when making calls to this method.
        
        :param:     index       The index to move the row from.
        :param:     toIndex     The index to move the row to.
    */
    public final func moveObjectAtIndex(index: Int, toIndex: Int) {
        moves.append(Move(fromIndex: index, toIndex: toIndex))
    }
    
    /**
        Records the row to be removed from index using animation at the end of the batch closure.
        
        The indexes are relative to the scheme, and cells above or below this scheme
        should not be considered when making calls to this method.
        
        :param:     index           The index to remove.
        :param:     rowAnimation    The type of animation to perform.
    */
    public final func deleteObjectAtIndex(index: Int, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        deletions.append(AddRemove(animation: rowAnimation, index: index))
    }
    
    /**
        Records the row to be inserted to index using animation at the end of the batch closure.
        
        The indexes are relative to the scheme, and cells above or below this scheme
        should not be considered when making calls to this method.
        
        :param:     index               The index to insert.
        :param:     rowAnimation        The type of animation to perform.
    */
    public final func insertObjectAtIndex(index: Int, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        insertions.append(AddRemove(animation: rowAnimation, index: index))
    }
    
    /**
        Records a range of rows to be removed from indexes using animation at the end of the batch closure.
        
        The indexes are relative to the scheme, and cells above or below this scheme
        should not be considered when making calls to this method.
        
        :param:     indexes         The indexes to remove.
        :param:     rowAnimation       The type of animation to perform.
    */
    public final func deleteObjectsAtIndexes(indexes: Range<Int>, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        for i in indexes {
            deletions.append(AddRemove(animation: rowAnimation, index: i))
        }
    }
    
    /**
        Records a range of rows to be inserted to indexes using animation at the end of the batch closure.
        
        The indexes are relative to the scheme, and cells above or below this scheme
        should not be considered when making calls to this method.
        
        :param:     indexes         The indexes to insert.
        :param:     rowAnimation    The type of animation to perform.
    */
    public final func insertObjectsAtIndexes(indexes: Range<Int>, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
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
        let insertRows = insertions.reduce([UITableViewRowAnimation: [NSIndexPath]]()) { (var memo, animation) in
            if memo[animation.animation] == nil {
                memo[animation.animation] = [NSIndexPath]()
            }
            
            memo[animation.animation]!.append(NSIndexPath(forRow: rowsBeforeScheme + animation.index, inSection: section))
            
            return memo
        }
        
        let deleteRows = deletions.reduce([UITableViewRowAnimation: [NSIndexPath]]()) { (var memo, animation) in
            if memo[animation.animation] == nil {
                memo[animation.animation] = [NSIndexPath]()
            }
            
            memo[animation.animation]!.append(NSIndexPath(forRow: rowsBeforeScheme + animation.index, inSection: section))
            
            return memo
        }
        
        // Perform the animations
        for move in moves {
            tableView.moveRowAtIndexPath(NSIndexPath(forRow: rowsBeforeScheme + move.fromIndex, inSection: section), toIndexPath: NSIndexPath(forRow: rowsBeforeScheme + move.toIndex, inSection: section))
        }
        
        for (animation, insertions) in insertRows {
            tableView.insertRowsAtIndexPaths(insertions, withRowAnimation: animation)
        }
        
        for (animation, deletions) in deleteRows {
            tableView.deleteRowsAtIndexPaths(deletions, withRowAnimation: animation)
        }
        
        tableView.endUpdates()
    }
}

final class InferringRowAnimator<T: Scheme where T: InferrableRowAnimatableScheme>: SchemeRowAnimator {
    private let originalRowIdentifiers: [T.IdentifierType]
    private var animatableScheme: T {
        return scheme as! T
    }
    
    init(tableScheme: TableScheme, withScheme scheme: T, inTableView tableView: UITableView) {
        originalRowIdentifiers = scheme.rowIdentifiers
        super.init(tableScheme: tableScheme, withScheme: scheme, inTableView: tableView)
    }
    
    func guessRowAnimationsWithAnimation(animation: UITableViewRowAnimation) {
        let updatedRowIdentifiers = animatableScheme.rowIdentifiers
        var addedIdentifiers = updatedRowIdentifiers // Will remove objects when they are found in the original identifiers
        var immovableIndexes = Dictionary<Array<T.IdentifierType>.Index, Void>() // To help with multiple equal objects
        
        for (index, identifier) in enumerate(originalRowIdentifiers) {
            if let newIndex = findIdentifier(identifier, inIdentifiers: updatedRowIdentifiers, excludingIndexes: immovableIndexes) {
                // Handle possibility of it moved
                if index != newIndex {
                    // Object was moved
                    moves.append(Move(fromIndex: index, toIndex: newIndex))
                    
                } // No animations performed if the index is the same
                
                // Prevent this index from being considered moved in the future
                immovableIndexes[newIndex] = ()
                
                // Object was in both original and updated, so we can remove it from our list of added identifiers
                addedIdentifiers.removeAtIndex(find(addedIdentifiers, updatedRowIdentifiers[newIndex])!)
            } else {
                // Object was deleted, so mark this row deleted
                deletions.append(AddRemove(animation: animation, index: index))
            }
        }
        
        for added in addedIdentifiers {
            insertions.append(AddRemove(animation: animation, index: find(updatedRowIdentifiers, added)!))
        }
    }
    
    private func findIdentifier(identifier: T.IdentifierType, inIdentifiers identifiers: [T.IdentifierType], excludingIndexes excludedIndexes: Dictionary<Array<T.IdentifierType>.Index, Void>) -> Array<T.IdentifierType>.Index? {
        var foundIndex: Array<T.IdentifierType>.Index?
        
        for (index, ident) in enumerate(identifiers) {
            if excludedIndexes[index] == nil && ident == identifier {
                foundIndex = index
                break
            }
        }
        
        return foundIndex
    }
}
