//
//  Restaurant.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 8/2/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import RealmSwift

class Restaurant: Object {
    
    dynamic var placeDetailsURL: String = ""
    dynamic var googleURL: String = ""

    dynamic var countrySelected: String = ""
    dynamic var countrySelectedKey: String = ""
    
    dynamic var name: String = ""
    dynamic var rating: Double = 0
    dynamic var detailsReferenceID: String = ""
    dynamic var phoneNumber: String = ""
    
    dynamic var address: String = ""
    dynamic var destLatitude: Double = 0
    dynamic var destLongitude: Double = 0
    
    dynamic var dateEaten: String = ""
    
    let photoReferenceID = List<PhotoID>()
    
    override class func primaryKey() -> String {
        return "countrySelectedKey"
    }
    
}

