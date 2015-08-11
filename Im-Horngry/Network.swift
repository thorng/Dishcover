//
//  Network.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 7/30/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

// Requesting from Google Places API
private let GOOGLE_PLACES_API_KEY: String = "AIzaSyAKtrEj6qZ17YcjfD4SlijGbZd96ZZPkRM"
var count: Int = 0

class Network {
    
    class func get(urlString:String, completionHandler: ((NSDictionary?) -> Void)?, errorHandler:(() -> Void)?) {
        if let url = NSURL(string: urlString) {
            var request = NSMutableURLRequest(URL: url)
            var session = NSURLSession.sharedSession()
            request.HTTPMethod = "GET"
            var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                Network.handleRESTResponse(completionHandler, data: data, response: response, error: error,  errorHandler: errorHandler)
            })
            task.resume()
        }
    }
    
    class func handleRESTResponse(completionHandler: ((NSDictionary?) -> Void)?, data:NSData?, response:NSURLResponse?, error: NSError?, errorHandler:(() -> Void)?){
        
        var err: NSError?
        var json = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves, error: &err) as? NSDictionary
        
        count++
        
        if let parseJSON = json {
            println(count)
            completionHandler?(parseJSON)
        } else {
            println(count)
            println("Very bad error")
            errorHandler?()
        }
    }
    
    // MARK: Google Search Request
    class func buildSearchURL(priceSelected: Int, radius: Int, locValue: CLLocationCoordinate2D, countryKeyword: String) -> String {
        let placeSearchString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(locValue.latitude),\(locValue.longitude)&minprice=0&maxprice=\(priceSelected)&radius=\(radius)&opennow=true&types=food&keyword=\(countryKeyword)&key=" + GOOGLE_PLACES_API_KEY
        
        return placeSearchString
    }
    
    class func getGooglePlaces(url: String, completionHandler: [NSDictionary]? -> Void) {
        
        // Fetch the restaurant
        Network.get(url, completionHandler: { data -> Void in
            if let json = data, places = json["results"] as? [NSDictionary] {
                completionHandler(places)
            } else {
                println("Something happened with Network 'get' request. Maybe bad internet connection")
                completionHandler(nil)
            }
        }, errorHandler: nil)
    }
    
    // MARK: Google Details Requet
    class func buildDetailsURL(referenceID: String) -> String {
        let placeDetailsString = "https://maps.googleapis.com/maps/api/place/details/json?reference=" + referenceID + "&key=" + GOOGLE_PLACES_API_KEY
        
        return placeDetailsString
    }
    
    class func getGooglePlacesDetails(url: String, completionHandler: NSDictionary? -> Void) {
        
        // Fetch the restaurant
        Network.get(url, completionHandler: { data -> Void in
            if let json = data, places = json["result"] as? NSDictionary {
                completionHandler(places)
            }
        }, errorHandler: nil)
    }
    
    
}