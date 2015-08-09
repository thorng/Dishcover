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
    
    var restaurantImages: [UIImageView] = []
    
    // === DEBUGGING VARIABLES ===
    var queriesCount: Int = 0 // counting the number of requests
    
    var detailsReceivedCount: Int = 0
    
    var maxResults = 2
    
    // === OUTLET VARIABLES ===
    @IBOutlet weak var firstRestaurantImage: UIImageView!
    @IBOutlet weak var secondRestaurantImage: UIImageView!
    @IBOutlet weak var thirdRestaurantImage: UIImageView!
    
    @IBOutlet weak var firstRestaurantNameLabel: UILabel!
    @IBOutlet weak var secondRestaurantNameLabel: UILabel!
    @IBOutlet weak var thirdRestaurantNameLabel: UILabel!
    
    @IBOutlet weak var firstRestaurantButton: UIButton!
    @IBOutlet weak var secondRestaurantButton: UIButton!
    @IBOutlet weak var thirdRestaurantButton: UIButton!
    
    @IBOutlet weak var firstRestaurantRatingLabel: UILabel!
    @IBOutlet weak var secondRestaurantRatingLabel: UILabel!
    @IBOutlet weak var thirdRestaurantRatingLabel: UILabel!
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
    func restaurantsReceived(restaurants: [NSDictionary]) {
        
        println("restaurantsReceived function called...")
        
        // check to see if there are results
        //if let restaurants = restaurants {
        println("if statement called")
        if restaurants.count > 0 {
            // Find out how many results and set max results equal to that number
            // ^ update this variable only if it's less than 2, based on the dictionary received
            var restaurantsCount = restaurants.count
            
            if restaurantsCount > 0 {
                
                if restaurantsCount <= maxResults {
                    maxResults = restaurantsCount - 1
                }
                
                for x in 0...maxResults {
                    
                    var place = restaurants[x]
                    
                    // Get the Google Details request
                    if let placeReference = place["reference"] as? String {
                        self.detailsRequest(placeReference, index: x)
                    }
                }
            }
        }
        //}
        else {
            println("else statement called")
            retryRequest()
        }
    }
    
    // MARK: Google Details Request
    func detailsRequest(referenceIdentifier: String, index: Int) {
        let placeDetailsURL = Network.buildDetailsURL(referenceIdentifier)
        println("=============")
        println(placeDetailsURL)
        println("=============")
        Network.getGooglePlacesDetails(placeDetailsURL, completionHandler: { response -> Void in
            if let response = response {
                self.detailsReceived(response, index: index)
            }
        })
    }
    
    // Google Details Results
    func detailsReceived(restaurantDetails: NSDictionary, index: Int) {
        
        println("detailsReceived function called...")
        
        // create a new restaurant object to store all the info
        let restaurant = Restaurant()
        
        if let name = restaurantDetails["name"] as? String {
            restaurant.name = name
        }
        
        if let rating = restaurantDetails["rating"] as? String {
            restaurant.rating = rating
        }
        
        if let address = restaurantDetails["formatted_address"] as? String {
            restaurant.address = address
        }
        
        if let phoneNumber = restaurantDetails["formatted_phone_number"] as? String {
            restaurant.phoneNumber = phoneNumber
        }
        
        // grab and display photo
        if let photos = restaurantDetails["photos"] as? [NSDictionary] {
            if let photo_dictionary = photos.first, photo_ref = photo_dictionary["photo_reference"] as? String {
                restaurant.photoReferenceID = photo_ref
            }
        }
        
        detailsReceivedCount++
        restaurantArray.append(restaurant)
        
        if detailsReceivedCount - 1 == maxResults {
            displayRestaurantInformation(restaurant)
        }
    }
    
    // Download and Display Image
    func downloadAndDisplayImage(photoReference: String, restaurantImageArray: [UIImageView], index: Int) {
        if let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" + photoReference + "&key=AIzaSyAKtrEj6qZ17YcjfD4SlijGbZd96ZZPkRM") {
            if let data = NSData(contentsOfURL: url) {
                restaurantImageArray[index].contentMode = UIViewContentMode.ScaleAspectFill
                restaurantImageArray[index].image = UIImage(data: data)
            }
        }
    }
    
    // function that looks at the restaurant array and updates buttons/info based on this info.
    func displayRestaurantInformation(restaurant: Restaurant) {
        
        var restaurantImageArray: [UIImageView] = [self.firstRestaurantImage, self.secondRestaurantImage, self.thirdRestaurantImage]
        var restaurantNameArray: [UILabel] = [self.firstRestaurantNameLabel, self.secondRestaurantNameLabel, self.thirdRestaurantNameLabel]
        var restaurantButtonArray: [UIButton] = [self.firstRestaurantButton, self.secondRestaurantButton, self.thirdRestaurantButton]
        var restaurantRatingArray: [UILabel] = [self.firstRestaurantRatingLabel, self.secondRestaurantRatingLabel, self.thirdRestaurantRatingLabel]
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            for x in 0...self.detailsReceivedCount - 1 {
                
                restaurantRatingArray[x].text = self.restaurantArray[x].rating
                restaurantNameArray[x].text = self.restaurantArray[x].name
                
                self.downloadAndDisplayImage(self.restaurantArray[x].photoReferenceID, restaurantImageArray: restaurantImageArray, index: x)
            }
        }
    }
    
    // Retry the request if request returns nothing
    func retryRequest(){
        
        println("no results, trying again")
        println()
        
        // Switch to main thread
//        dispatch_async(dispatch_get_main_queue()) { () -> Void in
//            self.restaurantLabel.text = "Still loading..."
//        }
        
        // Restart the request with a different country!
        generateRandomCountry()
        startRestaurantRequest()
        
        queriesCount++
        println(queriesCount)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "firstRestaurant" {
            
        }
    }

}
