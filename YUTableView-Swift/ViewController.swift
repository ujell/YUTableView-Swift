//
//  ViewController.swift
//  YUTableView-Swift
//
//  Created by yücel uzun on 24/07/15.
//  Copyright © 2015 Yücel Uzun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: YUTableView!
    
    var closeOtherNodes: Bool!
    var insertRowAnimation: UITableViewRowAnimation!
    var deleteRowAnimation: UITableViewRowAnimation!
    
    var allNodes : [YUTableViewNode]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableProperties()
    }
    
    func setTableProperties () {
        allNodes = createNodes()
        tableView.setNodes(allNodes)
        tableView.setDelegate(self)
        tableView.allowOnlyOneActiveNodeInSameLevel = closeOtherNodes
        tableView.insertRowAnimation = insertRowAnimation
        tableView.deleteRowAnimation = deleteRowAnimation
        tableView.animationCompetitionHandler = {
            print("Animation ended")
        }
    }
    
    func setTableViewSettings (closeOtherNodes: Bool, insertAnimation: UITableViewRowAnimation, deleteAnimation: UITableViewRowAnimation) {
        self.closeOtherNodes = closeOtherNodes
        self.insertRowAnimation = insertAnimation
        self.deleteRowAnimation = deleteAnimation
    }
    
    func createNodes () -> [YUTableViewNode] {
        var nodes = [YUTableViewNode] ()
        for i in 1..<11 {
            var childNodes = [YUTableViewNode] ()
            for j in 1...5 {
                var grandChildNodes = [YUTableViewNode] ()
                for k in 1...3 {
                    let node = YUTableViewNode (data: "\(i).\(j).\(k)", cellIdentifier: "BasicCell")
                    grandChildNodes.append(node)
                }
                let node = YUTableViewNode(childNodes: grandChildNodes, data: ["img": "cat", "label": "\(i).\(j)"], cellIdentifier: "ComplexCell")
                childNodes.append(node)
            }
            let node = YUTableViewNode(childNodes: childNodes, data: "\(i)", cellIdentifier: "BasicCell")
            nodes.append (node)
        }
        return nodes
    }
    
    @IBAction func selectRandomNode() {
        var selectedNode = allNodes.first?.getParent()
        repeat {
            selectedNode = selectedNode!.childNodes[Int(arc4random_uniform(UInt32(selectedNode!.childNodes.count)))]
        } while arc4random_uniform(2) == 0 && selectedNode!.hasChildren()
        tableView.selectNode (selectedNode!)
    }
}

extension ViewController: YUTableViewDelegate {
    func setContentsOfCell(_ cell: UITableViewCell, node: YUTableViewNode) {
        if let customCell = cell as? CustomTableViewCell, let cellDic = node.data as? [String:String] {
            customCell.setLabel(cellDic["label"]!, andImage: cellDic["img"]!)
        } else {
            cell.textLabel!.text = node.data as? String
        }
    }
    func heightForNode(_ node: YUTableViewNode) -> CGFloat? {
        if node.cellIdentifier == "ComplexCell" {
            return 100.0
        }
        return nil
    }
    
    func didSelectNode(_ node: YUTableViewNode, indexPath: IndexPath) {
        if !node.hasChildren () {
            let alert = UIAlertView(title: "Row Selected", message: "Label: \(node.data as! String)", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
}
