//
//  ViewController.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 7/14/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
//        var currentLocation = CLLocation!
//        
//        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
//            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){
//                
//                currentLocation = locManager.location
//                
//        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error ) -> Void in
            
            if error != nil {
                println("Error: " + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as! CLPlacemark
                self.displayLocationInfo(pm)
            }
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        self.locationManager.stopUpdatingLocation()
        println(placemark.locality)
        println(placemark.postalCode)
        println(placemark.administrativeArea)
        println(placemark.country)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Network.getGooglePlaces("japan"){ (response) -> Void in
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


}
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