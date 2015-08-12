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
    
    @IBOutlet weak var firstPrice: UIButton!
    @IBOutlet weak var secondPrice: UIButton!
    @IBOutlet weak var thirdPrice: UIButton!
    
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
        }
        if segue.identifier == "liftOffToRestaurantOverview" {
            var restaurantOverview = segue.destinationViewController as! RestaurantOverviewViewController
            
            restaurantOverview.priceSelected = priceSelected
            restaurantOverview.radius = radius
            restaurantOverview.locValue = locValue
            restaurantOverview.randomCountry = randomCountry
        }
    }
    
    @IBAction func unwindToMainViewController(segue: UIStoryboardSegue, sender: AnyObject!) {

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func firstPrice(sender: UIButton) {
        priceSelected = 1
        
        sender.backgroundColor = UIColor(red:0.36, green:0.57, blue:1.00, alpha:1.0)
        sender.setTitleColor(UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0), forState: UIControlState.Normal)
        
        secondPrice.setTitleColor(UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0), forState: UIControlState.Normal)
        secondPrice.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
        
        thirdPrice.setTitleColor(UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0), forState: UIControlState.Normal)
        thirdPrice.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
    }
    @IBAction func secondPrice(sender: UIButton) {
        priceSelected = 2
        
        sender.backgroundColor = UIColor(red:0.36, green:0.57, blue:1.00, alpha:1.0)
        sender.setTitleColor(UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0), forState: UIControlState.Normal)
        
        firstPrice.setTitleColor(UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0), forState: UIControlState.Normal)
        firstPrice.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
        
        thirdPrice.setTitleColor(UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0), forState: UIControlState.Normal)
        thirdPrice.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)

    }
    @IBAction func thirdPrice(sender: UIButton) {
        priceSelected = 3
        
        sender.backgroundColor = UIColor(red:0.36, green:0.57, blue:1.00, alpha:1.0)
        sender.setTitleColor(UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0), forState: UIControlState.Normal)
        
        firstPrice.setTitleColor(UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0), forState: UIControlState.Normal)
        firstPrice.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
        
        secondPrice.setTitleColor(UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0), forState: UIControlState.Normal)
        secondPrice.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
    }
    
//    // Price segmented control
//    @IBAction func price(sender: UISegmentedControl) {
//        switch segmentedControlPrice.selectedSegmentIndex {
//        case 0:
//            priceSelected = 1
//        case 1:
//            priceSelected = 2
//        case 2:
//            priceSelected = 3
//        default:
//            priceSelected = 1
//        }
//    }
//    
//    // Radius segmented control
//    @IBAction func radiusConstraint(sender: UISegmentedControl) {
//        switch segmentedControlRadius.selectedSegmentIndex {
//        case 0:
//            radius = 800
//        case 1:
//            radius = 5000
//        case 2:
//            radius = 20000
//        default:
//            radius = 800
//        }
//    }
    
    @IBAction func goButton(sender: UIButton) {
        println("LIFTOFFFFFFF")
    }
    
    // This delegate is called, getting the location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        locValue = manager.location.coordinate
        
    }
    
}