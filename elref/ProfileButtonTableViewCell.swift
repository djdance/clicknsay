//
//  ProfileImageTableViewCell.swift
//  elref
//
//  Created by Dj Dance on 07.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class ProfileButtonTableViewCell: UITableViewCell {
    @IBOutlet weak var sB: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        sB.layer.cornerRadius = 10
        sB.layer.masksToBounds = true
        

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
