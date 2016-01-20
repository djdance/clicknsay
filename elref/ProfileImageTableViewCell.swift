//
//  ProfileImageTableViewCell.swift
//  elref
//
//  Created by Dj Dance on 07.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class ProfileImageTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var foto: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        //foto.backgroundColor=UIColor.whiteColor()
        foto.layer.cornerRadius = 15
        foto.layer.masksToBounds = true
        foto.clipsToBounds=true
        foto.layer.borderColor = UIColor.lightGrayColor().CGColor// greyColor];.CGColor;
        foto.layer.borderWidth = 0.5;
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
