//
//  InfoViewController.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 7/25/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import UIKit
import CoreLocation

class InfoViewController: UIViewController {
    
    var randomCountry: String?
    var locValue: CLLocationCoordinate2D? // Latitude & Longitude value
    var priceSelected: Int? // price constraint
    var radius: Int? // radius constraint
    
    var selectedRestaurantName: String? // the restaurant selected from the API request
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var imageURL: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("hi")
        println("price selected: \(priceSelected)")
        println("radius selected: \(radius)")
        restaurantLabel.text = "Loading..."
        
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
                
                //println(rows)
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
        countryLabel.text = randomCountry
    }
    
    func startRestaurantRequest() {
        if locValue != nil {
            let url = Network.buildURL(priceSelected!, radius: radius!, locValue: locValue!, countryKeyword: randomCountry!)
            println(url)
            Network.getGooglePlaces(url, completionHandler: { response -> Void in
                if let dict = response {
                    println("passed dict = response")
                    self.restaurantsReceived(dict)
                }
            })
        }
        else {
            println("sorry, location not found")
        }
    }
    
    func restaurantsReceived(restaurants: [NSDictionary]) {
        
        var restaurantNameArray: [String] = []
        if restaurants.count > 0 {
            for place in restaurants {
                let results = place["name"] as? String ?? ""
                restaurantNameArray.append(results)
                
                println("your place selected is: \(results)")
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.restaurantLabel.text = "\(restaurantNameArray[0])"
                    self.downloadImage()
                }
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
        if let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=CnRtAAAATLZNl354RwP_9UKbQ_5Psy40texXePv4oAlgP4qNEkdIrkyse7rPXYGd9D_Uj1rVsQdWT4oRz4QrYAJNpFX7rzqqMlZw2h2E2y5IKMUZ7ouD_SlcHxYq1yL4KbKUv3qtWgTK0A6QbGh87GB3sscrHRIQiG2RrmU_jF4tENr9wGS_YxoUSSDrYjWmrNfeEHSGSc3FyhNLlBU&key=AIzaSyAKtrEj6qZ17YcjfD4SlijGbZd96ZZPkRM") {
            if let data = NSData(contentsOfURL: url){
                imageURL.contentMode = UIViewContentMode.ScaleAspectFit
                imageURL.image = UIImage(data: data)
            }
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
