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
    
    var address: String = ""
    var rating: Double = 0.0
    var country: String = ""
    var restaurantName: String = ""
    
    var priceSelected: Int? // price constraint
    var radius: Int? // radius constraint
    var photoReference: String? // photo reference to display on the view
    
    var queriesCount: Int = 0 // counting the number of requests
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var imageURL: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restaurantLabel.text = restaurant.name
        ratingLabel.text = "\(restaurant.rating)"
        addressLabel.text = restaurant.address
        countryLabel.text = restaurant.countrySelected
        
        // Swipe gestures
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:") // put : at the end of method name
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:") // put : at the end of method name
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
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
    }
    
    // adds restaurant name to Realm
    func addObjectToRealm() {
        var restaurantVisited = Restaurant()
        let realm = Realm()
        
        realm.write {
            if self.restaurant.name != "" {
                restaurantVisited = self.restaurant
                realm.add(restaurantVisited)
                println("Object added to Realm")
            }
        }
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