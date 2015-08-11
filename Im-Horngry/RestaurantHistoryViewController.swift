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
    
    var restaurants: Results<Restaurant>! {
        didSet {
            mainTableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tell the table view where its data source is
        mainTableView.dataSource = self
        
        restaurants = Realm().objects(Restaurant)

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "fromHistorytoInfo" {

        }
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
