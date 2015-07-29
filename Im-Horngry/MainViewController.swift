//
//  ViewController.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 7/14/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import UIKit
import CoreLocation

var locValue: CLLocationCoordinate2D? // Latitude & Longitude value
var googleSearchWebAddress: String?
var randomCountry: String = "" // Random Value from countryDict
var priceSelected = 0 // price constraint
var radius = 0 // radius constraint

var selectedCountry: String = ""

var countryDict = [String: String]() // Country & Adjectival dictionary

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var segmentedControlRadius: UISegmentedControl!
    @IBOutlet weak var segmentedControlPrice: UISegmentedControl!
    
    let locManager = CLLocationManager() // Location Variable
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize CoreLocation and request permission
        self.locManager.requestWhenInUseAuthorization()
        
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.distanceFilter = kCLDistanceFilterNone
        locManager.startUpdatingLocation() // calls locationManager delegate
        
        // Creates dictionary of Countries and Adjectivals
        parseTxtToDictionary()
        
        // Randomly generate dict value
        generateRandomCountry()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        var passingObject = segue.destinationViewController as! InfoViewController
        passingObject.selectedCountry = selectedCountry
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func price(sender: UISegmentedControl) {
        switch segmentedControlPrice.selectedSegmentIndex {
        case 0:
            println("first segmented control selected")
            priceSelected = 1
        case 1:
            println("2nd segmented control selected")
            priceSelected = 2
        case 2:
            println("3rd segmented control selected")
            priceSelected = 3
        default:
            break
        }
    }
    
    @IBAction func radiusConstraint(sender: UISegmentedControl) {
        switch segmentedControlRadius.selectedSegmentIndex {
        case 0:
            println("800m selected")
            radius = 800
        case 1:
            println("5000m selected")
            radius = 5000
        case 2:
            println("20000m selected")
            radius = 20000
        default:
            break
        }
    }
    
    @IBAction func goButton(sender: UIButton) {
        println("LIFTOFFFFFFF")
        
        // sends API request and returns a restaurant
        returnRestaurant()
        
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
    }
    
    func returnRestaurant() {
        if locValue != nil {
            Network.getGooglePlaces(randomCountry){ (response) -> Void in
                if let places = response {
                    for place in places {
                        println(place["name"])
                        selectedCountry = (place["name"] as? String)!
                    }
                }
            }
        }
        else {
            println("sorry, location not found")
        }
    }
    
    // This delegate is called, getting the location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        locValue = manager.location.coordinate
        
    }
    
}

// Requesting from Google Places API
private let GOOGLE_PLACES_API_KEY:String = "AIzaSyAKtrEj6qZ17YcjfD4SlijGbZd96ZZPkRM"

class Network {
    class func get(urlString:String, completionHandler: ((NSDictionary?) -> Void)?, errorHandler:(() -> Void)?) {
        var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            Network.handleRESTResponse(completionHandler, data: data, response: response, error: error,  errorHandler: errorHandler)
        })
        task.resume()
    }
    
    class func handleRESTResponse(completionHandler: ((NSDictionary?) -> Void)?, data:NSData?, response:NSURLResponse?, error: NSError?, errorHandler:(() -> Void)?){
        var err: NSError?
        var json = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves, error: &err) as? NSDictionary
        if let parseJSON = json {
            completionHandler?(parseJSON)
        }
        else {
            errorHandler?()
        }
    }
    
    class func getGooglePlaces(place:String, completionHandler: (([NSDictionary]?) -> Void)?) {
        
        let substring1 = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(locValue!.latitude),\(locValue!.longitude)&minprice=0&maxprice=\(priceSelected)&radius=\(radius)&opennow=true&types=food&keyword=\(randomCountry)&key=" + GOOGLE_PLACES_API_KEY
        let substring2 = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=500&types=food&name=cruise&key=" + GOOGLE_PLACES_API_KEY
        Network.get(substring1, completionHandler: { (data) -> Void in
                if let json = data, places = json["results"] as? [NSDictionary] {
                    completionHandler?(places)
                }
                if let json = data, statuses = json["status"] as? [NSDictionary] {
                    completionHandler?(statuses)
                }
            }, errorHandler: nil)
    }
}