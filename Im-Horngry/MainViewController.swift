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
var randomCountry: String = "" // Random Value from countryDict
var priceSelected = 1 // price constraint
var radius = 800 // radius constraint

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
        

        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        var network = segue.destinationViewController as! Network

        // variables being passed into Network
        network.priceSelected = priceSelected
        network.radius = radius
        network.locValue = locValue
        network.countryDict = countryDict
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Price segmented control
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
            priceSelected = 1
        }
    }
    
    // Radius segmented control
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
            radius = 800
        }
    }
    
    @IBAction func goButton(sender: UIButton) {
        println("LIFTOFFFFFFF")
        
        // sends API request and returns a restaurant
//        returnRestaurant()
        
    }
    
//    func returnRestaurant() {
//        if locValue != nil {
//            Network.getGooglePlaces(randomCountry){ (response) -> Void in
//                if let places = response {
//                    for place in places {
//                        println(place["name"])
//                        selectedCountry = place["name"] as! String
//                    }
//                }
//            }
//        }
//        else {
//            println("sorry, location not found")
//        }
//    }
    
    // This delegate is called, getting the location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        locValue = manager.location.coordinate
        
    }
    
}