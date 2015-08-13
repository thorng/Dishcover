//
//  InfoViewController.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 7/25/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import RealmSwift

class InfoViewController: UIViewController {
    
    var restaurant = Restaurant()
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    var paginatedScrollView: PaginatedScrollView?
    
    //@IBOutlet weak var paginatedScrollView: PaginatedScrollView!
    
    var placeDetailsURL: String = ""
    
    var address: String = ""
    var rating: Double = 0.0
    var country: String = ""
    var restaurantName: String = ""
    
    var photoReferenceID: [String] = []
    var restaurantPhotos: [UIImage] = []
    
    var priceSelected: Int? // price constraint
    var radius: Int? // radius constraint
    
    var queriesCount: Int = 0 // counting the number of requests
    var isSegueFromRestaurantHistory = false
    
    //google maps
    var shouldUseGoogleMaps: Bool!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var eatenButton: UIButton!
    
    @IBOutlet weak var countryTitle: UINavigationItem!
    
    @IBOutlet weak var directionsButton: UIBarButtonItem!
    
    @IBOutlet weak var imagesContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shouldUseGoogleMaps = (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!))
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        

        // hide eaten button if accessing from History
        if isSegueFromRestaurantHistory == true {
            eatenButton.hidden = true
        }


    }
    
    func downloadArrayOfPhotos() {
        
        if restaurant.photoReferenceID.count > 0 {
            
            for i in 0...restaurant.photoReferenceID.count - 1 {
                photoReferenceID.append(restaurant.photoReferenceID[i].photoReferenceID)
            }
            
            var maxImages = photoReferenceID.count - 1
            var imageIndex: NSInteger = 0
            
            // downloading the photos
            for index in 0...photoReferenceID.count - 1 {
                let realm = Realm()
                downloadImage(photoReferenceID[index])
            }
            
            paginatedScrollViewSetup()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // if accessing from history, get photos and display. else, just display the photos
        placeDetailsURL = restaurant.placeDetailsURL
        if restaurant.photoReferenceID.count == 0 {
            println("placeDetailsURL: \(placeDetailsURL)")
            
            Network.getGooglePlacesDetails(placeDetailsURL, completionHandler: { response -> Void in
                if let response = response {
                    self.detailsReceived(response)
                }
            })
            
        } else {
            println("else function called")
            downloadArrayOfPhotos()
        }
        
        countryTitle.title = restaurant.name
        
        restaurantLabel.text = restaurant.name
        ratingLabel.text = "\(restaurant.rating)"
        addressLabel.text = restaurant.address
        countryLabel.text = restaurant.countrySelectedKey
        
    }
    
    // MARK: Paginated Scroll View Setup
    func paginatedScrollViewSetup() {
        
        let newFrame = CGRect(x: 0, y: 0, width: imagesContainerView.frame.width, height: imagesContainerView.frame.height)
        paginatedScrollView = PaginatedScrollView(frame: newFrame)
        paginatedScrollView!.canCancelContentTouches = false
        mainScrollView!.delaysContentTouches = true
//        
//        self.view.addSubview(paginatedScrollView!) // add to the subview
//        
        self.view.layoutIfNeeded()
        println(self.paginatedScrollView?.frame)
        self.paginatedScrollView?.images = restaurantPhotos
        
        //self.addSubview(mainScrollView)
        
//        paginatedScrollView!.frame = CGRectMake(0, 0, mainScrollView.contentSize.width, mainScrollView.contentSize.height)
      
//      mainScrollView.addSubview(paginatedScrollView!)
       // paginatedScrollView!.addSubview(mainScrollView)

        
        imagesContainerView.addSubview(paginatedScrollView!)
//        self.view.addSubview(buttonOne)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    
    func detailsReceived(restaurantDetails: NSDictionary) {
        
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            
            // grab and display photo
            if let photos = restaurantDetails["photos"] as? [NSDictionary] {
                
                // store all photo_reference ID's in the request
                for i in 0...photos.count - 1 {
                    
                    let photo_dictionary = photos[i]
                    
                    if let photo_ref = photo_dictionary["photo_reference"] as? String {
                        
                        let realm = Realm()
                        let photoIDObject = PhotoID()
                        
                        photoIDObject.photoReferenceID = photo_ref
                        
                        // Create array of photoReferenceID's
                        realm.write {
                            self.restaurant.photoReferenceID.append(photoIDObject)
                        }
                    }
                }
            }
            
            // Download photos using above array of photoReferenceID's
            self.downloadArrayOfPhotos()

        }
    }
    
    func downloadImage(photoReference: String) {
        if let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" + photoReference + "&key=AIzaSyAKtrEj6qZ17YcjfD4SlijGbZd96ZZPkRM") {
            if let data = NSData(contentsOfURL: url) {
                restaurantPhotos.append(UIImage(data: data)!)
            }
        }
    }
    
    // adds restaurant name to Realm
    func addObjectToRealm() {
        let realm = Realm()

        let realmRestaurant = Restaurant(value: ["placeDetailsURL": self.restaurant.placeDetailsURL, "name": self.restaurant.name, "countrySelected": self.restaurant.countrySelected, "countrySelectedKey": self.restaurant.countrySelectedKey, "address": self.restaurant.address, "phoneNumber": self.restaurant.phoneNumber, "rating": self.restaurant.rating])
        
        realm.write {
            realm.add(realmRestaurant)
        }
    }
    
    @IBAction func startRouting(sender: AnyObject) {
        
        var latitude = restaurant.destLatitude
        var longitude = restaurant.destLongitude
        
        if shouldUseGoogleMaps == true {
            let url = NSURL(string: "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)")
            UIApplication.sharedApplication().openURL(url!)
        }
        else {
            let url = NSURL(string: "http://maps.apple.com/maps?saddr=Current%20Location&daddr=\(latitude),\(longitude)")
            UIApplication.sharedApplication().openURL(url!)
        }
        
    }
    
    @IBAction func eatenPressed(sender: UIButton) {
        let finishedSavingViewNib = UINib(nibName: "FinishedSavingView", bundle: nil)
        let finishedSavingView:UIView = finishedSavingViewNib.instantiateWithOwner(nil, options: nil).last as! UIView
        
        finishedSavingView.frame = self.view.frame
        
        self.view.addSubview(finishedSavingView)
        let dispatchTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,
            Int64(3 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue()) { () -> Void in
            self.performSegueWithIdentifier("exitFromInfoController", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        println("MEMORY WARNING")
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "exitFromInfoController" {
            self.addObjectToRealm()
        }
        
    }

}