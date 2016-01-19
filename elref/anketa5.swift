//
//  anketa1.swift
//  elref
//
//  Created by Dj Dance on 17.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class anketa2: UIView {

   
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var mainView: UIView!

    var itemId=0

    
    @IBAction func didPressCB(sender: CheckboxButton) {
        sender.selected = !sender.selected
    }
}
