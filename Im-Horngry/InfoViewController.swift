//
//  InfoViewController.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 7/25/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    //var selectedCountry: String!
    var priceSelected: Int!
    var radius: Int!
    
    @IBOutlet weak var restaurantLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("hi")
        println("price selected: \(priceSelected)")
        println("radius selected: \(radius)")
        restaurantLabel.text = "someting"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func returnRestaurant() {
//        if locValue != nil {
//            Network.getGooglePlaces(randomCountry){ (response) -> Void in
//                if let places = response {
//                    for place in places {
//                        println(place["name"])
//                        selectedCountry = place["name"] as! String
//                    }
//                }
//            }
//        }
//        else {
//            println("sorry, location not found")
//        }
//    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
