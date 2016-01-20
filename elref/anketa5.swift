//
//  anketa1.swift
//  elref
//
//  Created by Dj Dance on 17.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class anketa5: UIView {

   
   
    @IBOutlet weak var mainView: UIView!

    var itemId=0

    @IBOutlet weak var editText: UITextField!
    @IBAction func didEndOnExit(sender: UITextField) {
        sender.resignFirstResponder()
    }

}
