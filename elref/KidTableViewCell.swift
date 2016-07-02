//
//  Root1TableViewCell.swift
//  elref
//
//  Created by Dj Dance on 17.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class KidTableViewCell: UITableViewCell {
    @IBOutlet weak var ico: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var plashka: UIView!
    
    var delegate: RootViewController?
    var indexPath: NSIndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true

        plashka.layer.cornerRadius = 15
        plashka.layer.masksToBounds = true

        title.layer.cornerRadius = 5
        title.layer.masksToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(titleButtonTapped(_:)))
        title.addGestureRecognizer(tapGestureRecognizer)
        title.userInteractionEnabled = false

        ico.layer.cornerRadius = 5
        ico.layer.masksToBounds = true
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(icoButtonTapped(_:)))
        ico.addGestureRecognizer(tapGestureRecognizer2)
        ico.userInteractionEnabled = true
    }
    
    func titleButtonTapped(sender: AnyObject) {
        //var newState: CheckboxState = .Checked // depends on whether the image shows checked or unchecked
        delegate?.tableViewCellTitleClicked(self)
    }
    func icoButtonTapped(sender: AnyObject) {
        delegate?.tableViewCellIcoClicked(self)
    }
    
}
