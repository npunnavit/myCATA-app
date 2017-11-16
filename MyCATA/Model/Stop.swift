//
//  Stop.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/14/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation
import MapKit

struct Stop : Codable {
    let stopId : Int
    let name : String
    let latitude : CLLocationDegrees
    let longtitude : CLLocationDegrees
    
    enum CodingKeys : String, CodingKey {
        case stopId = "StopId"
        case name = "Name"
        case latitude = "Latitude"
        case longtitude = "Longitude"
    }
}