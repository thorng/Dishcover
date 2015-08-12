//
//  RestaurantHistoryViewController.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 8/2/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import UIKit
import RealmSwift

class RestaurantHistoryViewController: UIViewController {
    
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet weak var countriesVisitedNumberLabel: UILabel!
    
    var isSegueFromRestaurantHistory = true
    
    var restaurants: Results<Restaurant>! {
        didSet {
            mainTableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countriesVisitedNumberLabel.text = "\(Int(restaurants?.count ?? 0))"
        println(Int(restaurants?.count ?? 0))
        
        // Tell the table view where its data source is
        mainTableView.dataSource = self
        
        restaurants = Realm().objects(Restaurant)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "fromHistorytoInfo" {
            if let destination = segue.destinationViewController as? InfoViewController {
                if let index = mainTableView.indexPathForSelectedRow()?.row {
                    var restaurant = restaurants[index] as Restaurant
                    destination.restaurant = restaurant
                    
                    destination.isSegueFromRestaurantHistory = true
                }
            }
        }
        
    }
    
    @IBAction func unwindToHistory(segue: UIStoryboardSegue, sender: AnyObject!) {
        
    }

}

extension RestaurantHistoryViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = mainTableView.dequeueReusableCellWithIdentifier("RestaurantCell", forIndexPath: indexPath) as! RestaurantTableViewCell
        
        let row = indexPath.row
        let restaurant = restaurants[row] as Restaurant
        cell.restaurant = restaurant
                
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(restaurants?.count ?? 0)
    }
    
}
