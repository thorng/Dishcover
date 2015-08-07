//
//  RestaurantOverviewViewController.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 8/4/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import UIKit
import MapKit

class RestaurantOverviewViewController: UIViewController {
    
    // =========================
    
    // === INPUT VARIABLES ===
    var randomCountryKey: String? // random country key
    var randomCountry: String? // random country adjectival
    var locValue: CLLocationCoordinate2D? // Latitude & Longitude value
    var priceSelected: Int? // price constraint
    var radius: Int? // radius constraint
    
    // ==== OUTPUT VARIABLES ===
    var restaurantArray: [Restaurant] = []
    var contentMode: UIViewContentMode?
    var image: UIImage?
    
    // === DEBUGGING VARIABLES ===
    var queriesCount: Int = 0 // counting the number of requests
    
    var detailsReceivedCount: Int = 0 {
        didSet {
            if detailsReceivedCount == maxResults {
//                displayRestaurantInformation()
            }
        }
    }
    
    var maxResults = 2
    
    // === OUTLET VARIABLES ===
    @IBOutlet weak var firstRestaurantImage: UIImageView!
    @IBOutlet weak var secondRestaurantImage: UIImageView!
    @IBOutlet weak var thirdRestaurantImage: UIImageView!
    
    var restaurantImageArray: [UIImageView] = [firstRestaurantImage, secondRestaurantImage, thirdRestaurantImage]
    
    @IBOutlet weak var firstRestaurantNameLabel: UILabel!
    @IBOutlet weak var secondRestaurantNameLabel: UILabel!
    @IBOutlet weak var thirdRestaurantNameLabel: UILabel!
    
    var restaurantNameArray: [UILabel] = [firstRestaurantNameLabel, secondRestaurantNameLabel, thirdRestaurantNameLabel]
    
    @IBOutlet weak var firstRestaurantButton: UIButton!
    @IBOutlet weak var secondRestaurantButton: UIButton!
    @IBOutlet weak var thirdRestaurantButton: UIButton!
    
    var restaurantButtonArray: [UIButton] = [firstRestaurantButton, secondRestaurantButton, thirdRestaurantButton]
    
    @IBOutlet weak var firstRestaurantRatingLabel: UILabel!
    @IBOutlet weak var secondRestaurantRatingLabel: UILabel!
    @IBOutlet weak var thirdRestaurantRatingLabel: UILabel!
    
    var restaurantRatingArray: [UILabel] = [firstRestaurantRatingLabel, secondRestaurantRatingLabel, thirdRestaurantRatingLabel]
    
    // =========================

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // resets count variables
        detailsReceivedCount = 0
        queriesCount = 0
        maxResults = 2
        
        // Creates dictionary of Countries and Adjectivals
        parseTxtToDictionary()
        
        // Randomly generate dict value
        generateRandomCountry()
        
