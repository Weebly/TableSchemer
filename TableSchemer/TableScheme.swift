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
open class TableScheme: NSObject {
    
    public typealias BuildHandler = (_ builder: TableSchemeBuilder) -> Void
    open internal(set) var attributedSchemeSets: [AttributedSchemeSet]
    
    #if DEBUG
    private var buildingBatchAnimations = false
    #endif
    
    public convenience init(tableView: UITableView, schemeSets: [SchemeSet]) {
        self.init(tableView: tableView, attributedSchemeSets: schemeSets.map { AttributedSchemeSet(schemeSet: $0, hidden: false) })
    }

    public init(tableView: UITableView, attributedSchemeSets: [AttributedSchemeSet]) {
        self.attributedSchemeSets = attributedSchemeSets
        super.init()

        for attributedSchemeSet in attributedSchemeSets {
            for attributedScheme in attributedSchemeSet.schemeSet.attributedSchemes {
                guard let scheme = attributedScheme.scheme as? InferrableReuseIdentifierScheme else {
                    continue
                }

                for pair in scheme.reusePairs {
                    tableView.register(pair.cellType, forCellReuseIdentifier: pair.identifier)
                }
            }
        }

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    public convenience init(tableView: UITableView, buildHandler: BuildHandler) {
        let builder = TableSchemeBuilder()
        buildHandler(builder)
        self.init(tableView: tableView, attributedSchemeSets: builder.schemeSets)
    }
    
    // MARK: Public Instance Methods
    
    /**
     *    This method returns the scheme at a given index path. Use this method
     *    in table view delegate methods to find the scheme the cell belongs to.
     *
     *    @param indexPath The index path that will be used to find the scheme
     *
     *    @return The scheme at the index path.
     */
    public func schemeAtIndexPath(_ indexPath: IndexPath) -> Scheme? {
        guard let schemeSet = schemeSet(forSection: (indexPath as NSIndexPath).section) else { return nil }
        let row = (indexPath as NSIndexPath).row
        var offset = 0
        var priorHiddenSchemes = 0
        
        for (idx, attributedScheme) in schemeSet.attributedSchemes.enumerated() {
            if attributedScheme.hidden {
                priorHiddenSchemes += 1
                continue
            }

            if row >= (idx + offset - priorHiddenSchemes) && row < (idx + offset + attributedScheme.scheme.numberOfCells - priorHiddenSchemes) {
                return attributedScheme.scheme
            } else {
                offset += attributedScheme.scheme.numberOfCells - 1
            }
        }
        
        return nil
    }

    /**
     Returns the `SchemeSet` located at the given index. If one cannot be found, returns nil.
     
     - parameter    section: The section the `SchemeSet` is located at.
     - returns:     The `SchemeSet` at the given index, or nil if not found.
    */
    public func schemeSet(forSection section: Int) -> SchemeSet? {
        var schemeSetIndex: Int?
        var offset = 0
        for (index, schemeSet) in attributedSchemeSets.enumerated() {
            // Section indexes do not include our hidden scheme sets, so
            // when we pull one from our schemeSets array, which does include
            // the hidden scheme sets, we need to offset by our hidden schemes
            // before it.
            if schemeSet.hidden {
                offset += 1
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

        guard let index = schemeSetIndex else { return nil }

        return attributedSchemeSets[index].schemeSet
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
    public func scheme(containing view: UIView) -> Scheme? {
        if let cell = view.TSR_containingTableViewCell(),
            let tableView = cell.TSR_containingTableView(),
            let indexPath = tableView.indexPath(for: cell),
            let scheme = schemeAtIndexPath(indexPath) {
                return scheme
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
    public func schemeWithIndex(containing view: UIView) -> (scheme: Scheme, index: Int)? {
        if let cell = view.TSR_containingTableViewCell(),
            let tableView = cell.TSR_containingTableView(),
            let indexPath = tableView.indexPath(for: cell),
            let scheme = schemeAtIndexPath(indexPath) {
                let numberOfRowsBeforeScheme = rowsBeforeScheme(scheme)
                let offset = (indexPath as NSIndexPath).row - numberOfRowsBeforeScheme
                return (scheme: scheme, index: offset)
        }
        
        return nil
    }
    
    // MARK: Scheme Visibility

    /**
     Returns if the given `SchemeSet` is hidden. If the `SchemeSet` does not belong
     to the `TableScheme` this will return `nil`.
     
     - parameter    schemeSet:  The `SchemeSet` to check visibility for.
     - returns:     `true` if the `SchemeSet` is hidden, `false` if it is not, and `nil`
                    if the given `SchemeSet` does not belong to this `TableScheme`.
    */
    public func isSchemeSetHidden(_ schemeSet: SchemeSet) -> Bool? {
        guard let attributedSchemeSet = attributedSchemeSets.lazy.filter({ $0.schemeSet === schemeSet}).first else { return nil }
        return attributedSchemeSet.hidden
    }

    /**
     Returns if the given `Scheme` is hidden. If the `Scheme` does not belong
     to the `TableScheme` this will return `nil`.
     
     If the `Scheme` is not marked as hidden, but the containing `SchemeSet` is, this
     will return `false`.

     - parameter    scheme:  The `Scheme` to check visibility for.
     - returns:     `true` if the `Scheme` is hidden, `false` if it is not, and `nil`
     if the given `Scheme` does not belong to this `TableScheme`.
     */
    public func isSchemeHidden(_ scheme: Scheme) -> Bool? {
        for attributedSchemeSet in attributedSchemeSets {
            for attributedScheme in attributedSchemeSet.schemeSet.attributedSchemes {
                if attributedScheme.scheme === scheme {
                    return attributedScheme.hidden
                }
            }
        }

        return nil
    }
    
    /**
        Hides a Scheme in the provided table view using the given animation.
    
        The passed in Scheme must belong to the TableScheme. 
    
        - parameter     scheme:          The scheme to hide.
        - parameter     tableView:       The UITableView to perform the animations on.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func hideScheme(_ scheme: Scheme, in tableView: UITableView, with rowAnimation: UITableViewRowAnimation = .automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif

        guard let indexes = attributedSchemeIndexesWithScheme(scheme) else {
            NSLog("ERROR: Could not locate \(scheme) within \(self)")
            return
        }

        attributedSchemeSets[indexes.schemeSetIndex].schemeSet.attributedSchemes[indexes.schemeIndex].hidden = true
        tableView.deleteRows(at: indexPathsForScheme(scheme), with: rowAnimation)
    }
    
    /**
        Shows a Scheme in the provided table view using the given animation.
        
        The passed in Scheme must belong to the TableScheme. 
    
        - parameter     scheme:          The scheme to show.
        - parameter     tableView:       The UITableView to perform the animations on.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func showScheme(_ scheme: Scheme, in tableView: UITableView, with rowAnimation: UITableViewRowAnimation = .automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif

        guard let indexes = attributedSchemeIndexesWithScheme(scheme) else {
            NSLog("ERROR: Could not locate \(scheme) within \(self)")
            return
        }

        attributedSchemeSets[indexes.schemeSetIndex].schemeSet.attributedSchemes[indexes.schemeIndex].hidden = false
        tableView.insertRows(at: indexPathsForScheme(scheme), with: rowAnimation)
    }
    
    /**
        Reloads a Scheme in the provided table view using the given animation.
    
        The passed in Scheme must belong to the TableScheme.
    
        - parameter     scheme:          The scheme to reload the rows for.
        - parameter     tableView:       The UITableView to perform the animations on.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func reloadScheme(_ scheme: Scheme, in tableView: UITableView, with rowAnimation: UITableViewRowAnimation = .automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif

        guard let indexes = attributedSchemeIndexesWithScheme(scheme) else {
            NSLog("ERROR: Could not locate \(scheme) within \(self)")
            return
        }

        if !attributedSchemeSets[indexes.schemeSetIndex].schemeSet.attributedSchemes[indexes.schemeIndex].hidden {
            tableView.reloadRows(at: indexPathsForScheme(scheme), with: rowAnimation)
        }
    }
    
    /**
        Hides a SchemeSet in the provided table view using the given animation.
        
        The passed in SchemeSet must belong to the TableScheme. This method should not be used with batch updates. Instead, use
        `hideSchemeSet(_:, with:)`.
        
        - parameter     schemeSet:       The schemeSet to hide.
        - parameter     tableView:       The UITableView to perform the animations on.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func hideSchemeSet(_ schemeSet: SchemeSet, in tableView: UITableView, with rowAnimation: UITableViewRowAnimation = .automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif

        guard let index = attributedSchemeSets.index(where: { $0.schemeSet === schemeSet }) else {
            NSLog("ERROR: Could not locate \(schemeSet) within \(self)")
            return
        }

        let section = sectionForSchemeSet(schemeSet)
        attributedSchemeSets[index].hidden = true
        tableView.deleteSections(IndexSet(integer: section), with: rowAnimation)
    }
    
    /**
        Shows a SchemeSet in the provided table view using the given animation.
        
        The passed in SchemeSet must belong to the TableScheme.
        
        - parameter     schemeSet:       The schemeSet to show.
        - parameter     tableView:       The UITableView to perform the animations on.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func showSchemeSet(_ schemeSet: SchemeSet, in tableView: UITableView, with rowAnimation: UITableViewRowAnimation = .automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif

        guard let index = attributedSchemeSets.index(where: { $0.schemeSet === schemeSet }) else {
            NSLog("ERROR: Could not locate \(schemeSet) within \(self)")
            return
        }

        let section = sectionForSchemeSet(schemeSet)
        attributedSchemeSets[index].hidden = false
        tableView.insertSections(IndexSet(integer: section), with: rowAnimation)
    }
    
    /**
        Reloads a SchemeSet in the provided table view using the given animation.
        
        The passed in SchemeSet must belong to the TableScheme.
        
        - parameter     schemeSet:       The schemeSet to reload the rows for.
        - parameter     tableView:       The UITableView to perform the animations on.
        - parameter     rowAnimation:    The type of animation that should be performed.
    */
    public func reloadSchemeSet(_ schemeSet: SchemeSet, in tableView: UITableView, with rowAnimation: UITableViewRowAnimation = .automatic) {
        #if DEBUG
        assert(!buildingBatchAnimations, "You should not use this method within a batch update block")
        #endif

        guard let index = attributedSchemeSets.index(where: { $0.schemeSet === schemeSet }) else {
            NSLog("ERROR: Could not locate \(schemeSet) within \(self)")
            return
        }
        
        if !attributedSchemeSets[index].hidden {
            tableView.reloadSections(IndexSet(integer: sectionForSchemeSet(schemeSet)), with: rowAnimation)
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
    public func batchSchemeVisibilityChanges(in tableView: UITableView, visibilityOperations: (_ animator: TableSchemeBatchAnimator) -> Void) {
        let batchAnimator = TableSchemeBatchAnimator(tableScheme: self, withTableView: tableView)
        tableView.beginUpdates()
        
        #if DEBUG
        buildingBatchAnimations = true
        #endif
        
        visibilityOperations(batchAnimator)
        
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
    public func animateChangesToScheme(_ scheme: Scheme, inTableView tableView: UITableView, withChangeHandler changeHandler: (_ animator: SchemeRowAnimator) -> Void) {
        guard let indexes = attributedSchemeIndexesWithScheme(scheme) else {
            NSLog("ERROR: Could not locate \(scheme) within \(self)")
            return
        }
        
        let animator = SchemeRowAnimator(tableScheme: self, with: attributedSchemeSets[indexes.schemeSetIndex].schemeSet.attributedSchemes[indexes.schemeIndex], in: tableView)
        changeHandler(animator)
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
    public func animateChangesToScheme<T: Scheme>(_ scheme: T, inTableView tableView: UITableView, withAnimation animation: UITableViewRowAnimation = .automatic, withChangeHandler changeHandler: () -> Void) where T: InferrableRowAnimatableScheme {
        guard let indexes = attributedSchemeIndexesWithScheme(scheme) else {
            NSLog("ERROR: Could not locate \(scheme) within \(self)")
            return
        }

        let animator = InferringRowAnimator(tableScheme: self, with: scheme, ownedBy: attributedSchemeSets[indexes.schemeSetIndex].schemeSet.attributedSchemes[indexes.schemeIndex], in: tableView)
        assert(scheme.rowIdentifiers.count == scheme.numberOfCells, "The schemes number of row identifiers must equal its number of cells before the changes")
        changeHandler()
        assert(scheme.rowIdentifiers.count == scheme.numberOfCells, "The schemes number of row identifiers must equal its number of cells after the changes")
        animator.guessRowAnimations(with: animation)
        animator.performAnimations()
    }

    /**
     Locates the index for a given `SchemeSet`.
     
     -  parameter   schemeSet:  The `SchemeSet` to locate the index for
     -  returns:                The index of the scheme set, or nil if it doesn't exist
    */
    public func attributedSchemeSetIndexForSchemeSet(_ schemeSet: SchemeSet) -> Array<AttributedSchemeSet>.Index? {
        return attributedSchemeSets.index(where: { $0.schemeSet === schemeSet })
    }

    /**
     Locates the indexes for a given `Scheme`.

     -  parameter   scheme:     The `Scheme` to locate the indexes for
     -  returns:                The index of the scheme and scheme set, or nil if it doesn't exist
     */
    public func attributedSchemeIndexesWithScheme(_ scheme: Scheme) -> (schemeSetIndex: Array<AttributedSchemeSet>.Index, schemeIndex: Array<AttributedScheme>.Index)? {
        for (attributedSchemeSetIndex, attributedSchemeSet) in attributedSchemeSets.enumerated() {
            for (attributedSchemeIndex, attributedScheme) in attributedSchemeSet.schemeSet.attributedSchemes.enumerated() {
                if attributedScheme.scheme === scheme {
                    return (schemeSetIndex: attributedSchemeSetIndex, schemeIndex: attributedSchemeIndex)
                }
            }
        }

        return nil
    }

    
    // MARK: - Internal methods
    
    func indexPathsForScheme(_ scheme: Scheme) -> [IndexPath] {
        let rbs = rowsBeforeScheme(scheme)
        let schemeSet = schemeSetWithScheme(scheme)
        let section = sectionForSchemeSet(schemeSet)
        return (rbs..<(rbs + scheme.numberOfCells)).map { IndexPath(row: $0, section: section) }
    }
    
    func sectionForSchemeSet(_ schemeSet: SchemeSet) -> Int {
        var i = 0
        
        for scanSchemeSet in attributedSchemeSets {
            if scanSchemeSet.schemeSet === schemeSet {
                return i
            } else {
                if !scanSchemeSet.hidden {
                    i += 1
                }
            }
        }
        
        return i
    }
    
    
    func rowsBeforeScheme(_ scheme: Scheme) -> Int {
        let schemeSet = schemeSetWithScheme(scheme)
        
        var count = 0
        for scanAttributedSchemeObject in schemeSet.attributedSchemes {
            if scanAttributedSchemeObject.scheme === scheme {
                break
            }
            
            if scanAttributedSchemeObject.hidden {
                continue
            }
            
            count += scanAttributedSchemeObject.scheme.numberOfCells
        }
        
        return count
    }
    
    func schemeSetWithScheme(_ scheme: Scheme) -> SchemeSet {
        var foundSet: AttributedSchemeSet?
        
        for schemeSet in attributedSchemeSets {
            for scanScheme in schemeSet.schemeSet.schemes {
                if scanScheme === scheme {
                    foundSet = schemeSet
                    break
                }
            }
        }
        
        assert(foundSet != nil)
        
        return foundSet!.schemeSet
    }

}

// MARK: UITableViewDataSource methods
extension TableScheme: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return attributedSchemeSets.reduce(0) { $1.hidden ? $0 : $0 + 1 }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let set = schemeSet(forSection: section)!

        return set.visibleSchemes.reduce(0) { (memo: Int, scheme: Scheme) in
            memo + scheme.numberOfCells
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let scheme = schemeAtIndexPath(indexPath)!
        let configurationIndex = (indexPath as NSIndexPath).row - rowsBeforeScheme(scheme)
        let cell = scheme.tableView(tableView, cellForRowAt: indexPath, relativeIndex: configurationIndex)

        (cell as? SchemeCell)?.scheme = scheme

        scheme.configureCell(cell, withRelativeIndex: configurationIndex)

        return cell
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return schemeSet(forSection: section)?.headerText
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return schemeSet(forSection: section)?.footerText
    }

}

extension TableScheme: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let scheme = schemeAtIndexPath(indexPath), let cell = tableView.cellForRow(at: indexPath) else { return }

        let numberOfRowsBeforeScheme = rowsBeforeScheme(scheme)
        let newSelectedIndex = (indexPath as NSIndexPath).row - numberOfRowsBeforeScheme
        scheme.selectCell(cell, inTableView: tableView, inSection: (indexPath as NSIndexPath).section, havingRowsBeforeScheme: numberOfRowsBeforeScheme, withRelativeIndex: newSelectedIndex)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let scheme = schemeAtIndexPath(indexPath)!
        let relativeIndex = (indexPath as NSIndexPath).row - rowsBeforeScheme(scheme)
        let rowHeight = scheme.height(forRelativeIndex: relativeIndex)

        switch rowHeight {
        case .useTable:
            return tableView.rowHeight
        case .custom(let h):
            return CGFloat(h)
        }
    }

}
