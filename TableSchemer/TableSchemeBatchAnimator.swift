//
//  TableSchemeBatchAnimator.swift
//  TableSchemer
//
//  Created by James Richard on 11/18/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

/**
    This class is passed into the closure for performing batch animations to a TableScheme. It will record
    your changes to the TableScheme's SchemeSet and Scheme visibility, and then perform them all in one batch
    at the end of the TableScheme's batch operation method.
*/
public final class TableSchemeBatchAnimator {
    private struct Row {
        let animation: UITableViewRowAnimation
        let attributedSchemeSetIndex: Array<AttributedSchemeSet>.Index
        let attributedSchemeIndex: Array<AttributedScheme>.Index
    }
    
    private struct Section {
        let animation: UITableViewRowAnimation
        let attributedSchemeSetIndex: Array<AttributedSchemeSet>.Index
    }
    
    private var rowInsertions = [Row]()
    private var rowDeletions = [Row]()
    private var rowReloads = [Row]()
    private var sectionInsertions = [Section]()
    private var sectionDeletions = [Section]()
    private var sectionReloads = [Section]()
    
    private let tableScheme: TableScheme
    private let tableView: UITableView
    
    init(tableScheme: TableScheme, withTableView tableView: UITableView) {
        self.tableScheme = tableScheme
        self.tableView = tableView
    }
    
