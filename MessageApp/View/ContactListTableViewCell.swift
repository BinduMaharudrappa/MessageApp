//
//  ContactListTableViewCell.swift
//  MessageApp
//
//  Created by Bindu Maharudrappa on 28.09.19.
//  Copyright © 2019 Bindu Maharudrappa. All rights reserved.
//

import UIKit

class ContactListTableViewCell: UITableViewCell {

    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userDisplayName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
