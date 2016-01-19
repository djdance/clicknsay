//
//  ProfileTextTableViewCell.swift
//  elref
//
//  Created by Dj Dance on 06.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class ProfileTextTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textEdit: UITextField!
    var controller:ProfileViewController! = nil 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textEdit.delegate=self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        //print("textFieldDidBeginEditing");
    }
    func textFieldDidEndEditing(textField: UITextField) {
        //print("textFieldDidEndEditing, value=\(textField.text)");
        controller.changedValue(self)
    }
    
    
    
}
