//
//  FollowTableViewCell.swift
//  icome
//
//  Created by Tuo Zhang on 2016-01-19.
//  Copyright © 2016 iCome. All rights reserved.
//

import UIKit

class FollowTableViewCell: UITableViewCell {
    @IBOutlet weak var GenderImage: UIImageView!

    @IBOutlet weak var FeaturedImage: UIImageView!
    @IBOutlet weak var City: UILabel!
    @IBOutlet weak var Nickname: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
