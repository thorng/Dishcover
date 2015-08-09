//
//  InfoViewController.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 7/25/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import RealmSwift

class InfoViewController: UIViewController {
    
    var restaurant = Restaurant()
    
    var priceSelected: Int? // price constraint
    var radius: Int? // radius constraint
    var photoReference: String? // photo reference to display on the view
    
    var selectedRestaurantName: String? // the restaurant selected from the API request
    
    var restaurantNameArray: [String] = [] // the restaurant names
    
    var queriesCount: Int = 0 // counting the number of requests
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var imageURL: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("price selected: \(priceSelected)")
        println("radius selected: \(radius)")
        
        restaurantLabel.text = "Loading..."
        countryLabel.text = ""
        ratingLabel.text = ""
        addressLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // adds restaurant name to Realm
    func addObjectToRealm() {
        let restaurantVisited = Restaurant()
        let realm = Realm()
        
        realm.write {
            if self.restaurantNameArray.count > 0 {
                restaurantVisited.name = self.restaurantNameArray[0]
                realm.add(restaurantVisited)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "exitFromInfoController" {
            self.addObjectToRealm()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}