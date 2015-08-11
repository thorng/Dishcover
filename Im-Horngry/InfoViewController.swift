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
    var paginatedScrollView: PaginatedScrollView?
    
    var placeDetailsURL: String = ""
    
    var address: String = ""
    var rating: Double = 0.0
    var country: String = ""
    var restaurantName: String = ""
    
    var photoReferenceID: [String] = []
    var restaurantPhotos: [UIImage] = []
    
    var priceSelected: Int? // price constraint
    var radius: Int? // radius constraint
    
    var queriesCount: Int = 0 // counting the number of requests
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var restaurantLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        placeDetailsURL = restaurant.placeDetailsURL
        
        if photoReferenceID.count == 0 {
            Network.getGooglePlacesDetails(placeDetailsURL, completionHandler: { response -> Void in
                if let response = response {
                    self.detailsReceived(response, index: index, placeDetailsURL: placeDetailsURL)
                }
            })
        }
        
        restaurantLabel.text = restaurant.name
        ratingLabel.text = "\(restaurant.rating)"
        addressLabel.text = restaurant.address
        countryLabel.text = restaurant.countrySelected
        
        // MARK: Paginated Scroll View Setup
        
        // create array of photo reference ID's
        if restaurant.photoReferenceID.count > 0 {
            for i in 0...restaurant.photoReferenceID.count - 1 {
                photoReferenceID.append(restaurant.photoReferenceID[i].photoReferenceID)
            }
        }

        var maxImages = photoReferenceID.count - 1
        var imageIndex: NSInteger = 0
        
        // downloading the photos
        for index in 0...photoReferenceID.count - 1 {
            downloadImage(photoReferenceID[index])
        }
        
        paginatedScrollView = PaginatedScrollView(frame: CGRectMake(0, 50, self.view.frame.size.width, 330))
        self.view.addSubview(paginatedScrollView!) // add to the
        
       //let restaurantPhotos: [UIImage] = [ (restaurantPhotos!.image.value)!,  (post!.image2.value)!, (post!.image3.value)!]
        
        self.paginatedScrollView?.images = restaurantPhotos

    }
    
    func downloadImage(photoReference: String) {
        if let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" + photoReference + "&key=AIzaSyAKtrEj6qZ17YcjfD4SlijGbZd96ZZPkRM") {
            if let data = NSData(contentsOfURL: url) {
                restaurantPhotos.append(UIImage(data: data)!)
            }
        }
    }
    
    // adds restaurant name to Realm
    func addObjectToRealm() {
        
//        Network.getGooglePlacesDetails(self.placeDetailsURL, completionHandler: { response -> Void in
//            
//            if let response = response {
//                
//                let results = response as NSDictionary
//                
//                
//                }
//                
//            }
//        })
    
        let realm = Realm()

        let realmRestaurant = Restaurant(value: ["placeDetailsURL": self.restaurant.placeDetailsURL, "name": self.restaurant.name, "countrySelected": self.restaurant.countrySelectedKey, "address": self.restaurant.address, "phoneNumber": self.restaurant.phoneNumber])
        
        realm.write {
            //realm.create(Restaurant.self, value: results, update: true)
            realm.add(realmRestaurant)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        println("MEMORY WARNING")
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "exitFromInfoController" {
            self.addObjectToRealm()
        }
    }

}