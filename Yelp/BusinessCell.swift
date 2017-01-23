//
//  BusinessCell.swift
//  Yelp
//
//  Created by Jiapei Liang on 1/22/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var restaurantImageView: UIImageView!
    
    var business: Business! {
        didSet {
            nameLabel.text = business.name
            ratingImageView.setImageWith(business.ratingImageURL!)
            addressLabel.text = business.address
            categoriesLabel.text = business.categories
            reviewCountLabel.text = "\(business.reviewCount!) Reviews"
            distanceLabel.text = business.distance
            if let imageURL = business.imageURL {
                restaurantImageView.setImageWith(imageURL)
            }
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        restaurantImageView.layer.cornerRadius = 5
        restaurantImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
