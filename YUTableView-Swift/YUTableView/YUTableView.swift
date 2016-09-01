//
//  YUTableView.swift
//  YUTableView-Swift
//
//  Created by yücel uzun on 22/07/15.
//  Copyright © 2015 Yücel Uzun. All rights reserved.
//

import UIKit

public protocol YUTableViewDelegate {
    /**  Called inside "cellForRowAtIndexPath:" method. Edit your cell in this funciton. */
    func setContentsOfCell (cell: UITableViewCell, node: YUTableViewNode)
    /** Uses the returned value as cell height if implemented */
    func heightForIndexPath (indexPath: NSIndexPath) -> CGFloat?
    /** Uses the returned value as cell height if heightForIndexPath is not implemented */
    func heightForNode (node: YUTableViewNode) -> CGFloat?
    /** Called whenever a node is selected. You should check if it's a leaf. */
    func didSelectNode (node: YUTableViewNode, indexPath: NSIndexPath)
    /** Determines if swipe actions should be shown */
    func canEditNode (node: YUTableViewNode, indexPath: NSIndexPath) -> Bool
    /** Called when a node is removed with a swipe */
    func didRemoveNode (node: YUTableViewNode, indexPath: NSIndexPath)
    
}

extension YUTableViewDelegate {
    public func heightForNode (node: YUTableViewNode) -> CGFloat? { return nil }
    public func heightForIndexPath (indexPath: NSIndexPath) -> CGFloat? { return nil }
    public func didSelectNode (node: YUTableViewNode, indexPath: NSIndexPath) {}
    public func canEditNode (node: YUTableViewNode, indexPath: NSIndexPath) -> Bool { return false }
    public func didRemoveNode (node: YUTableViewNode, indexPath: NSIndexPath) {}
}

public class YUTableView: UITableView
{
    private var yuTableViewDelegate : YUTableViewDelegate!

    private var firstLevelNodes: [YUTableViewNode]!
    private var rootNode : YUTableViewNode! {
        willSet {
            if rootNode != nil {
                disableNodeAndChildNodes (rootNode)
            }
        }
    }
    private var nodesToDisplay: [YUTableViewNode]!
    
    /** If "YUTableViewNode"s don't have individual identifiers, this one is used */
    public var defaultCellIdentifier: String!

    public var insertRowAnimation: UITableViewRowAnimation = .Right
    public var deleteRowAnimation: UITableViewRowAnimation = .Left
    public var animationCompetitionHandler: () -> Void = {}
    /** Removes other open items before opening a new one */
    public var allowOnlyOneActiveNodeInSameLevel: Bool = false
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeDefaultValues ()
    }
    
    public required override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        initializeDefaultValues ()
    }
    
    private func initializeDefaultValues () {
        self.delegate = self
        self.dataSource = self
    }
    
    public func setDelegate (delegate: YUTableViewDelegate) {
        yuTableViewDelegate = delegate
    }
    
    public func setNodes (nodes: [YUTableViewNode]) {
        rootNode = YUTableViewNode(childNodes: nodes)
        self.firstLevelNodes = nodes
        self.nodesToDisplay = self.firstLevelNodes
        reloadData()
    }
    
    public func selectNodeAtIndex (index: Int) {
        let node = nodesToDisplay [index]
        openNodeAtIndexRow(index)
        yuTableViewDelegate?.didSelectNode(node, indexPath: NSIndexPath(forRow: index, inSection: 0))
    }
    
    public func selectNode (node: YUTableViewNode) {
        var index = nodesToDisplay.indexOf(node)
        if index == nil {
            selectNode(node.getParent()!)
            index = nodesToDisplay.indexOf(node)
        }
        openNodeAtIndexRow(index!)
        yuTableViewDelegate?.didSelectNode(node, indexPath: NSIndexPath(forRow: index!, inSection: 0))
    }
}

extension YUTableView: UITableViewDataSource {
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if nodesToDisplay != nil {
            return nodesToDisplay.count
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let node = nodesToDisplay[indexPath.row]
        let cellIdentifier = node.cellIdentifier != nil ? node.cellIdentifier : defaultCellIdentifier
        let cell = self.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        yuTableViewDelegate?.setContentsOfCell(cell, node: node)
        return cell
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let canEdit = yuTableViewDelegate?.canEditNode(nodesToDisplay[indexPath.row], indexPath: indexPath) {
            return canEdit;
        }
        return false;
    }
    
    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let node = nodesToDisplay[indexPath.row]
            removeNodeAtIndexPath (indexPath)
            yuTableViewDelegate?.didRemoveNode(node, indexPath: indexPath)
        } 
    }
    
}

