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
var randomVal: String = "" // Random Value from countryDict
var price = 1
var radius = 500

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locManager = CLLocationManager() // Location Variable
    var countryDict = [String: String]() // Country & Adjectival dictionary
    
    
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
        let index: Int = Int(arc4random_uniform(UInt32(countryDict.count)))
        randomVal = Array(countryDict.values)[index]
        
        println(randomVal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // setting the price variable
    @IBAction func price1(sender: UIButton) {
        price = 1
        println("you chose $10")
    }
    
    @IBAction func price2(sender: UIButton) {
        price = 2
        println("you chose $20")

    }
    
    @IBAction func price3(sender: UIButton) {
        price = 3
        println("you chose $30")

    }
    
    // setting the radius variable
    @IBAction func feet(sender: UIButton) {
        radius = 800
        println("you chose 800m")

    }
    
    @IBAction func bike(sender: UIButton) {
        radius = 5000
        println("you chose 5000m")

    }
    
    @IBAction func car(sender: UIButton) {
        radius = 20000
        println("you chose 20000m")

    }
    
    @IBAction func goButton(sender: UIButton) {
        println("LIFTOFFFFFFF")
        if locValue != nil {
            Network.getGooglePlaces(randomVal){ (response) -> Void in
                if let places = response {
                    for place in places {
                        println(place["name"])
                    }
                }
            }
        }
        else {
            println("sorry, location not found")
        }
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
        
        let substring1 = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(locValue!.latitude),\(locValue!.longitude)&minprice=0&maxprice=\(price)&radius=\(radius)&opennow=true&types=food&keyword=\(randomVal)&key=" + GOOGLE_PLACES_API_KEY
        let substring2 = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=500&types=food&name=cruise&key=" + GOOGLE_PLACES_API_KEY
        Network.get(substring1, completionHandler: { (data) -> Void in
                if let json = data, places = json["results"] as? [NSDictionary] {
                    completionHandler?(places)
                }
            }, errorHandler: nil)
    }
}