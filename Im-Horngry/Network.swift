//
//  Network.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 7/30/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import Foundation
import CoreLocation

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
    
    class func buildURL(priceSelected: Int, radius: Int, locValue: CLLocationCoordinate2D, countryKeyword: String) -> String {
        let placeSearchString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(locValue.latitude),\(locValue.longitude)&minprice=0&maxprice=\(priceSelected)&radius=\(radius)&opennow=true&types=food&keyword=\(countryKeyword)&key=" + GOOGLE_PLACES_API_KEY
        
        return placeSearchString
    }
    
    class func getGooglePlaces(url: String, completionHandler: [NSDictionary]? -> Void) {
        
        let testPlaceSearchString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=500&types=food&name=cruise&key=" + GOOGLE_PLACES_API_KEY
        
        // Fetch the restaurant
        Network.get(url, completionHandler: { data -> Void in
            if let json = data, places = json["results"] as? [NSDictionary] {
                completionHandler(places)
            }
        }, errorHandler: nil)

    }
}