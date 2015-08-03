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
        if segue.identifier == "RestaurantControllerSegue" {
            var infoViewController = segue.destinationViewController as! InfoViewController
            
            // variables being passed into Network
            infoViewController.priceSelected = priceSelected
            infoViewController.radius = radius
            infoViewController.locValue = locValue
            infoViewController.randomCountry = randomCountry
        }
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
            priceSelected = 1
        case 1:
            priceSelected = 2
        case 2:
            priceSelected = 3
        default:
            priceSelected = 1
        }
    }
    
    // Radius segmented control
    @IBAction func radiusConstraint(sender: UISegmentedControl) {
        switch segmentedControlRadius.selectedSegmentIndex {
        case 0:
            radius = 800
        case 1:
            radius = 5000
        case 2:
            radius = 20000
        default:
            radius = 800
        }
    }
    
    @IBAction func goButton(sender: UIButton) {
        println("LIFTOFFFFFFF")
    }
    
    // This delegate is called, getting the location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        locValue = manager.location.coordinate
        
    }
    
}