//
//  drawerTableViewCell.swift
//  elref
//
//  Created by Dj Dance on 04.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class drawerTableViewCell: UITableViewCell {
    @IBOutlet weak var drawerItem: UILabel!
    @IBOutlet weak var ico: UILabel!
    @IBOutlet weak var desc: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
