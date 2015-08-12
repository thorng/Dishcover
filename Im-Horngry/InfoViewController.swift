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
    var isSegueFromRestaurantHistory = false
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var eatenButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // hide eaten button if accessing from History
        if isSegueFromRestaurantHistory == true {
            eatenButton.hidden = true
        }
        
        // if accessing from history, get photos and display. else, just display the photos
        placeDetailsURL = restaurant.placeDetailsURL
        if restaurant.photoReferenceID.count == 0 {
            println("placeDetailsURL: \(placeDetailsURL)")
            
            Network.getGooglePlacesDetails(placeDetailsURL, completionHandler: { response -> Void in
                if let response = response {
                    self.detailsReceived(response)
                }
            })
            
        } else {
            println("else function called")
            downloadArrayOfPhotos()
        }
        
        restaurantLabel.text = restaurant.name
        ratingLabel.text = "\(restaurant.rating)"
        addressLabel.text = restaurant.address
        countryLabel.text = restaurant.countrySelected

    }
    
    func downloadArrayOfPhotos() {
        
        if restaurant.photoReferenceID.count > 0 {
            
            for i in 0...restaurant.photoReferenceID.count - 1 {
                photoReferenceID.append(restaurant.photoReferenceID[i].photoReferenceID)
            }
            
            var maxImages = photoReferenceID.count - 1
            var imageIndex: NSInteger = 0
            
            // downloading the photos
            for index in 0...photoReferenceID.count - 1 {
                let realm = Realm()
                downloadImage(photoReferenceID[index])
            }
            
            paginatedScrollViewSetup()
        }
        
    }
    
    // MARK: Paginated Scroll View Setup
    func paginatedScrollViewSetup() {
        
        paginatedScrollView = PaginatedScrollView(frame: CGRectMake(0, -5, self.view.frame.size.width, 330))
        
        self.view.addSubview(paginatedScrollView!) // add to the subview
        
        self.paginatedScrollView?.images = restaurantPhotos
        
    }
    
    func detailsReceived(restaurantDetails: NSDictionary) {
        
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            
            // grab and display photo
            if let photos = restaurantDetails["photos"] as? [NSDictionary] {
                
                // store all photo_reference ID's in the request
                for i in 0...photos.count - 1 {
                    
                    let photo_dictionary = photos[i]
                    
                    if let photo_ref = photo_dictionary["photo_reference"] as? String {
                        
                        let realm = Realm()
                        let photoIDObject = PhotoID()
                        
                        photoIDObject.photoReferenceID = photo_ref
                        
                        // ERROR: Terminating app due to uncaught exception 'RLMException', reason: 'Realm accessed from incorrect thread'
                        
                        // Create array of photoReferenceID's
                        realm.write {
                            self.restaurant.photoReferenceID.append(photoIDObject)
                        }
                    }
                }
            }
            
            // Download photos using above array of photoReferenceID's
            self.downloadArrayOfPhotos()

        }
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
        let realm = Realm()

        let realmRestaurant = Restaurant(value: ["placeDetailsURL": self.restaurant.placeDetailsURL, "name": self.restaurant.name, "countrySelected": self.restaurant.countrySelectedKey, "address": self.restaurant.address, "phoneNumber": self.restaurant.phoneNumber, "rating": self.restaurant.rating])
        
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
        
        if segue.identifier == "exitToHistory" {
            
        }
        
    }

}