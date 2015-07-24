YUTableView adds expandable sub-menu support to UITableView.

#Installation
You can directly drag&drop **YUTableView** folder from demo to your project.

#Requirements
* Swift 2
* Doesn't compatible with Objective-C. For Objective-C check [this](https://github.com/ujell/YUTableView) version. 

#Usage
##Data Model
You must create a YUTableViewNode for all of your rows.

###Properties
* ```data```: This is where you store the custom data of the cell.
* ```cellIdentifier```: The identifier of the cell. If you don't set cellIdentifier, default identifier (which is a property of **YUTableView**) will be used.

###How to init
```Swift
// Initializing node with data.
let node = YUTableViewNode (data: "Label")
// Initializing node with data and cell identifier.
let node2 = YUTableViewNode (data: "Label", cellIdentifier: "Cell")
// Initializing node with children and data
YUTableViewNode (childNodes: [node, node2], data: "Parent")
```

##Table
##Usage of YUTableView
###Being notified when user selected cell
Your view controller should implement "YUTableViewDelegate" and you should call "setDelegate" method to set your delegate.
```Swift
func setTableProperties () {
    tableView.setDelegate(self);
    // Other stuf...
}

func didSelectNode(node: YUTableViewNode, indexPath: NSIndexPath) {
  // Do something with node or indexPath...
}
 ```

###Different cell heights
"YUTableViewDelegate" has "heightForIndexPath:" and "heightForNode:" methods to provide different cell heights.
```Swift
func heightForNode(node: YUTableViewNode) -> CGFloat? {
    if node.cellIdentifier == "ComplexCell" {
        return 100.0;
    }
    return nil;
}
func heightForIndexPath (indexPath: NSIndexPath) -> CGFloat? {
    if indexPath.row == 5 {
        return 100.0;
    }
    return nil;
}
```

YUTableView first checks "heightForNode:", if it returns nil (or didn't implemented) then checks "heightForIndexPath:". If both of them return nil (or didn't implemented) it just uses default row height.

####Setting animation type
```Swift
let tableView : YUTableView
//...
// Changes the animation of inserting cells.
tableView.insertRowAnimation = .Top;
// Changes the animation of deleting cells.
tableView.deleteRowAnimation = .Fade;
```

###Selecting Rows Programatically 
To select a row one of the "selectNodeAtIndex:"  or "selectNode:" methods can be used. 
```Swift
let tableView : YUTableView
//...
let someRandomNode = getRandomNode ();
//...
tableView.selectNode (someRandomNode);
//...
tableView.selectNodeAtIndex(4);
```

###Animation completion
You can set a block which will executed after animation was completed.
```Swift
let tableView : YUTableView
//...
tableView.animationCompetitionHandler = {
    print("Animation ended");
}
```

##Cells
You must implement "setContentsOfCell:node:" method of YUTableViewDelegate to edit cells.
```Swift
func setContentsOfCell(cell: UITableViewCell, node: YUTableViewNode) {
    if let customCell = cell as? CustomTableViewCell, let cellDic = node.data as? [String:String] {
        customCell.setLabel(cellDic["label"]!, andImage: cellDic["img"]!);
    } else {
        cell.textLabel!.text = node.data as? String;
    }
}
```

If you are loading your cell from xib don't forget to register your nib to the table view.
```Swift
let tableView : YUTableView
//...
tableView.registerNib(UINib(nibName: "NibName", bundle: nil), forCellReuseIdentifier: "Identifier");
```
