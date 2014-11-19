//
//  TableScheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/13/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

/**
 *    This class can be used as the data source to a UITableView's dataSource. It
 *    is driven by scheme sets, which are mapped directly to a section in the table
 *    view's index paths. Inside each scheme set is an array of schemes. These
 *    schemes provide varying functionlity and allow you to encapsulate all
 *    information about a particular cell, such as a configuration block or row height, in an object.
 */
public class TableScheme: NSObject, UITableViewDataSource {
    
    public typealias BuildHandler = (builder: TableSchemeBuilder) -> Void
    public let schemeSets: [SchemeSet]
    
    #if DEBUG
    private var buildingBatchAnimations = false
    #endif
    
    public init(schemeSets: [SchemeSet]) {
        self.schemeSets = schemeSets
    }
    
    public convenience init(buildHandler: BuildHandler) {
        let builder = TableSchemeBuilder()
        buildHandler(builder: builder)
        self.init(schemeSets: builder.schemeSets)
    }
    
    // MARK: UITableViewDataSource methods
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return schemeSets.reduce(0) { $1.hidden ? $0 : $0 + 1 }
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let schemeSet = schemeSetForSection(section)
        
        return schemeSet.visibleSchemes.reduce(0) { (memo: Int, scheme: Scheme) in
            memo + scheme.numberOfCells
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let scheme = schemeAtIndexPath(indexPath)!
        let configurationIndex = indexPath.row - rowsBeforeScheme(scheme)
        let reuseIdentifier = scheme.reuseIdentifierForRelativeIndex(configurationIndex)
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier!, forIndexPath: indexPath) as UITableViewCell
        
        if let schemeCell = cell as? SchemeCell {
            schemeCell.scheme = scheme
        }
        
        scheme.configureCell(cell, withRelativeIndex: configurationIndex)
        
