//
//  DirectionsTableViewCell.swift
//  Yelp
//
//  Created by Jiapei Liang on 2/20/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class DirectionsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ETALabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
