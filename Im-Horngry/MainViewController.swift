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
    
    @IBOutlet weak var firstPrice: UIButton!
    @IBOutlet weak var secondPrice: UIButton!
    @IBOutlet weak var thirdPrice: UIButton!
    
    @IBOutlet weak var walkButton: UIButton!
    @IBOutlet weak var bikeButton: UIButton!
    @IBOutlet weak var carButton: UIButton!
    
    let locManager = CLLocationManager() // Location Variable
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize CoreLocation and request permission
        self.locManager.requestWhenInUseAuthorization()
        
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.distanceFilter = kCLDistanceFilterNone
        locManager.startUpdatingLocation() // calls locationManager delegate
        
        firstPrice.layer.borderWidth = 1
        secondPrice.layer.borderWidth = 1
        thirdPrice.layer.borderWidth = 1
        
        walkButton.layer.borderWidth = 1
        bikeButton.layer.borderWidth = 1
        carButton.layer.borderWidth = 1
        
        firstPrice.layer.borderColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0).CGColor
        secondPrice.layer.borderColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0).CGColor
        thirdPrice.layer.borderColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0).CGColor

        walkButton.layer.borderColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0).CGColor
        bikeButton.layer.borderColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0).CGColor
        carButton.layer.borderColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0).CGColor
        
        firstPrice.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:1.0).CGColor

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
    
    // MARK: UIButton Customization
    
    @IBAction func firstPrice(sender: UIButton) {
        priceSelected = 1
        
        sender.backgroundColor = UIColor(red:0.36, green:0.57, blue:1.00, alpha:1.0)
        sender.setTitleColor(UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0), forState: UIControlState.Normal)
        
        sender.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:1.0).CGColor
        sender.layer.shadowRadius = 10
        
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
    
    @IBAction func walkButton(sender: UIButton) {
        radius = 800
        
        sender.backgroundColor = UIColor(red:0.36, green:0.57, blue:1.00, alpha:1.0)
        sender.setTitleColor(UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0), forState: UIControlState.Normal)
        
        bikeButton.setTitleColor(UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0), forState: UIControlState.Normal)
        bikeButton.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
        
        carButton.setTitleColor(UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0), forState: UIControlState.Normal)
        carButton.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
        
    }
    
    @IBAction func bikeButton(sender: UIButton) {
        radius = 5000
        
        sender.backgroundColor = UIColor(red:0.36, green:0.57, blue:1.00, alpha:1.0)
        sender.setTitleColor(UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0), forState: UIControlState.Normal)
        
        walkButton.setTitleColor(UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0), forState: UIControlState.Normal)
        walkButton.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
        
        carButton.setTitleColor(UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0), forState: UIControlState.Normal)
        carButton.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
    }
    
    @IBAction func carButton(sender: UIButton) {
        radius = 30000
        
        sender.backgroundColor = UIColor(red:0.36, green:0.57, blue:1.00, alpha:1.0)
        sender.setTitleColor(UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0), forState: UIControlState.Normal)
        
        walkButton.setTitleColor(UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0), forState: UIControlState.Normal)
        walkButton.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
        
        bikeButton.setTitleColor(UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0), forState: UIControlState.Normal)
        bikeButton.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
    }
    
    @IBAction func goButton(sender: UIButton) {
        println("LIFTOFFFFFFF")
    }
    
    // This delegate is called, getting the location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        locValue = manager.location.coordinate
        
    }
    
}