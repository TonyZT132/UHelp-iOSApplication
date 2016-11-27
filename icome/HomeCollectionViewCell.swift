//
//  HomeCollectionViewCell.swift
//  icome
//
//  Created by Tuo Zhang on 2016-01-12.
//  Copyright © 2016 iCome. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell{

    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var thumbnailImage3: UIImageView!
    @IBOutlet weak var thumbnailImage2: UIImageView!
    @IBOutlet weak var thumbnailImage1: UIImageView!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var viewCount: UILabel!
    @IBOutlet weak var commectCountImage: UIImageView!
    @IBOutlet weak var viewCountImage: UIImageView!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var genderImage: UIImageView!
    @IBOutlet weak var shortDescription: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var nickName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
