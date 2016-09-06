//
//  CommentTableViewCell.swift
//  icome
//
//  Created by Tuo Zhang on 2016-02-22.
//  Copyright © 2016 iCome. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Featured_Image: UIImageView!
    @IBOutlet weak var Usernames: UILabel!
    @IBOutlet weak var Content: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