extension YUTableView: UITableViewDelegate {
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let height = yuTableViewDelegate?.heightForIndexPath(indexPath)  {
            return height
        }
        if let height = yuTableViewDelegate?.heightForNode(nodesToDisplay[indexPath.row]) {
            return height
        }
        return tableView.rowHeight
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let node = nodesToDisplay [indexPath.row]
        yuTableViewDelegate.didSelectNode(node, indexPath: indexPath)
        if node.isActive {
            closeNodeAtIndexRow(indexPath.row)
        } else if node.hasChildren() {
            openNodeAtIndexRow(indexPath.row)
        }
    }
}

private extension YUTableView {

    func openNodeAtIndexRow (indexRow: Int) {
        var indexRow = indexRow
        let node = nodesToDisplay [indexRow]
        if allowOnlyOneActiveNodeInSameLevel {
            closeNodeAtSameLevelWithNode(node, indexRow: indexRow)
            indexRow = nodesToDisplay.indexOf(node)!
        }
        if let newNodes = node.childNodes {
            nodesToDisplay.insert(newNodes, atIndex: indexRow + 1)
            let indexesToInsert = indexesFromRow(indexRow + 1, count: newNodes.count)!
            updateTableRows(insertRows: indexesToInsert, removeRows: nil)
            node.isActive = true
        }
    }

    func closeNodeAtSameLevelWithNode (node: YUTableViewNode, indexRow: Int) {
        if let siblings = node.getParent()?.childNodes {
            if let activeNode = siblings.filter( { $0.isActive }).first {
                closeNodeAtIndexRow (nodesToDisplay.indexOf(activeNode)!)
            }
        }
    }
    
    func closeNodeAtIndexRow (indexRow: Int, shouldReloadClosedRow: Bool = false ) {
        let node = nodesToDisplay [indexRow]
        let numberOfDisplayedChildren = getNumberOfDisplayedChildrenAndDeactivateEveryNode(node)
        nodesToDisplay.removeRange(indexRow + 1...indexRow+numberOfDisplayedChildren )
        updateTableRows(removeRows: indexesFromRow(indexRow + 1, count: numberOfDisplayedChildren))
        node.isActive = false
        if shouldReloadClosedRow {
            self.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexRow, inSection: 0)], withRowAnimation: .Fade)
        }
    }
    
    func getNumberOfDisplayedChildrenAndDeactivateEveryNode (node: YUTableViewNode) -> Int {
        var count = 0
        if let children = node.childNodes {
            count += children.count
            for node in children.filter ({$0.isActive })  {
                count += getNumberOfDisplayedChildrenAndDeactivateEveryNode(node)
                node.isActive = false
            }
        }
        return count
    }
    
    func indexesFromRow (from: Int, count: Int) -> [NSIndexPath]? {
        var indexes = [NSIndexPath] ()
        for i in 0  ..< count {
            indexes.append(NSIndexPath(forRow: i + from, inSection: 0))
        }
        if (indexes.count == 0) { return nil }
        return indexes
    }

    func updateTableRows ( insertRows indexesToInsert: [NSIndexPath]? = nil, removeRows indexesToRemove: [NSIndexPath]? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.animationCompetitionHandler ()
        }
        self.beginUpdates()
        if indexesToRemove != nil && indexesToRemove?.count > 0 {
            self.deleteRowsAtIndexPaths(indexesToRemove!, withRowAnimation: self.deleteRowAnimation)
        }
        if indexesToInsert != nil && indexesToInsert?.count > 0 {
            self.insertRowsAtIndexPaths(indexesToInsert!, withRowAnimation: self.insertRowAnimation)
        }
        self.endUpdates()
        CATransaction.commit()
    }
    
    func removeNodeAtIndexPath (indexPath: NSIndexPath) {
        if nodesToDisplay[indexPath.row].isActive {
            closeNodeAtIndexRow(indexPath.row)
        }
        nodesToDisplay.removeAtIndex(indexPath.row)
        updateTableRows(removeRows: [indexPath])
    }
    
    func disableNodeAndChildNodes (node: YUTableViewNode) {
        node.isActive = false
        for child in node.childNodes ?? [YUTableViewNode]() {
            disableNodeAndChildNodes(child)
        }
    }
}

private extension Array {
    mutating func insert (items: [Element], atIndex: Int) {
        var counter = 0
        for item in items {
            insert(item, atIndex: atIndex + counter)
            counter += 1
        }
    }
    
    
}
