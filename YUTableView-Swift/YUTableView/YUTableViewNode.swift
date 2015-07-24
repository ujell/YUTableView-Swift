//
//  YUTableViewNode.swift
//  YUTableView-Swift
//
//  Created by yücel uzun on 16/07/15.
//  Copyright © 2015 Yücel Uzun. All rights reserved.
//

func ==(lhs: YUTableViewNode, rhs: YUTableViewNode) -> Bool {
    return lhs.nodeId == rhs.nodeId;
}

class YUTableViewNode: Equatable {
    private static var nextId: Int = 0;
    private var subNodes: [YUTableViewNode]!;
    private var parent: YUTableViewNode!;
    private var nodeId: Int;
    
    /** Use this to set your custom data for the node. Like label names */
    var data: AnyObject!;
    /** Cell identifier of this node.
    - Warning: If you're using custom ".xib" file for your cell, you should register it before using it
    */
    var cellIdentifier: String!; // Don't forget register nib
    /** Is subitems are displayed. YUTableView uses this and you probably don't need it. */
    var isActive: Bool = false;
    
    init (subNodes: [YUTableViewNode]? = nil, data: AnyObject? = nil, cellIdentifier: String = "") {
        nodeId = YUTableViewNode.nextId++;
        self.setSubNodes(subNodes);
        self.data = data;
        self.cellIdentifier = cellIdentifier == "" ? nil : cellIdentifier;
    }
    
    private func setSubNodes (nodes: [YUTableViewNode]?) {
        self.subNodes = nodes;
        if self.subNodes != nil {
            for node in self.subNodes {
                node.parent = self;
            }
        }
    }
    
    func getParent () -> YUTableViewNode? {
        return parent;
    }
    
    func hasSubNodes () -> Bool {
        return subNodes != nil && subNodes.count != 0
    }
    
    func getSubNodes () -> [YUTableViewNode]? {
        return subNodes;
    }
    
}