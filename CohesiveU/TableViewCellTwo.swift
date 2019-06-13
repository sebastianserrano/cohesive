//
//  TableViewCellTwo.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-12.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit

class TableViewCellTwo: UITableViewCell {

    
    @IBOutlet weak var ProfilePhoto: UIImageView!
    @IBOutlet weak var Indicator: UIActivityIndicatorView!
    @IBOutlet weak var userTap: UIButton!
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var Offers: UILabel!
    @IBOutlet weak var UserObjectId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Indicator.color = UIColor.white
        Indicator.layer.zPosition = 0
        ProfilePhoto.layer.zPosition = 1
        userTap.layer.zPosition = 2
        ProfilePhoto.layer.cornerRadius = 5
        ProfilePhoto.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
