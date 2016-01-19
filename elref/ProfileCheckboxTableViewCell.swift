//
//  ProfileCheckboxTableViewCell.swift
//  elref
//
//  Created by Dj Dance on 07.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class ProfileCheckboxTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var checkbox: UISwitch!
    var controller:ProfileViewController! = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        checkbox.addTarget(self, action: "switchChanged:", forControlEvents: UIControlEvents.ValueChanged)
    }
    func switchChanged(mySwitch: UISwitch) {
        //print("switchChanged, \(mySwitch.on)")
        controller.changedValue(self)
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