        return cell
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return schemeSetForSection(section).name
    }
    
    // MARK: Public Instance Methods
    /**
     *    This method handles selection for the table view. It's recommended that you use this
     *    method inside your UITableViewDelegate to handle selection. It will execute the appropriate
     *    selection handler associated to the cell scheme at that index.
     *
     *    @param tableView The table view being selected.
     *    @param indexPath The index path that was selected.
     */
    public func handleSelectionInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) {
        let scheme = schemeAtIndexPath(indexPath)!
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        let numberOfRowsBeforeScheme = rowsBeforeScheme(scheme)
        let newSelectedIndex = indexPath.row - numberOfRowsBeforeScheme
        scheme.selectCell(cell, inTableView: tableView, inSection: indexPath.section, havingRowsBeforeScheme: numberOfRowsBeforeScheme, withRelativeIndex: newSelectedIndex)
    }
    
    /**
     *    This method returns the height for the cell at indexPath.
     *
     *    It will ask the scheme for its height using heightForRelativeIndex(relativeIndex:)
     *
     *    @param tableView The table view asking for heights.
     *    @param indexPath The index path of the cell.
     *
     *    @return The height that the cell should be.
     */
    public func heightInTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> CGFloat {
        let scheme = schemeAtIndexPath(indexPath)!
        let relativeIndex = indexPath.row - rowsBeforeScheme(scheme)
        let rowHeight = scheme.heightForRelativeIndex(relativeIndex)
        
        switch rowHeight {
            case .UseTable:
                return tableView.rowHeight
            case .Custom(let h):
                return CGFloat(h)
        }
    }
    
    /**
     *    Returns a string containing the SchemeSet's footer text, if it exists.
     *
     *    @param tableView The table view asking for the view.
     *    @param indexPath The index path of the cell.
     *
     *    @return A strin containing the SchemeSet's footer text or nil
     */
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String! {
        return schemeSetForSection(section).footerText
    }
    
    /**
     *    This method returns the scheme at a given index path. Use this method
     *    in table view delegate methods to find the scheme the cell belongs to.
     *
     *    @param indexPath The index path that will be used to find the scheme
     *
     *    @return The scheme at the index path.
     */
    public func schemeAtIndexPath(indexPath: NSIndexPath) -> Scheme? {
        let schemeSet = schemeSetForSection(indexPath.section)
        let row = indexPath.row
        var offset = 0
        var priorHiddenSchemes = 0
        
        for (idx, scheme) in enumerate(schemeSet.schemes) {
            if (idx + offset > row) {
                break
            }
            
            if scheme.hidden {
                priorHiddenSchemes++
                continue
            }
            
            if row >= (idx + offset - priorHiddenSchemes) && row < (idx + offset + scheme.numberOfCells - priorHiddenSchemes) {
                return scheme
            } else {
                offset += scheme.numberOfCells - 1
            }
        }
        
        return schemeSet[row - offset + priorHiddenSchemes]
    }
    
    /**
     *      This method returns the scheme contained in a particular view. You would typically use
     *      this method when you have a UIControl sending an action for a view and you need to 
     *      determine the scheme that contains the control.
     *
     *      This view must be contained in the view hierarchey for the UITableView that this
     *      TableScheme is backing.
     *
     *      @param view The view that is contained in the view.
     *     
     *      @return The Scheme that contains the view, or nil if the view does not have a scheme.
     */
    public func schemeContainingView(view: UIView) -> Scheme? {
        if let cell = view.TSR_containingTableViewCell() {
            if let tableView = cell.TSR_containingTableView() {
                assert(tableView.dataSource === self)
                if let indexPath = tableView.indexPathForCell(cell) {
                    if let scheme = schemeAtIndexPath(indexPath) {
                        return scheme
                    }
                }
            }
        }
        
        return nil
    }
    
    /**
    *      This method returns the scheme contained in a particular view along with the offset within
    *      the scheme the chosen cell is at. Its similar to schemeContainingView(view:) -> Scheme?. 
    *
    *      You would typically use this method when you have a UIControl sending an action for a view
    *      that is part of a collection of cells within a scheme.
    *
    *      This view must be contained in the view hierarchey for the UITableView that this
    *      TableScheme is backing.
    *
    *      @param view The view that is contained in the view.
    *
    *      @return A tuple with the Scheme and Index of the cell within the scheme, or nil if 
    *              the view does not have a scheme.
    */
    public func schemeWithIndexContainingView(view: UIView) -> (scheme: Scheme, index: Int)? {
        if let cell = view.TSR_containingTableViewCell() {
            if let tableView = cell.TSR_containingTableView() {
                assert(tableView.dataSource === self)
                if let indexPath = tableView.indexPathForCell(cell) {
                    if let scheme = schemeAtIndexPath(indexPath) {
                        let numberOfRowsBeforeScheme = rowsBeforeScheme(scheme)
                        let offset = indexPath.row - numberOfRowsBeforeScheme
                        return (scheme: scheme, index: offset)
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: Scheme Visibility
    
    /**
        Hides a Scheme in the provided table view using the given animation.
    
        The passed in Scheme must belong to the TableScheme. 
    
        :param:     scheme          The scheme to hide.
        :param:     tableView       The UITableView to perform the animations on.
        :param:     rowAnimation    The type of animation that should be performed.
    */
    public func hideScheme(scheme: Scheme, inTableView tableView: UITableView, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif
        scheme.hidden = true
        tableView.deleteRowsAtIndexPaths(indexPathsForScheme(scheme), withRowAnimation: rowAnimation)
    }
    
    /**
        Shows a Scheme in the provided table view using the given animation.
        
        The passed in Scheme must belong to the TableScheme. 
    
        :param:     scheme          The scheme to show.
        :param:     tableView       The UITableView to perform the animations on.
        :param:     rowAnimation    The type of animation that should be performed.
    */
    public func showScheme(scheme: Scheme, inTableView tableView: UITableView, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif
        scheme.hidden = false
        tableView.insertRowsAtIndexPaths(indexPathsForScheme(scheme), withRowAnimation: rowAnimation)
    }
    
    /**
        Hides a SchemeSet in the provided table view using the given animation.
        
        The passed in SchemeSet must belong to the TableScheme. This method should not be used with batch updates. Instead, use
        `hideSchemeSet(_:, withRowAnimation:)`.
        
        :param:     schemeSet       The schemeSet to hide.
        :param:     tableView       The UITableView to perform the animations on.
        :param:     rowAnimation    The type of animation that should be performed.
    */
    public func hideSchemeSet(schemeSet: SchemeSet, inTableView tableView: UITableView, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif
        let section = sectionForSchemeSet(schemeSet)
        schemeSet.hidden = true
        tableView.deleteSections(NSIndexSet(index: section), withRowAnimation: rowAnimation)
    }
    
    /**
        Shows a SchemeSet in the provided table view using the given animation.
        
        The passed in SchemeSet must belong to the TableScheme.
        
        :param:     schemeSet       The schemeSet to show.
        :param:     tableView       The UITableView to perform the animations on.
        :param:     rowAnimation    The type of animation that should be performed.
    */
    public func showSchemeSet(schemeSet: SchemeSet, inTableView tableView: UITableView, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif
        let section = sectionForSchemeSet(schemeSet)
        schemeSet.hidden = false
        tableView.insertSections(NSIndexSet(index: section), withRowAnimation: rowAnimation)
    }
    
    /**
        Perform batch changes to the given table view using the operations performed on the animator passed in the 
        visibilityOperations closure.
    
        It's important that this method be used over explicitly calling beginUpdates()/endUpdates() and using the normal
        visibility operations. The normal visibility operations will update the data set immediately, while the batch-specific
        visibility operations (which are part of the passed in BatchAnimator class) will defer
        determining all the indexPaths until it is time to update the table view.
    
        :param:     tableView               The UITableView to perform the animations on.
        :param:     visibilityOperations    A closure containing the animation operations to be performed on the UITableView. A BatchAnimator
                                            will be passed into the closure, which is where your batch operations should occur.
    */
    public func batchSchemeVisibilityChangesInTableView(tableView: UITableView, visibilityOperations: (animator: TableSchemeBatchAnimator) -> Void) {
        let batchAnimator = TableSchemeBatchAnimator(tableScheme: self, withTableView: tableView)
        tableView.beginUpdates()
        
        #if DEBUG
        buildingBatchAnimations = true
        #endif
        
        visibilityOperations(animator: batchAnimator)
        
        #if DEBUG
        buildingBatchAnimations = false
        #endif
        
        batchAnimator.performVisibilityChanges()
        tableView.endUpdates()
    }
    
    /**
        This method will perform animations instructed in the changeHandler on the passed in SchemeRowAnimator. It allows you to have complete
        control over how changes in a scheme are animated. 
    
        Note this method does not make any changes to your scheme, and only provides you a way to make the changes to the table view based
        on the schemes relative index paths. For example, if you insert a row on the SchemeRowAnimator at index 0, and the scheme starts at
        row 2 in section 3, it will perform an insertion at row 2 in section 3. This allows you to think about how your scheme animates 
        internally, and ignore how schemes around it are laid out. It's recommended that you make the changes to your scheme within the
        changeHandler block as well to keep that code grouped together.
    
        :param:     scheme          The scheme that the changes are being applied to.
        :param:     tableView       The UITableView that the animations should be performed on.
        :param:     changeHandler   A closure with a SchemeRowAnimator that you give your animation instructions to.
    */
    public func animateChangesToScheme(scheme: Scheme, inTableView tableView: UITableView, withChangeHandler changeHandler: (animator: SchemeRowAnimator) -> Void) {
        let animator = SchemeRowAnimator(tableScheme: self, withScheme: scheme, inTableView: tableView)
        changeHandler(animator: animator)
        animator.performAnimations()
    }
    
    /**
        This method will infer changes done to a scheme that conforms to InferrableRowAnimatableScheme within the changeHandler, and 
        perform appropriate animations to the passed in tableView.
    
        You must make your changes to the scheme within the changeHandler, or the animation object will not be able to identify the difference
        between the object before and after the closure.
    
        The changes to your object must affect the rowIdentifiers property of the InferrableRowAnimatableScheme protocol. You
        should have one rowIdentifier for each row. 
    
        :param:     scheme          The scheme that the changes are being applied to.
        :param:     tableView       The UITableView that the animations should be performed on.
        :param:     changeHandler   A closure that you perform the changes to your scheme in.
    */
    public func animateChangesToScheme<T: Scheme where T: InferrableRowAnimatableScheme>(scheme: T, inTableView tableView: UITableView, withAnimation animation: UITableViewRowAnimation = .Automatic, withChangeHandler changeHandler: () -> Void) {
        let animator = InferringRowAnimator(tableScheme: self, withScheme: scheme, inTableView: tableView)
        changeHandler()
        animator.guessRowAnimationsWithAnimation(animation)
        animator.performAnimations()
    }
    
    // MARK: Private
    
    private func rowsBeforeScheme(scheme: Scheme) -> Int {
        let schemeSet = schemeSetWithScheme(scheme)
        
        var count = 0
        for scanScheme in schemeSet.schemes {
            if scanScheme === scheme {
                break
            }
            
            if scanScheme.hidden {
                continue
            }
            
            count += scanScheme.numberOfCells
        }
        
        return count
    }
    
    private func schemeSetForSection(section: Int) -> SchemeSet {
        var schemeSetIndex = section // Default to the passed in section
        var offset = 0
        for (index, schemeSet) in enumerate(schemeSets) {
            // Section indexes do not include our hidden scheme sets, so
            // when we pull one from our schemeSets array, which does include
            // the hidden scheme sets, we need to offset by our hidden schemes
            // before it.
            if schemeSet.hidden {
                offset++
                continue
            }
            
            // If our enumerated index minus our prior hidden scheme sets
            // equals the section that we're looking for, we found our
            // correct scheme set and can end the loop
            if index - offset == section {
                schemeSetIndex = index
                break
            }
        }
        
        return schemeSets[schemeSetIndex]
    }
    
    private func schemeSetWithScheme(scheme: Scheme) -> SchemeSet {
        var foundSet: SchemeSet?
        
        for schemeSet in schemeSets {
            for scanScheme in schemeSet.schemes {
                if scanScheme === scheme {
                    foundSet = schemeSet
                    break
                }
            }
        }
        
        assert(foundSet != nil)
        
        return foundSet!
    }
    
    private func indexPathsForScheme(scheme: Scheme) -> [NSIndexPath] {
        let rbs = rowsBeforeScheme(scheme)
        let schemeSet = schemeSetWithScheme(scheme)
        let section = sectionForSchemeSet(schemeSet)
        return map(rbs..<(rbs + scheme.numberOfCells)) { NSIndexPath(forRow: $0, inSection: section) }
    }
    
    private func sectionForSchemeSet(schemeSet: SchemeSet) -> Int {
        var i = 0
        
        for scanSchemeSet in schemeSets {
            if scanSchemeSet === schemeSet {
                return i
            } else {
                if !scanSchemeSet.hidden {
                    i++
                }
            }
        }
        
        return i
    }
}

/**
    This class is passed into the closure for performing batch animations to a TableScheme. It will record
    your changes to the TableScheme's SchemeSet and Scheme visibility, and then perform them all in one batch
    at the end of the TableScheme's batch operation method.
*/
public class TableSchemeBatchAnimator {
    private struct Row {
        let animation: UITableViewRowAnimation
        let scheme: Scheme
    }
    
    private struct Section {
        let animation: UITableViewRowAnimation
        let schemeSet: SchemeSet
    }
    
    private var rowInsertions = [Row]()
    private var rowDeletions = [Row]()
    private var sectionInsertions = [Section]()
    private var sectionDeletions = [Section]()
    
    private let tableScheme: TableScheme
    private let tableView: UITableView
    
    private init(tableScheme: TableScheme, withTableView tableView: UITableView) {
        self.tableScheme = tableScheme
        self.tableView = tableView
    }
    
    /**
        Shows a Scheme within a batch update using the given animation.
        
        The passed in Scheme must belong to the TableScheme.
        
        :param:     scheme          The scheme to show.
        :param:     rowAnimation    The type of animation that should be performed.
    */
    public func showScheme(scheme: Scheme, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        rowInsertions.append(Row(animation: rowAnimation, scheme: scheme))
    }
    
    /**
        Hides a Scheme within a batch update.
        
        The passed in Scheme must belong to the TableScheme.
        
        :param:     scheme          The scheme to hide.
        :param:     rowAnimation    The type of animation that should be performed.
    */
    public func hideScheme(scheme: Scheme, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        rowDeletions.append(Row(animation: rowAnimation, scheme: scheme))
    }
    
    /**
        Shows a SchemeSet within a batch update using the given animation.
        
        The passed in SchemeSet must belong to the TableScheme.
        
        :param:     schemeSet       The schemeSet to hide.
        :param:     rowAnimation    The type of animation that should be performed.
    */
    public func showSchemeSet(schemeSet: SchemeSet, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        sectionInsertions.append(Section(animation: rowAnimation, schemeSet: schemeSet))
    }
    
    /**
        Hides a SchemeSet within a batch update using the given animation.
        
        The passed in SchemeSet must belong to the TableScheme.
        
        :param:     schemeSet       The schemeSet to hide.
        :param:     rowAnimation    The type of animation that should be performed.
    */
    public func hideSchemeSet(schemeSet: SchemeSet, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        sectionDeletions.append(Section(animation: rowAnimation, schemeSet: schemeSet))
    }
    
    // MARK: Private methods
    private func performVisibilityChanges() {
        // Get the index paths of the schemes we are deleting. This will give us the deletion index paths. We need to do
        // this before marking them as hidden so indexPathForScheme doesn't skip it
        
        let deleteRows = rowDeletions.reduce([UITableViewRowAnimation: [NSIndexPath]]()) { (var memo, change) in
            if memo[change.animation] == nil {
                memo[change.animation] = [NSIndexPath]()
            }
            
            memo[change.animation]! += self.tableScheme.indexPathsForScheme(change.scheme)
            
            return memo
        }
        
        let deleteSections = sectionDeletions.reduce([UITableViewRowAnimation: NSMutableIndexSet]()) { (var memo, change) in
            if memo[change.animation] == nil {
                memo[change.animation] = NSMutableIndexSet() as NSMutableIndexSet
            }
            
            memo[change.animation]!.addIndex(self.tableScheme.sectionForSchemeSet(change.schemeSet))
            
            return memo
        }
        
        // Now update the visibility of all our batches
        
        for change in rowInsertions {
            change.scheme.hidden = false
        }
        
        for change in rowDeletions {
            change.scheme.hidden = true
        }
        
        for change in sectionDeletions {
            change.schemeSet.hidden = true
        }
        
        for change in sectionInsertions {
            change.schemeSet.hidden = false
        }
        
        // Now obtain the index paths for the inserted schemes. These will have their inserted index paths, skipping ones removed,
        // and correctly finding the ones that are visible
        
        let insertRows = rowInsertions.reduce([UITableViewRowAnimation: [NSIndexPath]]()) { (var memo, change) in
            if memo[change.animation] == nil {
                memo[change.animation] = [NSIndexPath]()
            }
            
            memo[change.animation]! += self.tableScheme.indexPathsForScheme(change.scheme)
            
            return memo
        }
        
        let insertSections = sectionInsertions.reduce([UITableViewRowAnimation: NSMutableIndexSet]()) { (var memo, change) in
            if memo[change.animation] == nil {
                memo[change.animation] = NSMutableIndexSet() as NSMutableIndexSet
            }
            
            memo[change.animation]!.addIndex(self.tableScheme.sectionForSchemeSet(change.schemeSet))
            
            return memo
        }
        
        // Now we have all the data we need to execute our animations. Perform them!
        
        for (animation, changes) in insertRows {
            tableView.insertRowsAtIndexPaths(changes, withRowAnimation: animation)
        }
        
        for (animation, changes) in deleteRows {
            tableView.deleteRowsAtIndexPaths(changes, withRowAnimation: animation)
        }
        
        for (animation, changes) in insertSections {
            tableView.insertSections(changes, withRowAnimation: animation)
        }
        
        for (animation, changes) in deleteSections {
            tableView.deleteSections(changes, withRowAnimation: animation)
        }
    }
}

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
    
    private let tableScheme: TableScheme
    private let tableView: UITableView
    public let scheme: Scheme
    
    private var moves = [Move]()
    private var insertions = [AddRemove]()
    private var deletions = [AddRemove]()
    
    private init(tableScheme: TableScheme, withScheme scheme: Scheme, inTableView tableView: UITableView) {
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
    public func moveObjectAtIndex(index: Int, toIndex: Int) {
        moves.append(Move(fromIndex: index, toIndex: toIndex))
    }
    
    /**
        Records the row to be removed from index using animation at the end of the batch closure.
        
        The indexes are relative to the scheme, and cells above or below this scheme
        should not be considered when making calls to this method.
    
        :param:     index       The index to remove.
        :param:     animation   The type of animation to perform.
    */
    public func deleteObjectAtIndex(index: Int, withAnimation animation: UITableViewRowAnimation = .Automatic) {
        deletions.append(AddRemove(animation: animation, index: index))
    }
    
    /**
        Records the row to be inserted to index using animation at the end of the batch closure.
        
        The indexes are relative to the scheme, and cells above or below this scheme
        should not be considered when making calls to this method.
        
        :param:     index       The index to insert.
        :param:     animation   The type of animation to perform.
    */
    public func insertObjectAtIndex(index: Int, withAnimation animation: UITableViewRowAnimation = .Automatic) {
        insertions.append(AddRemove(animation: animation, index: index))
    }
    
    /**
        Records a range of rows to be removed from indexes using animation at the end of the batch closure.
        
        The indexes are relative to the scheme, and cells above or below this scheme
        should not be considered when making calls to this method.
        
        :param:     indexes     The indexes to remove.
        :param:     animation   The type of animation to perform.
    */
    public func deleteObjectsAtIndexes(indexes: Range<Int>, withAnimation animation: UITableViewRowAnimation = .Automatic) {
        for i in indexes {
            deletions.append(AddRemove(animation: animation, index: i))
        }
    }
    
    /**
        Records a range of rows to be inserted to indexes using animation at the end of the batch closure.
        
        The indexes are relative to the scheme, and cells above or below this scheme
        should not be considered when making calls to this method.
        
        :param:     indexes     The indexes to insert.
        :param:     animation   The type of animation to perform.
    */
    public func insertObjectsAtIndexes(indexes: Range<Int>, withAnimation animation: UITableViewRowAnimation = .Automatic) {
        for i in indexes {
            insertions.append(AddRemove(animation: animation, index: i))
        }
    }
    
    private func performAnimations() {
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

private class InferringRowAnimator<T: Scheme where T: InferrableRowAnimatableScheme>: SchemeRowAnimator {
    private let originalRowIdentifiers: [T.IdentifierType]
    private var animatableScheme: T {
        return scheme as T
    }
    
    private init(tableScheme: TableScheme, withScheme scheme: T, inTableView tableView: UITableView) {
        originalRowIdentifiers = scheme.rowIdentifiers
        super.init(tableScheme: tableScheme, withScheme: scheme, inTableView: tableView)
    }
    
    private func guessRowAnimationsWithAnimation(animation: UITableViewRowAnimation) {
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