        // Start the restaurant request
        startRestaurantRequest()
    }
    
    // MARK: Creating the dictionary
    // Parse .txt file into a dictionary
    func parseTxtToDictionary() {
        
        println("Parsing text to dictionary...")
        
        var arraySeparated = [String]()
        var countryName: String?
        var countryAdjectival: String?
        
        let path = NSBundle.mainBundle().pathForResource("countries_of_the_world", ofType: "txt")
        
        if let content = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil) {
            
            var array = content.componentsSeparatedByString("\n")
            
            for rows in array {
                arraySeparated = rows.componentsSeparatedByString(",")
                countryName = arraySeparated[0]
                countryAdjectival = arraySeparated[1].stringByReplacingOccurrencesOfString(" ", withString: "_")
                countryDict[countryName!] = countryAdjectival
            }
        }
    }
    
    // Randomly generate dict value
    func generateRandomCountry () {
        
        println("Generating random country...")
        
        let index: Int = Int(arc4random_uniform(UInt32(countryDict.count)))
        randomCountryKey = Array(countryDict.keys)[index]
        randomCountry = Array(countryDict.values)[index]
        
        println(randomCountryKey)
        println(randomCountry)
    }
    
    func startRestaurantRequest() {
        
        println("Starting restaurant request...")
        
        if locValue != nil {
            
            println("locValue found, building URL...")
            
            let url = Network.buildSearchURL(priceSelected!, radius: radius!, locValue: locValue!, countryKeyword: randomCountry!)
            println(url)
            Network.getGooglePlaces(url, completionHandler: { response -> Void in
                if let dict = response {
                    self.restaurantsReceived(dict)
                } else {
                    println("getGooglePlaces failed. Retrying...")
                    self.retryRequest()
                }
            })
        }
        else {
            println("Sorry, location not found")
        }
    }
    
    // MARK: Google search results
    func restaurantsReceived(restaurants: [NSDictionary]?) {
        
        // check to see if there are results
        if let restaurants = restaurants {
            
            // Find out how many results and set max results equal to that number
            // ^ update this variable only if it's less than 2, based on the dictionary received
            var restaurantsCount = restaurants.count
            
            if restaurantsCount > 0 {
                
                if restaurantsCount < maxResults {
                    maxResults = restaurantsCount
                }
                
                for x in 0...maxResults {
                    
                    var place = restaurants[x]
                    
                    // Get the Google Details request
                    if let placeReference = place["reference"] as? String {
                        self.detailsRequest(placeReference)
                    }
                }
            }
        } else {
            retryRequest()
        }
        
        
        
    }
    
    // function that looks at the restaurant array and updates buttons/info based on this info.
    func displayRestaurantInformation() {
        for var i = 0; i < restaurantArray.count; i++ {
            
        }
        
    }
    
    // Retry the request if request returns nothing
    func retryRequest(){
        // Debugging
        println("no results, trying again")
        println()
        
        // Switch to main thread
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //self.restaurantLabel.text = "Still loading..."
        }
        
        // Restart the request with a different country!
        generateRandomCountry()
        startRestaurantRequest()
        
        queriesCount++
        println(queriesCount)
    }
    
    // Download and Display Image
    func downloadAndDisplayImage(photoReference: String, restaurant: Restaurant) {
        if let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" + photoReference + "&key=AIzaSyAKtrEj6qZ17YcjfD4SlijGbZd96ZZPkRM") {
            if let data = NSData(contentsOfURL: url) {
                restaurant.image = UIImage(data: data)
            }
        }
    }
    
    // MARK: Google Details Request
    func detailsRequest(referenceIdentifier: String) {
        let placeDetailsURL = Network.buildDetailsURL(referenceIdentifier)
        Network.getGooglePlacesDetails(placeDetailsURL, completionHandler: { response -> Void in
            if let response = response {
                self.detailsReceived(response)
            }
        })
    }
    
    // Google Details Results
    func detailsReceived(restaurantDetails: NSDictionary) {
        let restaurant = Restaurant()
        
        restaurant.name = restaurantDetails["name"] as! String
        restaurant.rating = restaurantDetails["rating"] as! Double
        restaurant.address = restaurantDetails["formatted_address"] as! String
        restaurant.phoneNumber = restaurantDetails["formatted_phone_number"] as! String
        
        restaurant.contentMode = UIViewContentMode.ScaleAspectFill
        
        if let photos = restaurantDetails["photos"] as? [NSDictionary] {
            if let photo_dictionary = photos.first, photo_ref = photo_dictionary["photo_reference"] as? String {
                restaurant.photoReferenceID = photo_ref
                downloadAndDisplayImage(restaurant.photoReferenceID, restaurant: restaurant)
            }
        }
        
        detailsReceivedCount++
        restaurantArray.append(restaurant)
    }
    
    func displayRestaurantInformation() {
        for x in 0...maxResults {
            restaurantNameArray[x].text = restaurantArray[x].name
            restaurantImageArray[x].image = restaurantArray[x].image
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "firstRestaurant" {
            
        }
    }

}
