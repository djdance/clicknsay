//
//  anketa1.swift
//  elref
//
//  Created by Dj Dance on 17.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class anketa2: UIView {
    var controller:PollViewController!=nil
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var mainView: UIView!

    var itemId=0
    var type=0

    @IBOutlet weak var checkbox: CheckboxButton!
    
    
    
    @IBAction func didPressCB(sender: CheckboxButton) {
        sender.selected = true//!sender.selected
        if controller != nil {
            controller.radioChecked(self)
        }
    }
    

}
