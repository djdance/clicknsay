//
//  Gift3TableViewCell.swift
//  elref
//
//  Created by Dj Dance on 16.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class Gift3TableViewCell: UITableViewCell {
    @IBOutlet weak var pin: UILabel!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var fio: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pinEdit: UITextField!
    var controller:GiftViewController! = nil

    @IBOutlet weak var submit: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        fio.text=NSUserDefaults.standardUserDefaults().stringForKey("giftUsername")
        if fio.text=="" {
            fio.text=NSUserDefaults.standardUserDefaults().stringForKey("username")
        }
        email.text=NSUserDefaults.standardUserDefaults().stringForKey("giftEmail")
        if email.text=="" {
            email.text=NSUserDefaults.standardUserDefaults().stringForKey("email")
        }

    }


    @IBAction func titleButton(sender: AnyObject) {
        //print("titleButton clicked")
        //NSNotificationCenter.defaultCenter().postNotificationName("orderGiftButton", object: nil)
        controller.orderGiftButton()
    
    }
    @IBAction func pin(sender: AnyObject) {
        let s="\(Int(arc4random_uniform(9)+1))\(Int(arc4random_uniform(9)+1))\(Int(arc4random_uniform(9)+1))\(Int(arc4random_uniform(9)+1))"
        pinEdit.text=s
    }

    @IBAction func submit(sender: AnyObject) {
        controller.submitOrder(self)
    }
    
    
}
