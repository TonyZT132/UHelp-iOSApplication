//
//  PersonalInfoTableViewCell.swift
//  icome
//
//  Created by Tuo Zhang on 2016-02-29.
//  Copyright © 2016 iCome. All rights reserved.
//

import UIKit

class PersonalInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var NickName: UILabel!
    @IBOutlet weak var Content: UILabel!
    @IBOutlet weak var Featured_Image: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
