//
//  Root1TableViewCell.swift
//  elref
//
//  Created by Dj Dance on 17.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class WordTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var repatsLabel: UILabel!
    @IBOutlet weak var enableButton: UISwitch!
    
    var delegate: WordsViewController?
    var indexPath: NSIndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(titleButtonTapped(_:)))
        title.addGestureRecognizer(tapGestureRecognizer)
        title.userInteractionEnabled = false

    }
    
    func titleButtonTapped(sender: AnyObject) {
        delegate?.tableViewCellTitleClicked(self)
    }
    
    @IBAction func enableButtonTapped(sender: AnyObject) {
        delegate?.enableButtonTapped(self)
    }
}
