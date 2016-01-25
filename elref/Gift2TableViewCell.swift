//
//  Gift2TableViewCell.swift
//  elref
//
//  Created by Dj Dance on 16.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class Gift2TableViewCell: UITableViewCell {
    var instuctions=""

    @IBOutlet weak var whereButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        whereButton.layer.cornerRadius = 15
        whereButton.layer.masksToBounds = true

    }

    @IBAction func whereButton(sender: UIButton) {
    }

}
