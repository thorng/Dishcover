//
//  ViewController.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 7/14/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftCSV

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize CoreLocation and request permission
        self.locManager.requestWhenInUseAuthorization()
        
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.distanceFilter = kCLDistanceFilterNone
        locManager.startUpdatingLocation() // calls locationManager delegate
        
//        //CSV Parser
//        if let url = NSURL(string: "countries_of_the_world.csv" ) {
//            var error: NSErrorPointer = nil
//            if let csv = CSV(contentsOfURL: url, error: error) {
//                // Rows
//                let rows = csv.rows
//                let headers = csv.headers  //=> ["country", "adjectival"]
//                
//                // Columns
//                let columns = csv.columns
//                let names = csv.columns["country"]
//                let ages = csv.columns["adjectival"]
//                
//                println(rows)
//            }
//        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Network.getGooglePlaces("arizona"){ (response) -> Void in
            if let places = response {
                for place in places {
                    println(place["name"])
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This delegate is called, getting the location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue: CLLocationCoordinate2D = manager.location.coordinate
        
        println("locations = \(locValue.latitude) \(locValue.longitude)")
        
        let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
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
        Network.get("https://maps.googleapis.com/maps/api/place/textsearch/json?query=restaurants+in+" + place + "&key=" + GOOGLE_PLACES_API_KEY, completionHandler: { (data) -> Void in
            if let json = data, places = json["results"] as? [NSDictionary] {
                completionHandler?(places)
            }
            }, errorHandler: nil)
    }
}