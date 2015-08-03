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

class InfoViewController: UIViewController {
    
    var randomCountry: String?
    var locValue: CLLocationCoordinate2D? // Latitude & Longitude value
    var priceSelected: Int? // price constraint
    var radius: Int? // radius constraint
    var photoReference: String? // photo reference to display on the view
    
    var selectedRestaurantName: String? // the restaurant selected from the API request
    
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
        randomCountry = Array(countryDict.values)[index]
        
        println(randomCountry)
    }
    
    func startRestaurantRequest() {
        if locValue != nil {
            let url = Network.buildSearchURL(priceSelected!, radius: radius!, locValue: locValue!, countryKeyword: randomCountry!)
            println(url)
            Network.getGooglePlaces(url, completionHandler: { response -> Void in
                if let dict = response {
                    self.restaurantsReceived(dict)
                }
            })
        }
        else {
            println("sorry, location not found")
        }
    }
    
    // MARK: Google search results
    func restaurantsReceived(restaurants: [NSDictionary]) {
        var restaurantNameArray: [String] = []
        
        // check to see if there's a first result, and only display that one
        if let place = restaurants.first {
            
            let results = place["name"] as? String ?? ""
            let rating = place["rating"] as? Double
            
            let reference = place["reference"] as? String
            
            // Get the Google Details request
            let placeDetailsURL = Network.buildDetailsURL(reference!)
            Network.getGooglePlacesDetails(placeDetailsURL, completionHandler: { response -> Void in
                self.addressLabel.text = "Loading address..."
                if let response = response {
                    self.detailsReceived(response)
                }
            })
            
            // grab photo reference string
            if let photos = place["photos"] as? [NSDictionary] {
                if let photo_dictionary = photos.first, photo_ref = photo_dictionary["photo_reference"] as? String {
                    photoReference = photo_ref
                }
            }
            
            restaurantNameArray.append(results)
            
            println("your place selected is: \(results)")
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.countryLabel.text = self.randomCountry
                self.restaurantLabel.text = "\(restaurantNameArray[0])"
                self.ratingLabel.text = "Rating: \(rating!)"
                self.downloadImage()
            }
        } else {
            
            // Debugging
            println("no results, trying again")
            println()
            
            // Switch to main thread
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.restaurantLabel.text = "Sorry, no restaurants found. Trying again..."
            }
            
            // Restart the request with a different country!
            generateRandomCountry()
            startRestaurantRequest()
        }
    }
    
    // Download Image
    func downloadImage() {
        if let photoReference = photoReference {
            if let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" + photoReference + "&key=AIzaSyAKtrEj6qZ17YcjfD4SlijGbZd96ZZPkRM") {
                if let data = NSData(contentsOfURL: url){
                    imageURL.contentMode = UIViewContentMode.ScaleAspectFit
                    imageURL.image = UIImage(data: data)
                }
            }
        }
    }
    
    // MARK: Google Details Results
    func detailsReceived(restaurantDetails: NSDictionary) {
        println("detailsReceived function called")
        
        let address = restaurantDetails["formatted_address"] as? String ?? ""
        addressLabel.text = address
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