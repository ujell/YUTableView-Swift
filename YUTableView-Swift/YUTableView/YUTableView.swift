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
    func setContentsOfCell (_ cell: UITableViewCell, node: YUTableViewNode)
    /** Uses the returned value as cell height if implemented */
    func heightForIndexPath (_ indexPath: IndexPath) -> CGFloat?
    /** Uses the returned value as cell height if heightForIndexPath is not implemented */
    func heightForNode (_ node: YUTableViewNode) -> CGFloat?
    /** Called whenever a node is selected. You should check if it's a leaf. */
    func didSelectNode (_ node: YUTableViewNode, indexPath: IndexPath)
    /** Determines if swipe actions should be shown */
    func canEditNode (_ node: YUTableViewNode, indexPath: IndexPath) -> Bool
    /** Called when a node is removed with a swipe */
    func didRemoveNode (_ node: YUTableViewNode, indexPath: IndexPath)
    
}

extension YUTableViewDelegate {
    public func heightForNode (_ node: YUTableViewNode) -> CGFloat? { return nil }
    public func heightForIndexPath (_ indexPath: IndexPath) -> CGFloat? { return nil }
    public func didSelectNode (_ node: YUTableViewNode, indexPath: IndexPath) {}
    public func canEditNode (_ node: YUTableViewNode, indexPath: IndexPath) -> Bool { return false }
    public func didRemoveNode (_ node: YUTableViewNode, indexPath: IndexPath) {}
}

public class YUTableView: UITableView
{
    fileprivate var yuTableViewDelegate : YUTableViewDelegate!

    fileprivate var firstLevelNodes: [YUTableViewNode]!
    fileprivate var rootNode : YUTableViewNode! {
        willSet {
            if rootNode != nil {
                disableNodeAndChildNodes(rootNode)
            }
        }
    }
    fileprivate var nodesToDisplay: [YUTableViewNode]!
    
    /** If "YUTableViewNode"s don't have individual identifiers, this one is used */
    public var defaultCellIdentifier: String!

    public var insertRowAnimation: UITableViewRowAnimation = .right
    public var deleteRowAnimation: UITableViewRowAnimation = .left
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
    
    public func setDelegate (_ delegate: YUTableViewDelegate) {
        yuTableViewDelegate = delegate
    }
    
    public func setNodes (_ nodes: [YUTableViewNode]) {
        rootNode = YUTableViewNode(childNodes: nodes)
        self.firstLevelNodes = nodes
        self.nodesToDisplay = self.firstLevelNodes
        reloadData()
    }
    
    public func selectNodeAtIndex (_ index: Int) {
        let node = nodesToDisplay [index]
        openNodeAtIndexRow(index)
        yuTableViewDelegate?.didSelectNode(node, indexPath: IndexPath(row: index, section: 0))
    }
    
    public func selectNode (_ node: YUTableViewNode) {
        var index = nodesToDisplay.index(of: node)
        if index == nil {
            selectNode(node.getParent()!)
            index = nodesToDisplay.index(of: node)
        }
        openNodeAtIndexRow(index!)
        yuTableViewDelegate?.didSelectNode(node, indexPath: IndexPath(row: index!, section: 0))
    }
    
    public func closeAllNodes () {
        for subNode in nodesToDisplay {
            closeNode (subNode);
        }
    }
    
    public func closeNode (_ node: YUTableViewNode) {
        if let index = nodesToDisplay.index(of: node) {
            closeNodeAtIndexRow(index)
        }
    }
}

extension YUTableView: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if nodesToDisplay != nil {
            return nodesToDisplay.count
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = nodesToDisplay[(indexPath as NSIndexPath).row]
        let cellIdentifier = node.cellIdentifier != nil ? node.cellIdentifier : defaultCellIdentifier
        let cell = self.dequeueReusableCell(withIdentifier: cellIdentifier!, for: indexPath)
        yuTableViewDelegate?.setContentsOfCell(cell, node: node)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let canEdit = yuTableViewDelegate?.canEditNode(nodesToDisplay[(indexPath as NSIndexPath).row], indexPath: indexPath) {
            return canEdit;
        }
        return false;
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let node = nodesToDisplay[(indexPath as NSIndexPath).row]
            removeNodeAtIndexPath (indexPath)
            yuTableViewDelegate?.didRemoveNode(node, indexPath: indexPath)
        } 
    }
    
}