    /**
        Shows a Scheme within a batch update using the given animation.
        
        The passed in Scheme must belong to the TableScheme.
        
        - parameter     scheme:          The scheme to show.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func showScheme(_ scheme: Scheme, with rowAnimation: UITableViewRowAnimation = .automatic) {
        let indexes = tableScheme.attributedSchemeIndexesWithScheme(scheme)!
        rowInsertions.append(Row(animation: rowAnimation, attributedSchemeSetIndex: indexes.schemeSetIndex, attributedSchemeIndex: indexes.schemeIndex))
    }
    
    /**
        Hides a Scheme within a batch update.
        
        The passed in Scheme must belong to the TableScheme.
        
        - parameter     scheme:          The scheme to hide.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func hideScheme(_ scheme: Scheme, with rowAnimation: UITableViewRowAnimation = .automatic) {
        let indexes = tableScheme.attributedSchemeIndexesWithScheme(scheme)!
        rowDeletions.append(Row(animation: rowAnimation, attributedSchemeSetIndex: indexes.schemeSetIndex, attributedSchemeIndex: indexes.schemeIndex))
    }
    
    /**
        Reloads a Scheme within a batch update.
    
        The passed in Scheme must belong to the TableScheme.
        
        - parameter     scheme:          The scheme to reload.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func reloadScheme(_ scheme: Scheme, with rowAnimation: UITableViewRowAnimation = .automatic) {
        let indexes = tableScheme.attributedSchemeIndexesWithScheme(scheme)!
        rowReloads.append(Row(animation: rowAnimation, attributedSchemeSetIndex: indexes.schemeSetIndex, attributedSchemeIndex: indexes.schemeIndex))
    }
    
    /**
        Shows a SchemeSet within a batch update using the given animation.
        
        The passed in SchemeSet must belong to the TableScheme.
        
        - parameter     schemeSet:       The schemeSet to hide.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func showSchemeSet(_ schemeSet: SchemeSet, with rowAnimation: UITableViewRowAnimation = .automatic) {
        guard let index = tableScheme.attributedSchemeSets.index(where: { $0.schemeSet === schemeSet }) else {
            NSLog("ERROR: Could not locate \(schemeSet) within \(tableScheme)")
            return
        }

        sectionInsertions.append(Section(animation: rowAnimation, attributedSchemeSetIndex: index))
    }
    
    /**
        Hides a SchemeSet within a batch update using the given animation.
        
        The passed in SchemeSet must belong to the TableScheme.
        
        - parameter     schemeSet:       The schemeSet to hide.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func hideSchemeSet(_ schemeSet: SchemeSet, with rowAnimation: UITableViewRowAnimation = .automatic) {
        guard let index = tableScheme.attributedSchemeSets.index(where: { $0.schemeSet === schemeSet }) else {
            NSLog("ERROR: Could not locate \(schemeSet) within \(tableScheme)")
            return
        }

        sectionDeletions.append(Section(animation: rowAnimation, attributedSchemeSetIndex: index))
    }
    
    /**
        Reloads a SchemeSet within a batch update.
        
        The passed in SchemeSet must belong to the TableScheme.
        
        - parameter     schemeSet:       The schemeSet to reload.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func reloadSchemeSet(_ schemeSet: SchemeSet, with rowAnimation: UITableViewRowAnimation = .automatic) {
        guard let index = tableScheme.attributedSchemeSets.index(where: { $0.schemeSet === schemeSet }) else {
            NSLog("ERROR: Could not locate \(schemeSet) within \(tableScheme)")
            return
        }

        sectionReloads.append(Section(animation: rowAnimation, attributedSchemeSetIndex: index))
    }
    
    // MARK: - Internal methods
    func performVisibilityChanges() {
        // Don't notify table view of changes in hidden scheme sets, or scheme sets we're already notifying about.
        let hiddenSchemeSets = tableScheme.attributedSchemeSets.filter({ $0.hidden }).map({ $0.schemeSet })
        let mutatedSchemeSets = (sectionDeletions + sectionInsertions + sectionReloads).map { self.tableScheme.attributedSchemeSets[$0.attributedSchemeSetIndex].schemeSet }
        let ignoredSchemeSets: [SchemeSet] = hiddenSchemeSets + mutatedSchemeSets

        // Get the index paths of the schemes we are deleting. This will give us the deletion index paths. We need to do
        // this before marking them as hidden so indexPathForScheme doesn't skip it

        let deleteRows = rowDeletions.filter { row in
            ignoredSchemeSets.index { self.tableScheme.attributedSchemeSets[row.attributedSchemeSetIndex].schemeSet === $0 } == nil
        }.reduce([UITableViewRowAnimation: [IndexPath]]()) { memo, change in
            var memo = memo
            if memo[change.animation] == nil {
                memo[change.animation] = [IndexPath]()
            }

            let scheme = self.tableScheme.attributedSchemeSets[change.attributedSchemeSetIndex].schemeSet.attributedSchemes[change.attributedSchemeIndex].scheme
            memo[change.animation]! += self.tableScheme.indexPathsForScheme(scheme)
            
            return memo
        }
        
        let deleteSections = sectionDeletions.reduce([UITableViewRowAnimation: NSMutableIndexSet]()) { memo, change in
            var memo = memo
            if memo[change.animation] == nil {
                memo[change.animation] = NSMutableIndexSet() as NSMutableIndexSet
            }

            let schemeSet = tableScheme.attributedSchemeSets[change.attributedSchemeSetIndex].schemeSet

            memo[change.animation]!.add(self.tableScheme.sectionForSchemeSet(schemeSet))
            
            return memo
        }
        
        // We also need the index paths of the reloaded schemes and sections before making changes to the table.
        
        let reloadRows = rowReloads.filter { row in
            ignoredSchemeSets.index { self.tableScheme.attributedSchemeSets[row.attributedSchemeSetIndex].schemeSet === $0 } == nil
        }.reduce([UITableViewRowAnimation: [IndexPath]]()) { memo, change in
            var memo = memo
            if memo[change.animation] == nil {
                memo[change.animation] = [IndexPath]()
            }

            let scheme = self.tableScheme.attributedSchemeSets[change.attributedSchemeSetIndex].schemeSet.attributedSchemes[change.attributedSchemeIndex].scheme
            memo[change.animation]! += self.tableScheme.indexPathsForScheme(scheme)
            
            return memo
        }
        
        let reloadSections = sectionReloads.reduce([UITableViewRowAnimation: NSMutableIndexSet]()) { memo, change in
            var memo = memo
            if memo[change.animation] == nil {
                memo[change.animation] = NSMutableIndexSet() as NSMutableIndexSet
            }

            let schemeSet = tableScheme.attributedSchemeSets[change.attributedSchemeSetIndex].schemeSet
            
            memo[change.animation]!.add(self.tableScheme.sectionForSchemeSet(schemeSet))
            
            return memo
        }
        
        // Now update the visibility of all our batches
        
        for change in rowInsertions {
            tableScheme.attributedSchemeSets[change.attributedSchemeSetIndex].schemeSet.attributedSchemes[change.attributedSchemeIndex].hidden = false
        }
        
        for change in rowDeletions {
            tableScheme.attributedSchemeSets[change.attributedSchemeSetIndex].schemeSet.attributedSchemes[change.attributedSchemeIndex].hidden = true
        }
        
        for change in sectionDeletions {
            tableScheme.attributedSchemeSets[change.attributedSchemeSetIndex].hidden = true
        }
        
        for change in sectionInsertions {
            tableScheme.attributedSchemeSets[change.attributedSchemeSetIndex].hidden = false
        }
        
        // Now obtain the index paths for the inserted schemes. These will have their inserted index paths, skipping ones removed,
        // and correctly finding the ones that are visible
        
        let insertRows = rowInsertions.filter { row in
            ignoredSchemeSets.index { self.tableScheme.attributedSchemeSets[row.attributedSchemeSetIndex].schemeSet === $0 } == nil
        }.reduce([UITableViewRowAnimation: [IndexPath]]()) { memo, change in
            var memo = memo
            if memo[change.animation] == nil {
                memo[change.animation] = [IndexPath]()
            }

            let scheme = self.tableScheme.attributedSchemeSets[change.attributedSchemeSetIndex].schemeSet.attributedSchemes[change.attributedSchemeIndex].scheme
            memo[change.animation]! += self.tableScheme.indexPathsForScheme(scheme)
            
            return memo
        }
        
        let insertSections = sectionInsertions.reduce([UITableViewRowAnimation: NSMutableIndexSet]()) { memo, change in
            var memo = memo
            if memo[change.animation] == nil {
                memo[change.animation] = NSMutableIndexSet() as NSMutableIndexSet
            }

            let schemeSet = tableScheme.attributedSchemeSets[change.attributedSchemeSetIndex].schemeSet
            
            memo[change.animation]!.add(self.tableScheme.sectionForSchemeSet(schemeSet))
            
            return memo
        }
        
        // Now we have all the data we need to execute our animations. Perform them!
        
        for (animation, changes) in insertRows {
            tableView.insertRows(at: changes, with: animation)
        }
        
        for (animation, changes) in deleteRows {
            tableView.deleteRows(at: changes, with: animation)
        }
        
        for (animation, changes) in insertSections {
            tableView.insertSections(changes as IndexSet, with: animation)
        }
        
        for (animation, changes) in deleteSections {
            tableView.deleteSections(changes as IndexSet, with: animation)
        }
        
        for (animation, changes) in reloadRows {
            tableView.reloadRows(at: changes, with: animation)
        }
        
        for (animation, changes) in reloadSections {
            tableView.reloadSections(changes as IndexSet, with: animation)
        }
    }
}
