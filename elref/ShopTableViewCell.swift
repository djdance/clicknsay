//
//  ShopTableViewCell.swift
//  elref
//
//  Created by Dj Dance on 14.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class ShopTableViewCell: UITableViewCell {
    @IBOutlet weak var ico: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var price: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
