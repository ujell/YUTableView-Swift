//
//  CustomTableViewCell.swift
//  YUTableView-Swift
//
//  Created by yücel uzun on 24/07/15.
//  Copyright © 2015 Yücel Uzun. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setLabel (text: String, andImage imageName: String) {
        label.text = text
        img.image = UIImage(named: imageName)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
