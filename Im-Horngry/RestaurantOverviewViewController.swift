//
//  RestaurantOverviewViewController.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 8/4/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class RestaurantOverviewViewController: UIViewController {
    
    // =========================
    
    // === INPUT VARIABLES ===
    
    var randomCountryKey: String? // random country key
    var randomCountry: String? // random country adjectival
    var locValue: CLLocationCoordinate2D? // Latitude & Longitude value
    var priceSelected: Int? // price constraint
    var radius: Int? // radius constraint
    
    var isSegueFromRestaurantHistory = false
    
    // ==== OUTPUT VARIABLES ===
    var restaurantArray: [Restaurant] = []
    var contentMode: UIViewContentMode?
    var image: UIImage?
    
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
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    
    // =========================

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

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
        //NSOperationQueue.mainQueue().addOperationWithBlock() {

        println("Generating random country...")
        
        let index: Int = Int(arc4random_uniform(UInt32(countryDict.count)))
        randomCountryKey = Array(countryDict.keys)[index]
        randomCountry = Array(countryDict.values)[index]
        
        let realm = Realm()
        var realmRestaurants: Results<Restaurant>!
        realmRestaurants = Realm().objects(Restaurant)
        
        // trying to search within realm objects
        
//        if realmRestaurants.valueForKey("randomCountryKey") == randomCountryKey {
//            println("valueForKey: \(realmRestaurants.valueForKey(randomCountryKey!))")
//            println("same country called!")
//        }
        
//        if realm.objects(Restaurant).filter("randomCountryKey == \(randomCountryKey)") != nil {
//            println("SAME COUNTRY CALLED")
//            println(realm.objects(Restaurant).filter("randomCountryKey == \(randomCountryKey)"))
//            println()
//        }
        
        
        println(randomCountryKey)
        
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
        
        // check to see if there are results
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
        } else {
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
                self.detailsReceived(response, index: index, placeDetailsURL: placeDetailsURL)
            }
        })
    }
    
    // Google Details Results
    func detailsReceived(restaurantDetails: NSDictionary, index: Int, placeDetailsURL: String) {
        
        println("detailsReceived function called...")
        
        // create a new restaurant object to store all the info
        let restaurant = Restaurant()
        
        // create a new photoID object to store all the photo reference IDs
        let photoID = PhotoID()
        
        // store the details URL
        restaurant.placeDetailsURL = placeDetailsURL
        
        if let randomCountry = randomCountry, randomCountryKey = randomCountryKey {
            restaurant.countrySelected = randomCountry
            restaurant.countrySelectedKey = randomCountryKey
        }
        
        if let name = restaurantDetails["name"] as? String {
            restaurant.name = name
        }
        
        if let rating = restaurantDetails["rating"] as? Double {
            restaurant.rating = rating
        }
        
        if let address = restaurantDetails["formatted_address"] as? String {
            restaurant.address = address
        }
        
        if let phoneNumber = restaurantDetails["formatted_phone_number"] as? String {
            restaurant.phoneNumber = phoneNumber
        }
        
        // grab latitude and longitude
        if let geometry = restaurantDetails["geometry"] as? NSDictionary {
            if let location = geometry["location"] as? NSDictionary {
                if let latitude = location["lat"] as? Double {
                    restaurant.destLatitude = latitude
                }
                if let longitude = location["lng"] as? Double {
                    restaurant.destLongitude = longitude
                }
            }
        }
        
        // grab and display photo
        if let photos = restaurantDetails["photos"] as? [NSDictionary] {
            
            // store all photo_reference ID's in the request
            for i in 0...photos.count - 1 {
                
                let photo_dictionary = photos[i]
                
                if let photo_ref = photo_dictionary["photo_reference"] as? String {
                    
                    let photoIDObject = PhotoID()
                    photoIDObject.photoReferenceID = photo_ref
                    
                    restaurant.photoReferenceID.append(photoIDObject)
                }
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
                restaurantImageArray[index].clipsToBounds = true
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

            // setting the opacity of each image
            self.firstRestaurantImage.alpha = 0.6
            self.secondRestaurantImage.alpha = 0.6
            self.thirdRestaurantImage.alpha = 0.6

            // hide views as needed
            if self.detailsReceivedCount == 1 {
                self.secondView.hidden = true
                self.thirdView.hidden = true
            }
            
            if self.detailsReceivedCount == 2 {
                self.thirdView.hidden = true
            }
            
            for x in 0...self.detailsReceivedCount - 1 {
                
                restaurantRatingArray[x].text = "\(self.restaurantArray[x].rating)"
                restaurantNameArray[x].text = self.restaurantArray[x].name
                
                let restaurantChosen = self.restaurantArray[x]
                if restaurantChosen.photoReferenceID.count > 0 {
                    self.downloadAndDisplayImage(restaurantChosen.photoReferenceID.first!.photoReferenceID, restaurantImageArray: restaurantImageArray, index: x)
                }
                
            }
        }
    }
    
    // Retry the request if request returns nothing
    func retryRequest(){
        
        println("NO RESULTS, TRYING AGAIN")
        println()
        
        // Restart the request with a different country!
        generateRandomCountry()
        startRestaurantRequest()
        
        queriesCount++
        println("Queries Count: \(queriesCount)")
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "firstRestaurant" {
            var infoViewController = segue.destinationViewController as! InfoViewController
            infoViewController.restaurant = restaurantArray[0]
            
            infoViewController.isSegueFromRestaurantHistory = false
        }
        if segue.identifier == "secondRestaurant" {
            var infoViewController = segue.destinationViewController as! InfoViewController
            infoViewController.restaurant = restaurantArray[1]
            
            infoViewController.isSegueFromRestaurantHistory = false
        }
        if segue.identifier == "thirdRestaurant" {
            var infoViewController = segue.destinationViewController as! InfoViewController
            infoViewController.restaurant = restaurantArray[2]
            
            infoViewController.isSegueFromRestaurantHistory = false
        }
    }
    
    @IBAction func unwindToRestaurantOverviewViewController(segue: UIStoryboardSegue, sender: AnyObject!) {
        
    }

}
