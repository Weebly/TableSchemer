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
    
    public convenience init(@noescape buildHandler: BuildHandler) {
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
        let cell = scheme.tableView(tableView, cellForRowAtIndexPath: indexPath, relativeIndex: configurationIndex)

        (cell as? SchemeCell)?.scheme = scheme
        
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
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
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
        
        for (idx, schemeItem) in schemeSet.schemeItems.enumerate() {
            if schemeItem.hidden {
                priorHiddenSchemes++
                continue
            }

            if row >= (idx + offset - priorHiddenSchemes) && row < (idx + offset + schemeItem.scheme.numberOfCells - priorHiddenSchemes) {
                return schemeItem.scheme
            } else {
                offset += schemeItem.scheme.numberOfCells - 1
            }
        }
        
        return nil
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
    
        - parameter     scheme:          The scheme to hide.
        - parameter     tableView:       The UITableView to perform the animations on.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func hideScheme(scheme: Scheme, inTableView tableView: UITableView, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif
        schemeItemWithScheme(scheme).hidden = true
        tableView.deleteRowsAtIndexPaths(indexPathsForScheme(scheme), withRowAnimation: rowAnimation)
    }
    
    /**
        Shows a Scheme in the provided table view using the given animation.
        
        The passed in Scheme must belong to the TableScheme. 
    
        - parameter     scheme:          The scheme to show.
        - parameter     tableView:       The UITableView to perform the animations on.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func showScheme(scheme: Scheme, inTableView tableView: UITableView, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif
        schemeItemWithScheme(scheme).hidden = false
        tableView.insertRowsAtIndexPaths(indexPathsForScheme(scheme), withRowAnimation: rowAnimation)
    }
    
    /**
        Reloads a Scheme in the provided table view using the given animation.
    
        The passed in Scheme must belong to the TableScheme.
    
        - parameter     scheme:          The scheme to reload the rows for.
        - parameter     tableView:       The UITableView to perform the animations on.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func reloadScheme(scheme: Scheme, inTableView tableView: UITableView, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif
        
        if !schemeItemWithScheme(scheme).hidden {
            tableView.reloadRowsAtIndexPaths(indexPathsForScheme(scheme), withRowAnimation: rowAnimation)
        }
    }
    
    /**
        Hides a SchemeSet in the provided table view using the given animation.
        
        The passed in SchemeSet must belong to the TableScheme. This method should not be used with batch updates. Instead, use
        `hideSchemeSet(_:, withRowAnimation:)`.
        
        - parameter     schemeSet:       The schemeSet to hide.
        - parameter     tableView:       The UITableView to perform the animations on.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func hideSchemeSet(schemeSet: SchemeSet, inTableView tableView: UITableView, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif
        let section = sectionForSchemeSet(schemeSet)
        schemeSet._hidden = true
        tableView.deleteSections(NSIndexSet(index: section), withRowAnimation: rowAnimation)
    }
    
    /**
        Shows a SchemeSet in the provided table view using the given animation.
        
        The passed in SchemeSet must belong to the TableScheme.
        
        - parameter     schemeSet:       The schemeSet to show.
        - parameter     tableView:       The UITableView to perform the animations on.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func showSchemeSet(schemeSet: SchemeSet, inTableView tableView: UITableView, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif
        let section = sectionForSchemeSet(schemeSet)
        schemeSet._hidden = false
        tableView.insertSections(NSIndexSet(index: section), withRowAnimation: rowAnimation)
    }
    
    /**
        Reloads a SchemeSet in the provided table view using the given animation.
        
        The passed in SchemeSet must belong to the TableScheme.
        
        - parameter     schemeSet:       The schemeSet to reload the rows for.
        - parameter     tableView:       The UITableView to perform the animations on.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func reloadSchemeSet(schemeSet: SchemeSet, inTableView tableView: UITableView, withRowAnimation rowAnimation: UITableViewRowAnimation = .Automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif
        
        if !schemeSet.hidden {
            tableView.reloadSections(NSIndexSet(index: sectionForSchemeSet(schemeSet)), withRowAnimation: rowAnimation)
        }
    }

    
    /**
        Perform batch changes to the given table view using the operations performed on the animator passed in the
        visibilityOperations closure.
    
        It's important that this method be used over explicitly calling beginUpdates()/endUpdates() and using the normal
        visibility operations. The normal visibility operations will update the data set immediately, while the batch-specific
        visibility operations (which are part of the passed in BatchAnimator class) will defer
        determining all the indexPaths until it is time to update the table view.
    
        - parameter     tableView:               The UITableView to perform the animations on.
        - parameter     visibilityOperations:    A closure containing the animation operations to be performed on the UITableView. A BatchAnimator
                                            will be passed into the closure, which is where your batch operations should occur.
    */
    public func batchSchemeVisibilityChangesInTableView(tableView: UITableView, @noescape visibilityOperations: (animator: TableSchemeBatchAnimator) -> Void) {
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
    
        - parameter     scheme:          The scheme that the changes are being applied to.
        - parameter     tableView:       The UITableView that the animations should be performed on.
        - parameter     changeHandler:   A closure with a SchemeRowAnimator that you give your animation instructions to.
    */
    public func animateChangesToScheme(scheme: Scheme, inTableView tableView: UITableView, @noescape withChangeHandler changeHandler: (animator: SchemeRowAnimator) -> Void) {
        let animator = SchemeRowAnimator(tableScheme: self, withSchemeItem: schemeItemWithScheme(scheme), inTableView: tableView)
        changeHandler(animator: animator)
        animator.performAnimations()
    }
    
    /**
        This method will infer changes done to a scheme that conforms to InferrableRowAnimatableScheme within the changeHandler, and 
        perform appropriate animations to the passed in tableView.
    
        You must make your changes to the scheme within the changeHandler, or the animation object will not be able to identify the difference
        between the object before and after the closure.
    
        The changes to your object must affect the rowIdentifiers property of the InferrableRowAnimatableScheme protocol. You
        must have one rowIdentifier for each row.
    
        - parameter     scheme:          The scheme that the changes are being applied to.
        - parameter     tableView:       The UITableView that the animations should be performed on.
        - parameter     changeHandler:   A closure that you perform the changes to your scheme in.
    */
    public func animateChangesToScheme<T: Scheme where T: InferrableRowAnimatableScheme>(scheme: T, inTableView tableView: UITableView, withAnimation animation: UITableViewRowAnimation = .Automatic, @noescape withChangeHandler changeHandler: () -> Void) {
        let animator = InferringRowAnimator(tableScheme: self, withScheme: scheme, ownedBySchemeItem: schemeItemWithScheme(scheme), inTableView: tableView)
        assert(scheme.rowIdentifiers.count == scheme.numberOfCells, "The schemes number of row identifiers must equal its number of cells before the changes")
        changeHandler()
        assert(scheme.rowIdentifiers.count == scheme.numberOfCells, "The schemes number of row identifiers must equal its number of cells after the changes")
        animator.guessRowAnimationsWithAnimation(animation)
        animator.performAnimations()
    }
    
    // MARK: - Internal methods
    
    func indexPathsForScheme(scheme: Scheme) -> [NSIndexPath] {
        let rbs = rowsBeforeScheme(scheme)
        let schemeSet = schemeSetWithScheme(scheme)
        let section = sectionForSchemeSet(schemeSet)
        return (rbs..<(rbs + scheme.numberOfCells)).map { NSIndexPath(forRow: $0, inSection: section) }
    }
    
    func sectionForSchemeSet(schemeSet: SchemeSet) -> Int {
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
    
    
    func rowsBeforeScheme(scheme: Scheme) -> Int {
        let schemeSet = schemeSetWithScheme(scheme)
        
        var count = 0
        for scanSchemeItem in schemeSet.schemeItems {
            if scanSchemeItem.scheme === scheme {
                break
            }
            
            if scanSchemeItem.hidden {
                continue
            }
            
            count += scanSchemeItem.scheme.numberOfCells
        }
        
        return count
    }
    
    func schemeSetWithScheme(scheme: Scheme) -> SchemeSet {
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

    func schemeItemWithScheme(scheme: Scheme) -> SchemeItem {
        var foundItem: SchemeItem?

        for schemeSet in schemeSets {
            for scanSchemeItem in schemeSet.schemeItems {
                if scanSchemeItem.scheme === scheme {
                    foundItem = scanSchemeItem
                    break
                }
            }
        }

        assert(foundItem != nil)

        return foundItem!
    }
    
    // MARK: - Private methods
    
    private func schemeSetForSection(section: Int) -> SchemeSet {
        var schemeSetIndex = section // Default to the passed in section
        var offset = 0
        for (index, schemeSet) in schemeSets.enumerate() {
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
}
