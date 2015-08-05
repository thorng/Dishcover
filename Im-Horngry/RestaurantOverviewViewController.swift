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
    var selectedRestaurantName: String? // the restaurant selected from the API request
    var rating: [Double]?
    var address: [String]?
    var detailsReference: [String]? // photo reference to display on the view
    var restaurantNameArray: [String] = [] // the restaurant names
    
    // === DEBUGGING VARIABLES ===
    var queriesCount: Int = 0 // counting the number of requests
    
    // === OUTLET VARIABLES ===
    @IBOutlet weak var countryLabel: UILabel! // "you're flying to 'countyLabel' today."
    @IBOutlet weak var firstRestaurantLabel: UIButton!
    @IBOutlet weak var secondRestaurantLabel: UIButton!
    @IBOutlet weak var thirdRestaurantLabel: UIButton!
    
    
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
        let index: Int = Int(arc4random_uniform(UInt32(countryDict.count)))
        randomCountryKey = Array(countryDict.keys)[index]
        randomCountry = Array(countryDict.values)[index]
        
        println(randomCountryKey)
        println(randomCountry)
    }
    
    func startRestaurantRequest() {
        if locValue != nil {
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
            if restaurants.count >= 3 {
                for x in 0..2 {
                    
                    // "place" selects an index from the ARRAY of restaurants
                    var place = restaurants[x]
                    
                    // within that index is a dictionary. "selectedRestaurantName" selects a key from that dictionary
                    selectedRestaurantName = place["name"] as? String ?? "ERROR while retrieving restaurant name"
                    rating.append(place["rating"] as? Double)
                    
                    // Get the Google Details request
                    detailsReference.append(place["reference"] as? String)
                    self.detailsRequest(photoReference)
                    
                    // grab photo reference string
                    if let photos = place["photos"] as? [NSDictionary] {
                        if let photo_dictionary = photos.first, photo_ref = photo_dictionary["photo_reference"] as? String {
                            detailsReference[x] = photo_ref
                        }
                    }
                    
                    restaurantNameArray.append(selectedRestaurantName)
                    println("your place selected is: \(selectedRestaurantName)")
                    
                    // Display all the information
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        self.countryLabel.text = "You're flying to \(self.randomCountryKey!) today."
                        
                        // setting the
                        if x = 0 {
                            self.firstRestaurantLabel.text = "\(self.restaurantNameArray[x])"
                        } else if x = 1 {
                            self.secondRestaurantLabel.text = "\(self.restaurantNameArray[x])"
                        } else if x = 2 {
                            self.thirdRestaurantLabel.text = "\(self.restaurantNameArray[x])"
                        } else {
                            println("whoops, there's an error with the index 'x'")
                        }
                        
                        self.downloadAndDisplayImage()
                    }
                }
            }
        } else {
            retryRequest()
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
    func downloadAndDisplayImage() {
        if let photoReference = detailsReference {
            if let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" + photoReference + "&key=AIzaSyAKtrEj6qZ17YcjfD4SlijGbZd96ZZPkRM") {
                if let data = NSData(contentsOfURL: url){
                    imageURL.contentMode = UIViewContentMode.ScaleAspectFit
                    imageURL.image = UIImage(data: data)
                }
            }
        }
    }
    
    // MARK: Google Details Request
    func detailsRequest(referenceIdentifier: String) {
        let placeDetailsURL = Network.buildDetailsURL(detailsReference!)
        Network.getGooglePlacesDetails(placeDetailsURL, completionHandler: { response -> Void in
            if let response = response {
                self.detailsReceived(response)
            }
        })
    }
    
    // Google Details Results
    func detailsReceived(restaurantDetails: NSDictionary) {
        self.address = restaurantDetails["formatted_address"] as? String ?? ""
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "firstRestaurant" {
            
        }
    }

}
