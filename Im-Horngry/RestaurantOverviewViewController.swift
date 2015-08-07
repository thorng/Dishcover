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
    
    // === DEBUGGING VARIABLES ===
    var queriesCount: Int = 0 // counting the number of requests
    
    // === OUTLET VARIABLES ===
    @IBOutlet weak var firstRestaurantImage: UIImageView!
    @IBOutlet weak var secondRestaurantImage: UIImageView!
    @IBOutlet weak var thirdRestaurantImage: UIImageView!
    
    // =========================

    override func viewDidLoad() {
        super.viewDidLoad()

        // Creates dictionary of Countries and Adjectivals
        parseTxtToDictionary()
        
        // Randomly generate dict value
        generateRandomCountry()
        
        // Start the restaurant request
        startRestaurantRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        // check to see if there's a first result, and only display that one
        if let restaurants = restaurants {
            
            // Find out how many results and set max results equal to that number
            // ^ update this variable only if it's less than 2, based on the dictionary received
            var restaurantsCount = restaurants.count
            var maxResults = 2
            
            if restaurantsCount > 0 {
                
                if restaurantsCount < maxResults {
                    maxResults = restaurantsCount
                }
                
                for x in 0...maxResults {
                    
                    var restaurant = Restaurant()
                    var place = restaurants[x]
                    
                    if let placeRating = place["rating"] as? Double {
                        restaurant.rating = placeRating
                        println(restaurant.rating)
                    }
                    
                    if let selectedRestaurantName = place["name"] as? String {
                        restaurant.name = selectedRestaurantName
                        println(restaurant.name)
                    }
                    
                    if let photos = place["photos"] as? [NSDictionary] {
                        if let photo_dictionary = photos.first, photo_ref = photo_dictionary["photo_reference"] as? String {
                            restaurant.photoReferenceID = photo_ref
                            println(restaurant.photoReferenceID)
                        }
                    }
                    
                    // Get the Google Details request
                    if let placeReference: AnyObject = place["reference"] as? String {
                        restaurant.detailsReferenceID = placeReference as! String
                        self.detailsRequest(restaurant.detailsReferenceID)
                    }

                    println("your place selected is: \(restaurant.name)")
                    
                    
                    
                    restaurantArray.append(restaurant)
                }
            }
            // TODO: Create a function that looks at the restaurant array, and update buttons/info based on this info. needs for loop
        } else {
            retryRequest()
        }
    }
    
    func displayRestaurantInformation() {
        for x...restaurantArray.count {
            restaurantsArray[restaurants]
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
    func downloadAndDisplayImage(photoReference: String) {
        if let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" + photoReference + "&key=AIzaSyAKtrEj6qZ17YcjfD4SlijGbZd96ZZPkRM") {
            if let data = NSData(contentsOfURL: url){
                //imageURL.contentMode = UIViewContentMode.ScaleAspectFit
                //imageURL.image = UIImage(data: data)
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
        // add object to restaurant object
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "firstRestaurant" {
            
        }
    }

}
