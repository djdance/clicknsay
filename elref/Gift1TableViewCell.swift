//
//  Gift1TableViewCell.swift
//  elref
//
//  Created by Dj Dance on 16.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class Gift1TableViewCell: UITableViewCell {
    @IBOutlet weak var ico: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true

        priceLabel.layer.cornerRadius = 10
        priceLabel.layer.masksToBounds = true

    }

}
