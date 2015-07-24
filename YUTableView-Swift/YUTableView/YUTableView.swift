//
//  YUTableView.swift
//  YUTableView-Swift
//
//  Created by yücel uzun on 22/07/15.
//  Copyright © 2015 Yücel Uzun. All rights reserved.
//

import UIKit

protocol YUTableViewDelegate {
    /**  Called inside "cellForRowAtIndexPath:" method. Edit your cell in this funciton. */
    func setContentsOfCell (cell: UITableViewCell, node: YUTableViewNode);
    /** Uses the returned value as cell height if implemented */
    func heightForIndexPath (indexPath: NSIndexPath) -> CGFloat!;
    /** Uses the returned value as cell height if heightForIndexPath is not implemented */
    func heightForNode (node: YUTableViewNode) -> CGFloat!;
    /** Called whenever a node is selected. You should check if it's a leaf. */
    func didSelectNode (node: YUTableViewNode, indexPath: NSIndexPath);
}

extension YUTableViewDelegate {
    func heightForNode (node: YUTableViewNode) -> CGFloat! { return nil; };
    func heightForIndexPath (indexPath: NSIndexPath) -> CGFloat! { return nil; };
    func didSelectNode (node: YUTableViewNode, indexPath: NSIndexPath) {}
}

class YUTableView: UITableView
{
    private var yuTableViewDelegate : YUTableViewDelegate!;

    private var firstLevelNodes: [YUTableViewNode]!;
    private var rootNode : YUTableViewNode!;
    private var nodesToDisplay: [YUTableViewNode]!;
    
    /** If "YUTableViewNode"s don't have individual identifiers, this one is used */
    var defaultCellIdentifier: String!;

    var insertRowAnimation: UITableViewRowAnimation = .Right;
    var deleteRowAnimation: UITableViewRowAnimation = .Left;
    var animationCompetitionHandler: () -> Void = {};
    /** Removes other open items before opening a new one */
    var allowOnlyOneActiveNodeInSameLevel: Bool = true;
    
    func setDelegate (delegate: YUTableViewDelegate) {
        yuTableViewDelegate = delegate;
    }
    
    func setNodes (nodes: [YUTableViewNode]) {
        rootNode = YUTableViewNode(subNodes: nodes);
        self.firstLevelNodes = nodes;
        self.nodesToDisplay = self.firstLevelNodes;
        reloadData();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        initializeDefaultValues ();
    }

    required override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style);
        initializeDefaultValues ();
    }
    
    private func initializeDefaultValues () {
        self.delegate = self;
        self.dataSource = self;
    }
}

extension YUTableView: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if nodesToDisplay != nil {
            return nodesToDisplay.count;
        }
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let node = nodesToDisplay[indexPath.row];
        let cellIdentifier = node.cellIdentifier != nil ? node.cellIdentifier : defaultCellIdentifier;
        let cell = self.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath);
        yuTableViewDelegate?.setContentsOfCell(cell, node: node);
        return cell;
    }
}

extension YUTableView: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let height = yuTableViewDelegate.heightForIndexPath(indexPath) {
            return height;
        }
        if let height = yuTableViewDelegate.heightForNode(nodesToDisplay[indexPath.row]) {
            return height;
        }
        return tableView.rowHeight;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let node = nodesToDisplay [indexPath.row];
        yuTableViewDelegate.didSelectNode(node, indexPath: indexPath);
        if node.isActive {
            closeNodeAtIndexRow(indexPath.row);
        } else if node.hasSubNodes() {
            openNodeAtIndexRow(indexPath.row);
        }
    }
}

private extension YUTableView {

    func openNodeAtIndexRow (var indexRow: Int) {
        let node = nodesToDisplay [indexRow];
        if allowOnlyOneActiveNodeInSameLevel {
            closeNodeAtSameLevelWithNode(node, indexRow: indexRow);
            indexRow = nodesToDisplay.indexOf(node)!;
        }
        if let newNodes = node.getSubNodes () {
            nodesToDisplay.insert(newNodes, atIndex: indexRow + 1);
            let indexesToInsert = indexesFromRow(indexRow + 1, count: newNodes.count)!;
            updateTableRows(insertRows: indexesToInsert, removeRows: nil);
            node.isActive = true;
        }
    }

    func closeNodeAtSameLevelWithNode (node: YUTableViewNode, indexRow: Int) {
        if let siblings = node.getParent()?.getSubNodes() {
            if let activeNode = siblings.filter( { $0.isActive }).first {
                closeNodeAtIndexRow (nodesToDisplay.indexOf(activeNode)!);
            }
        }
    }
    
    func closeNodeAtIndexRow (indexRow: Int ) {
        let node = nodesToDisplay [indexRow];
        let numberOfDisplayedSubnodes = getNumberOfDisplayedSubnodesAndDeactivateEveryNode(node);
        nodesToDisplay.removeRange(indexRow + 1...indexRow+numberOfDisplayedSubnodes );
        updateTableRows(removeRows: indexesFromRow(indexRow + 1, count: numberOfDisplayedSubnodes));
        node.isActive = false;
    }
    
    func getNumberOfDisplayedSubnodesAndDeactivateEveryNode (node: YUTableViewNode) -> Int {
        var count = 0;
        if let subNodes = node.getSubNodes() {
            count += subNodes.count;
            for node in subNodes.filter ({$0.isActive })  {
                count += getNumberOfDisplayedSubnodesAndDeactivateEveryNode(node);
                node.isActive = false;
            }
        }
        return count;
    }
    
    func indexesFromRow (from: Int, count: Int) -> [NSIndexPath]? {
        var indexes = [NSIndexPath] ();
        for var i = 0; i < count; i++ {
            indexes.append(NSIndexPath(forRow: i + from, inSection: 0));
        }
        if (indexes.count == 0) { return nil; }
        return indexes;
    }

    func updateTableRows ( insertRows indexesToInsert: [NSIndexPath]? = nil, removeRows indexesToRemove: [NSIndexPath]? = nil) {
        CATransaction.begin();
        CATransaction.setCompletionBlock { () -> Void in
            self.animationCompetitionHandler ();
        };
        self.beginUpdates();
        if indexesToRemove != nil && indexesToRemove?.count > 0 {
            self.deleteRowsAtIndexPaths(indexesToRemove!, withRowAnimation: self.deleteRowAnimation);
        }
        if indexesToInsert != nil && indexesToInsert?.count > 0 {
            self.insertRowsAtIndexPaths(indexesToInsert!, withRowAnimation: self.insertRowAnimation);
        }
        self.endUpdates();
        CATransaction.commit();
    }
    
}

private extension Array {
    mutating func insert (items: [Element], atIndex: Int) {
        var counter = 0;
        for item in items {
            insert(item, atIndex: atIndex + counter);
            counter++;
        }
    }
    
    
}