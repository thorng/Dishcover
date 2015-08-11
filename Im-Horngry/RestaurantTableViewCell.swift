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
        
//        Network.getGooglePlacesDetails(restaurant!.placeDetailsURL, completionHandler: { response -> Void in
//            if let response = response {
//                self.detailsReceived(response)
//            }
//        })

        // Configure the view for the selected state
    }
    
    func detailsReceived(restaurantDetails: NSDictionary) {
        if let photos = restaurantDetails["photos"] as? [NSDictionary] {
            
            // store all photo_reference ID's in the request
            for i in 0...photos.count - 1 {
                
                let photo_dictionary = photos[i]
                
                if let photo_ref = photo_dictionary["photo_reference"] as? String {
                    
                    let photoIDObject = PhotoID()
                    photoIDObject.photoReferenceID = photo_ref
                    
                    if let restaurant = restaurant {
                        restaurant.photoReferenceID.append(photoIDObject)
                    }
                    
                }
            }
        }
    }

}
