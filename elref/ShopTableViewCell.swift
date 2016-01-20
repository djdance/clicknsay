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
        
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        price.layer.cornerRadius = 10
        price.layer.masksToBounds = true

    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
