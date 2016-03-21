//
//  SettingsViewController.swift
//  YUTableView-Swift
//
//  Created by yücel uzun on 24/07/15.
//  Copyright © 2015 Yücel Uzun. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var otherNodesSwitch: UISwitch!
    
    @IBOutlet weak var insertRowAnimationButton: UIButton!
    @IBOutlet weak var deleteRowAnimationButton: UIButton!
    
    var insertRowAnimation: UITableViewRowAnimation = .Right
    var deleteRowAnimation: UITableViewRowAnimation = .Left
    
    enum AnimationTarget {
        case Insert
        case Delete
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? ViewController {
            destination.setTableViewSettings(closeOtherNodes: otherNodesSwitch.on, insertAnimation: insertRowAnimation, deleteAnimation: deleteRowAnimation)
        }
    }

    
    @IBAction func insertRowAnimationButtonTouched(sender: AnyObject) {
        let actionSheet = UIAlertController (title: "Insert Row Animation", message: nil, preferredStyle: .ActionSheet)
        addActionsToActionSheet(actionSheet, animationTarget: .Insert)
        presentViewController(actionSheet, animated:true, completion:nil)
    }
    
    @IBAction func deleteRowAnimationButtonTouched(sender: AnyObject) {
        let actionSheet = UIAlertController (title: "Remove Row Animation", message: nil, preferredStyle: .ActionSheet)
        addActionsToActionSheet(actionSheet, animationTarget: .Delete)
        presentViewController(actionSheet, animated:true, completion:nil)
    }
    
    func addActionsToActionSheet (actionSheet: UIAlertController, animationTarget: AnimationTarget) {
        
        actionSheet.addAction(UIAlertAction(title: "Fade", style: .Default, handler: { action in
            self.setAnimation(.Fade, title: "Fade", animationTarget: animationTarget) }))
        actionSheet.addAction(UIAlertAction(title: "Right", style: .Default, handler: { action in
            self.setAnimation(.Right, title: "Right", animationTarget: animationTarget) }))
        actionSheet.addAction(UIAlertAction(title: "Left", style: .Default, handler: { action in
            self.setAnimation(.Left, title: "Left", animationTarget: animationTarget) }))
        actionSheet.addAction(UIAlertAction(title: "Top", style: .Default, handler: { action in
            self.setAnimation(.Top, title: "Top", animationTarget: animationTarget) }))
        actionSheet.addAction(UIAlertAction(title: "Bottom", style: .Default, handler: { action in
            self.setAnimation(.Bottom, title: "Bottom", animationTarget: animationTarget) }))
        actionSheet.addAction(UIAlertAction(title: "Middle", style: .Default, handler: { action in
            self.setAnimation(.Middle, title: "Middle", animationTarget: animationTarget) }))
        actionSheet.addAction(UIAlertAction(title: "Automatic", style: .Default, handler: { action in
            self.setAnimation(.Automatic, title: "Automatic", animationTarget: animationTarget) }))
        actionSheet.addAction(UIAlertAction(title:"Cancel", style: .Cancel, handler:nil))
    }

    
    func setAnimation (animation: UITableViewRowAnimation, title: String, animationTarget: AnimationTarget) {
        if animationTarget == .Insert {
            insertRowAnimation = animation
            insertRowAnimationButton.setTitle(title, forState: .Normal)
        } else if animationTarget == .Delete {
            deleteRowAnimation = animation
            deleteRowAnimationButton.setTitle(title, forState: .Normal)
        }
    }
}
