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
    
    var placeDetailsURL: String = ""
    
    var address: String = ""
    var rating: Double = 0.0
    var country: String = ""
    var restaurantName: String = ""
    
    var photoReferenceID: [String] = []
    
    var priceSelected: Int? // price constraint
    var radius: Int? // radius constraint
    
    var queriesCount: Int = 0 // counting the number of requests
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var images: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        placeDetailsURL = restaurant.placeDetailsURL

        restaurantLabel.text = restaurant.name
        ratingLabel.text = "\(restaurant.rating)"
        addressLabel.text = restaurant.address
        countryLabel.text = restaurant.countrySelected
        
        // create array of photo reference ID's
        for i in 0...restaurant.photoReferenceID.count - 1 {
            photoReferenceID.append(restaurant.photoReferenceID[i].photoReferenceID)
        }
        var maxImages = photoReferenceID.count - 1
        var imageIndex: NSInteger = 0
        
        // downloading the photos
        for index in 0...photoReferenceID.count - 1 {
            downloadImage(photoReferenceID[index], restaurantImage: images)
        }
        
        // Swipe gestures
//        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:") // put : at the end of method name
//        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
//        self.view.addGestureRecognizer(swipeRight)
//        
//        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:") // put : at the end of method name
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
//        self.view.addGestureRecognizer(swipeLeft)
    }
    
//    func swiped(gesture: UIGestureRecognizer) {
//        
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            
//            switch swipeGesture.direction {
//                
//            case UISwipeGestureRecognizerDirection.Right :
//                println("User swiped right")
//                
//                // decrease index first
//                
//                imageIndex--
//                
//                // check if index is in range
//                
//                if imageIndex < 0 {
//                    
//                    imageIndex = maxImages
//                    
//                }
//                
//                image.image = UIImage(named: imageList[imageIndex])
//                
//            case UISwipeGestureRecognizerDirection.Left:
//                println("User swiped Left")
//                
//                // increase index first
//                
//                imageIndex++
//                
//                // check if index is in range
//                
//                if imageIndex > maxImages {
//                    
//                    imageIndex = 0
//                    
//                }
//                
//                image.image = UIImage(named: imageList[imageIndex])
//                
//                
//                
//                
//            default:
//                break //stops the code/codes nothing.
//                
//                
//            }
//            
//        }
//        
//        
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        println("MEMORY WARNING")
    }
    
    func downloadImage(photoReference: String, restaurantImage: UIImageView) {
        if let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" + photoReference + "&key=AIzaSyAKtrEj6qZ17YcjfD4SlijGbZd96ZZPkRM") {
            if let data = NSData(contentsOfURL: url) {
                restaurantImage.contentMode = UIViewContentMode.ScaleAspectFit
                restaurantImage.image = UIImage(data: data)
            }
        }
    }
    
    // adds restaurant name to Realm
    func addObjectToRealm() {

            Network.getGooglePlacesDetails(self.placeDetailsURL, completionHandler: { response -> Void in
                
                if let response = response {
                    
                    let realm = Realm()
                    
                    let results = response as NSDictionary
                    
                    realm.write {
                        realm.create(Restaurant.self, value: results, update: true)
                    }
                    
                }
                
            })
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "exitFromInfoController" {
            self.addObjectToRealm()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}