//
//  ViewController.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 7/14/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift

var locValue: CLLocationCoordinate2D? // Latitude & Longitude value
var randomCountry: String = "" // Random Value from countryDict

var countryDict = [String: String]() // Country & Adjectival dictionary

let selectedChoiceBGColor:UIColor = UIColor(red:0.36, green:0.57, blue:1.00, alpha:1.0)

let selectedChoiceTextColor:UIColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)

let unselectedChoiceBGColor:UIColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)

let unselectedChoiceTextColor:UIColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)

let enabledTakeOffBGColor:UIColor = UIColor(red:0.13, green:0.75, blue:0.39, alpha:1.0)

let enabledTakeOffTextColor:UIColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)

var disabledTakeOffBGColor:UIColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)

var disabledTakeOffTextColor:UIColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    var restaurants: Results<Restaurant>!
    
    // price constraint
    var priceSelected = 0 {
        didSet{
            if priceSelected != 0 && radius != 0 {
                takeOffButton.enabled = true
                takeOffButton.displayTakeOffEnabled()
            } else {
                takeOffButton.enabled = false
                takeOffButton.displayTakeOffDisabled()
            }
        }
    }
    
    // radius constraint
    var radius = 0 {
        didSet{
            if priceSelected != 0 && radius != 0 {
                takeOffButton.enabled = true
                takeOffButton.displayTakeOffEnabled()
            } else {
                takeOffButton.enabled = false
                takeOffButton.displayTakeOffDisabled()
            }
        }
    }
    
    var isFromOverviewController = false
    
    @IBOutlet weak var firstPrice: UIButton!
    @IBOutlet weak var secondPrice: UIButton!
    @IBOutlet weak var thirdPrice: UIButton!
    
    @IBOutlet weak var walkButton: UIButton!
    @IBOutlet weak var bikeButton: UIButton!
    @IBOutlet weak var carButton: UIButton!
    
    @IBOutlet weak var takeOffButton: UIButton!
    
    @IBOutlet weak var countryStatisticsLabel: UILabel!
    @IBOutlet weak var percentageStatisticsLabel: UILabel!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var historyButton: UIBarButtonItem!
    
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
            
            restaurantOverview.isFromMainViewcontroller = true
            
            restaurantOverview.priceSelected = priceSelected
            restaurantOverview.radius = radius
            restaurantOverview.locValue = locValue
            restaurantOverview.randomCountry = randomCountry
            
            takeOffButton.enabled = false
            isFromOverviewController = true
        }
    }
    
    @IBAction func unwindToMainViewController(segue: UIStoryboardSegue, sender: AnyObject!) {
        historyButton.enabled = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // array of all buttons
        let buttonChoicesArray: [UIButton] = [firstPrice, secondPrice, thirdPrice, walkButton, bikeButton, carButton]
        
        // disable Take Off button if no buttons are pressed
        if radius == 0 || priceSelected == 0 {
            takeOffButton.titleLabel?.textColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
            takeOffButton.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
            takeOffButton.enabled = false
        }
        
//        if locValue == nil {
//            takeOffButton.titleLabel?.adjustsFontSizeToFitWidth = true
//            takeOffButton.titleLabel?.text = "NO LOCATION"
//        }
        
        // fetching how many countires user has been to
        let realm = Realm()
        restaurants = Realm().objects(Restaurant)
        let restaurantsCount = restaurants.count
        
        var percentageOfTheWorld: Double = (Double(restaurants.count)/196) * 100
        var percentageOfTheWorldTruncate: Double = Double(round(100*percentageOfTheWorld)/100)
        
        if restaurants.count == 1 {
            countryStatisticsLabel.text = "You've been to \(restaurantsCount) country."
        } else {
            countryStatisticsLabel.text = "You've been to \(restaurantsCount) countries."
        }
        
        percentageStatisticsLabel.text = "\(percentageOfTheWorldTruncate)%"
        
        //iterate through all the buttons and deselect them
        for i in 0...buttonChoicesArray.count - 1 {
            buttonChoicesArray[i].selected = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // array of all buttons
        let buttonChoicesArray: [UIButton] = [firstPrice, secondPrice, thirdPrice, walkButton, bikeButton, carButton]
        
        for i in 0...5 {
            buttonChoicesArray[i].selected = false
            buttonChoicesArray[i].displayUnselected()
        }
        
        takeOffButton.displayTakeOffDisabled()
        
        radius = 0
        priceSelected = 0
        
        // frosted glass effect on background image
        
//        var ciimage :CIImage = CIImage(image: backgroundImage)
//        
//        var filter : CIFilter = CIFilter(name:"CIGaussianBlur")
//        
//        filter.setDefaults()
//        
//        filter.setValue(ciimage, forKey: kCIInputImageKey)
//        
//        filter.setValue(30, forKey: kCIInputRadiusKey)
//        
//        var outputImage : CIImage = filter.outputImage;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIButton Customization
    
    @IBAction func firstPrice(sender: UIButton) {
        priceSelected = 1
        
        sender.displaySelected()
        secondPrice.displayUnselected()
        thirdPrice.displayUnselected()
        
        sender.selected = true
    }
    
    @IBAction func secondPrice(sender: UIButton) {
        priceSelected = 2
        
        sender.displaySelected()
        
        firstPrice.displayUnselected()
        
        thirdPrice.displayUnselected()
        
        sender.selected = true
    }
    
    @IBAction func thirdPrice(sender: UIButton) {
        priceSelected = 3
        
        sender.displaySelected()
        
        firstPrice.displayUnselected()
        
        secondPrice.displayUnselected()
        
        sender.selected = true
    }
    
    @IBAction func walkButton(sender: UIButton) {
        radius = 800
        
        sender.displaySelected()
        
        bikeButton.displayUnselected()
        
        carButton.displayUnselected()
        
        sender.selected = true
    }
    
    @IBAction func bikeButton(sender: UIButton) {
        radius = 5000
        
        sender.displaySelected()
        
        walkButton.displayUnselected()
        
        carButton.displayUnselected()
        
        sender.selected = true
    }
    
    @IBAction func carButton(sender: UIButton) {
        radius = 30000
        
        sender.displaySelected()
        
        walkButton.displayUnselected()
        
        bikeButton.displayUnselected()
        
        sender.selected = true
    }
    
    @IBAction func goButton(sender: UIButton) {
        //historyButton.enabled = false
    }
    
    // This delegate is called, getting the location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        locValue = manager.location.coordinate
        
    }
    
}

extension UIButton {
    func displaySelected() {
        backgroundColor = selectedChoiceBGColor
        setTitleColor(selectedChoiceTextColor, forState: UIControlState.Normal)
        tintColor = UIColor.whiteColor()
    }
    
//    func displaySelectedTravel() {
//        backgroundColor = selectedChoiceBGColor
//        tintColor = selectedChoiceTextColor
//    }
    
    func displayUnselected() {
        backgroundColor = unselectedChoiceBGColor
        setTitleColor(unselectedChoiceTextColor, forState: UIControlState.Normal)
        tintColor = UIColor.blackColor()
    }

    func displayTakeOffEnabled() {
        backgroundColor = enabledTakeOffBGColor
        setTitleColor(enabledTakeOffTextColor, forState: .Normal)
    }
    
    func displayTakeOffDisabled() {
        backgroundColor = disabledTakeOffBGColor
        setTitleColor(disabledTakeOffTextColor, forState: .Normal)
    }
}