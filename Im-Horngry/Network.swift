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
private let GOOGLE_PLACES_API_KEY:String = "AIzaSyAKtrEj6qZ17YcjfD4SlijGbZd96ZZPkRM"

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
        
        // Fetch the restaurant
        Network.get(url, completionHandler: { data -> Void in
            if let json = data, places = json["results"] as? [NSDictionary] {
                completionHandler(places)
            }
        }, errorHandler: nil)

    }
    
//    class func getGooglePlacesDetails(url: String, completionHandler: [NSDictionary]? -> Void) {
//        
//        let testPlaceSearchString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=CnRtAAAATLZNl354RwP_9UKbQ_5Psy40texXePv4oAlgP4qNEkdIrkyse7rPXYGd9D_Uj1rVsQdWT4oRz4QrYAJNpFX7rzqqMlZw2h2E2y5IKMUZ7ouD_SlcHxYq1yL4KbKUv3qtWgTK0A6QbGh87GB3sscrHRIQiG2RrmU_jF4tENr9wGS_YxoUSSDrYjWmrNfeEHSGSc3FyhNLlBU&key=" + GOOGLE_PLACES_API_KEY
//        
//        // Fetch the restaurant
//        Network.get(testPlaceSearchString, completionHandler: { data -> Void in
//            if let json = data, places = json["results"] as? [NSDictionary] {
//                completionHandler(places)
//            }
//            }, errorHandler: nil)
//        
//    }
    
    
}