extension YUTableView: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = yuTableViewDelegate?.heightForIndexPath(indexPath)  {
            return height
        }
        if let height = yuTableViewDelegate?.heightForNode(nodesToDisplay[(indexPath as NSIndexPath).row]) {
            return height
        }
        return tableView.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let node = nodesToDisplay [(indexPath as NSIndexPath).row]
        yuTableViewDelegate.didSelectNode(node, indexPath: indexPath)
        if node.isActive {
            closeNodeAtIndexRow((indexPath as NSIndexPath).row)
        } else if node.hasChildren() {
            openNodeAtIndexRow((indexPath as NSIndexPath).row)
        }
    }
}

private extension YUTableView {

    func openNodeAtIndexRow (_ indexRow: Int) {
        var indexRow = indexRow
        let node = nodesToDisplay [indexRow]
        if allowOnlyOneActiveNodeInSameLevel {
            closeNodeAtSameLevelWithNode(node, indexRow: indexRow)
            indexRow = nodesToDisplay.index(of: node)!
        }
        if let newNodes = node.childNodes {
            nodesToDisplay.insert(newNodes, atIndex: indexRow + 1)
            let indexesToInsert = indexesFromRow(indexRow + 1, count: newNodes.count)!
            updateTableRows(insertRows: indexesToInsert, removeRows: nil)
            node.isActive = true
        }
    }

    func closeNodeAtSameLevelWithNode (_ node: YUTableViewNode, indexRow: Int) {
        if let siblings = node.getParent()?.childNodes {
            if let activeNode = siblings.filter( { $0.isActive }).first {
                closeNodeAtIndexRow (nodesToDisplay.index(of: activeNode)!)
            }
        }
    }
    
    func closeNodeAtIndexRow (_ indexRow: Int, shouldReloadClosedRow: Bool = false ) {
        let node = nodesToDisplay [indexRow]
        let numberOfDisplayedChildren = getNumberOfDisplayedChildrenAndDeactivateEveryNode(node)
        if (indexRow + 1 > indexRow+numberOfDisplayedChildren) { return }
        nodesToDisplay.removeSubrange(indexRow + 1...indexRow+numberOfDisplayedChildren )
        updateTableRows(removeRows: indexesFromRow(indexRow + 1, count: numberOfDisplayedChildren))
        if shouldReloadClosedRow {
            self.reloadRows(at: [IndexPath(row: indexRow, section: 0)], with: .fade)
        }
    }
    
    func getNumberOfDisplayedChildrenAndDeactivateEveryNode (_ node: YUTableViewNode) -> Int {
        if !node.isActive { return 0 }
        var count = 0
        node.isActive = false;
        if let children = node.childNodes {
            count += children.count
            for child in children.filter ({$0.isActive })  {
                count += getNumberOfDisplayedChildrenAndDeactivateEveryNode(child)
            }
        }
        return count
    }
    
    func indexesFromRow (_ from: Int, count: Int) -> [IndexPath]? {
        var indexes = [IndexPath] ()
        for i in 0  ..< count {
            indexes.append(IndexPath(row: i + from, section: 0))
        }
        if (indexes.count == 0) { return nil }
        return indexes
    }

    func updateTableRows ( insertRows indexesToInsert: [IndexPath]? = nil, removeRows indexesToRemove: [IndexPath]? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.animationCompetitionHandler ()
        }
        self.beginUpdates()
        if indexesToRemove != nil && indexesToRemove!.count > 0 {
            self.deleteRows(at: indexesToRemove!, with: self.deleteRowAnimation)
        }
        if indexesToInsert != nil && indexesToInsert!.count > 0 {
            self.insertRows(at: indexesToInsert!, with: self.insertRowAnimation)
        }
        self.endUpdates()
        CATransaction.commit()
    }
    
    func removeNodeAtIndexPath (_ indexPath: IndexPath) {
        if nodesToDisplay[(indexPath as NSIndexPath).row].isActive {
            closeNodeAtIndexRow((indexPath as NSIndexPath).row)
        }
        nodesToDisplay.remove(at: (indexPath as NSIndexPath).row)
        updateTableRows(removeRows: [indexPath])
    }
    
    func disableNodeAndChildNodes (_ node: YUTableViewNode) {
        node.isActive = false
        for child in node.childNodes ?? [YUTableViewNode]() {
            disableNodeAndChildNodes(child)
        }
    }
}

private extension Array {
    mutating func insert (_ items: [Element], atIndex: Int) {
        var counter = 0
        for item in items {
            insert(item, at: atIndex + counter)
            counter += 1
        }
    }
    
    
}
