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
    
    // boolean variables
    
    var isFromMainViewcontroller = false
    
    // === INPUT VARIABLES ===
    
    var randomCountryKey: String? // random country key
    var randomCountry: String? // random country adjectival
    var locValue: CLLocationCoordinate2D? // Latitude & Longitude value
    var priceSelected: Int? // price constraint
    var radius: Int? // radius constraint
    
    var isSegueFromRestaurantHistory = false
    
    var displayRestaurantCount = 0
    
    // ==== OUTPUT VARIABLES ===
    var restaurantArray: [Restaurant] = []
    var contentMode: UIViewContentMode?
    var image: UIImage?
    
    // === DEBUGGING VARIABLES ===
    var queriesCount: Int = 0 // counting the number of requests
    var detailsReceivedCount: Int = 0
    var maxResults = 2
    
    var startLoadingTimeInterval:NSTimeInterval!
    
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
    
    @IBOutlet weak var firstHeartImage: UIImageView!
    @IBOutlet weak var secondHeartImage: UIImageView!
    @IBOutlet weak var thirdHeartImage: UIImageView!
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    
    @IBOutlet weak var countrySelectedTitle: UINavigationItem!
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var flyingToLabel: UILabel!
    @IBOutlet weak var foundXRestaurantsLabel: UILabel!
    
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
        
        if isFromMainViewcontroller == true {
            startLoadingTimeInterval = NSDate().timeIntervalSince1970
            activityIndicator.startAnimating()
            loadingView.hidden = false
            activityIndicator.hidden = false
            
            firstRestaurantButton.enabled = false
            secondRestaurantButton.enabled = false
            thirdRestaurantButton.enabled = false
        } else {
            firstRestaurantButton.enabled = true
            secondRestaurantButton.enabled = true
            thirdRestaurantButton.enabled = true
        }
        
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
        
        
        // Check to see if country has been eaten at before!
        let realm = Realm()
        
        let predicate = NSPredicate(format: "countrySelectedKey = %@", randomCountryKey!)
        var results = realm.objects(Restaurant).filter(predicate)
        
        if results.count > 0 {
            println("same country called!")
            generateRandomCountry()
        }
        
        // update loading screen text
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            println("flyingToLabel text called")
            self.flyingToLabel.text = "Finding restaurants at \(self.randomCountryKey!)..."
        }
        
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
                
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.flyingToLabel.text = "You're flying to \(self.randomCountryKey!) today."
                    
                    if self.maxResults + 1 == 1 {
                        self.foundXRestaurantsLabel.text = "I found a restaurant near you"
                    } else {
                        self.foundXRestaurantsLabel.text = "I found \(self.maxResults+1) restaurants near you"
                    }
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
        
        if let googleURL = restaurantDetails["url"] as? String {
            restaurant.googleURL = googleURL
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
        
        var viewArray: [UIView] = [self.firstView, self.secondView, self.thirdView]
        var restaurantImageArray: [UIImageView] = [self.firstRestaurantImage, self.secondRestaurantImage, self.thirdRestaurantImage]
        var restaurantNameArray: [UILabel] = [self.firstRestaurantNameLabel, self.secondRestaurantNameLabel, self.thirdRestaurantNameLabel]
        var restaurantButtonArray: [UIButton] = [self.firstRestaurantButton, self.secondRestaurantButton, self.thirdRestaurantButton]
        var restaurantRatingArray: [UILabel] = [self.firstRestaurantRatingLabel, self.secondRestaurantRatingLabel, self.thirdRestaurantRatingLabel]
        var heartImageArray: [UIImageView] = [self.firstHeartImage, self.secondHeartImage, self.thirdHeartImage]
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.countrySelectedTitle.title = self.randomCountryKey

            // apply gradient on each image
            var gradientMaskLayer:CAGradientLayer = CAGradientLayer()
            
            // setting the opacity of each image
//            self.firstRestaurantImage.alpha = 0.6
//            self.secondRestaurantImage.alpha = 0.6
//            self.thirdRestaurantImage.alpha = 0.6

            // hide views as needed
            if self.detailsReceivedCount == 1 {
                self.secondView.hidden = true
                self.thirdView.hidden = true
            }
            
            if self.detailsReceivedCount == 2 {
                self.thirdView.hidden = true
            }
            
            for x in 0...self.detailsReceivedCount - 1 {
                
                // Show no rating if rating = 0
                if self.restaurantArray[x].rating == 0 {
                    restaurantRatingArray[x].text = ""
                    restaurantRatingArray[x].hidden = true
                    heartImageArray[x].hidden = true
                } else {
                    restaurantRatingArray[x].text = "\(self.restaurantArray[x].rating)"
                    
                    // adding a heart behind the rating
                    let myImage = UIImage(named: "heart")
//                    let myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
//                    myImageView.image = myImage
//                    restaurantRatingArray[x].addSubview(myImageView)
//                    restaurantRatingArray[x].sendSubviewToBack(myImageView)
                }
                
                restaurantNameArray[x].text = self.restaurantArray[x].name
                
                let restaurantChosen = self.restaurantArray[x]
                
                if restaurantChosen.photoReferenceID.count == 0 {
                    println("\n NO IMAGES \n")
                    restaurantImageArray[x].image = UIImage(named: "world_map")
                    restaurantImageArray[x].contentMode = .ScaleAspectFill
                }
                
                if restaurantChosen.photoReferenceID.count > 0 {
                    
                    restaurantImageArray[x].alpha = 0.6
                    
                    // apply alpha gradient
//                    gradientMaskLayer.frame = restaurantImageArray[x].bounds
//                    gradientMaskLayer.colors = [UIColor.clearColor().CGColor!, UIColor.blackColor().CGColor!]
//                    gradientMaskLayer.locations = [0.05, 0.0]
//                    restaurantImageArray[x].layer.mask = gradientMaskLayer
                    
                    self.downloadAndDisplayImage(restaurantChosen.photoReferenceID.first!.photoReferenceID, restaurantImageArray: restaurantImageArray, index: x)
                }
                
                if self.detailsReceivedCount == 1 {
                    self.performSegueWithIdentifier("firstRestaurant", sender: self)
                }
                
            }
            
            // have loading screen display for at least 5 seconds before showing results
            let currentTimeInterval:NSTimeInterval = NSDate().timeIntervalSince1970
            
            let loadingTime = currentTimeInterval - self.startLoadingTimeInterval
            
            if loadingTime < 5.0 {
                let dispatchTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,
                    Int64((5.0 - loadingTime) * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue()) { () -> Void in
                     self.displayFinishedLoading()
                }
            } else {
                self.displayFinishedLoading()
            }
            
        }
    }
    
    func displayFinishedLoading(){
        self.activityIndicator.stopAnimating()
        self.loadingView.hidden = true
        self.activityIndicator.hidden = true
        
        self.firstRestaurantButton.enabled = true
        self.secondRestaurantButton.enabled = true
        self.thirdRestaurantButton.enabled = true
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
            
            isFromMainViewcontroller = false
            
            firstRestaurantButton.enabled = false
            secondRestaurantButton.enabled = false
            thirdRestaurantButton.enabled = false
            
            var infoViewController = segue.destinationViewController as! InfoViewController
            infoViewController.restaurant = restaurantArray[0]
            
            infoViewController.isSegueFromRestaurantHistory = false
        }
        if segue.identifier == "secondRestaurant" {
            
            isFromMainViewcontroller = false
            
            firstRestaurantButton.enabled = false
            secondRestaurantButton.enabled = false
            thirdRestaurantButton.enabled = false

            var infoViewController = segue.destinationViewController as! InfoViewController
            infoViewController.restaurant = restaurantArray[1]
            
            infoViewController.isSegueFromRestaurantHistory = false
        }
        if segue.identifier == "thirdRestaurant" {
            
            isFromMainViewcontroller = false
            
            firstRestaurantButton.enabled = false
            secondRestaurantButton.enabled = false
            thirdRestaurantButton.enabled = false

            var infoViewController = segue.destinationViewController as! InfoViewController
            infoViewController.restaurant = restaurantArray[2]
            
            infoViewController.isSegueFromRestaurantHistory = false
        }
    }
    
    @IBAction func unwindToRestaurantOverviewViewController(segue: UIStoryboardSegue, sender: AnyObject!) {

    }

}
