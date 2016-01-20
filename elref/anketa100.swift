//
//  anketa1.swift
//  elref
//
//  Created by Dj Dance on 17.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class anketa100: UIView {
    var controller:PollViewController!=nil
   
    @IBOutlet weak var b: UIButton!
   
    @IBOutlet weak var mainView: UIView!

    var itemId=0

    @IBAction func b(sender: AnyObject) {
        if controller != nil {
            b.enabled=false
            controller.doneButton()
        }
    }

}
