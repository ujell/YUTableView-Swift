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
    
    var insertRowAnimation: UITableViewRowAnimation = .right
    var deleteRowAnimation: UITableViewRowAnimation = .left
    
    enum AnimationTarget {
        case insert
        case delete
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? ViewController {
            destination.setTableViewSettings(closeOtherNodes: otherNodesSwitch.isOn, insertAnimation: insertRowAnimation, deleteAnimation: deleteRowAnimation)
        }
    }

    
    @IBAction func insertRowAnimationButtonTouched(_ sender: AnyObject) {
        let actionSheet = UIAlertController (title: "Insert Row Animation", message: nil, preferredStyle: .actionSheet)
        addActionsToActionSheet(actionSheet, animationTarget: .insert)
        present(actionSheet, animated:true, completion:nil)
    }
    
    @IBAction func deleteRowAnimationButtonTouched(_ sender: AnyObject) {
        let actionSheet = UIAlertController (title: "Remove Row Animation", message: nil, preferredStyle: .actionSheet)
        addActionsToActionSheet(actionSheet, animationTarget: .delete)
        present(actionSheet, animated:true, completion:nil)
    }
    
    func addActionsToActionSheet (_ actionSheet: UIAlertController, animationTarget: AnimationTarget) {
        
        actionSheet.addAction(UIAlertAction(title: "Fade", style: .default, handler: { action in
            self.setAnimation(.fade, title: "Fade", animationTarget: animationTarget) }))
        actionSheet.addAction(UIAlertAction(title: "Right", style: .default, handler: { action in
            self.setAnimation(.right, title: "Right", animationTarget: animationTarget) }))
        actionSheet.addAction(UIAlertAction(title: "Left", style: .default, handler: { action in
            self.setAnimation(.left, title: "Left", animationTarget: animationTarget) }))
        actionSheet.addAction(UIAlertAction(title: "Top", style: .default, handler: { action in
            self.setAnimation(.top, title: "Top", animationTarget: animationTarget) }))
        actionSheet.addAction(UIAlertAction(title: "Bottom", style: .default, handler: { action in
            self.setAnimation(.bottom, title: "Bottom", animationTarget: animationTarget) }))
        actionSheet.addAction(UIAlertAction(title: "Middle", style: .default, handler: { action in
            self.setAnimation(.middle, title: "Middle", animationTarget: animationTarget) }))
        actionSheet.addAction(UIAlertAction(title: "Automatic", style: .default, handler: { action in
            self.setAnimation(.automatic, title: "Automatic", animationTarget: animationTarget) }))
        actionSheet.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler:nil))
    }

    
    func setAnimation (_ animation: UITableViewRowAnimation, title: String, animationTarget: AnimationTarget) {
        if animationTarget == .insert {
            insertRowAnimation = animation
            insertRowAnimationButton.setTitle(title, for: UIControlState())
        } else if animationTarget == .delete {
            deleteRowAnimation = animation
            deleteRowAnimationButton.setTitle(title, for: UIControlState())
        }
    }
}
