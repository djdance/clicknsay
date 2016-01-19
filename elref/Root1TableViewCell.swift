//
//  Root1TableViewCell.swift
//  elref
//
//  Created by Dj Dance on 17.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class Root1TableViewCell: UITableViewCell {
    @IBOutlet weak var ico: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
