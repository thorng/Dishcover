//
//  RestaurantTableViewCell.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 8/3/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {

    @IBOutlet weak var eatenRestaurantLabel: UILabel!
    @IBOutlet weak var eatenCountryLabel: UILabel!
    
    var restaurant: Restaurant? {
        didSet {
            eatenRestaurantLabel.text = restaurant?.name
            eatenCountryLabel.text = restaurant?.countrySelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
