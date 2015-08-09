//
//  Restaurant.swift
//  Im-Horngry
//
//  Created by Timothy Horng on 8/2/15.
//  Copyright (c) 2015 Timothy Horng. All rights reserved.
//

import RealmSwift

class Restaurant: Object {
    dynamic var name: String = ""
    dynamic var photoReferenceID: String = ""
    dynamic var rating: String = ""
    dynamic var address: String = ""
    dynamic var detailsReferenceID: String = ""
    dynamic var phoneNumber: String = ""
}

