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
    let stopId : StopID
    let name : String
    let latitude : CLLocationDegrees
    let longtitude : CLLocationDegrees
    var location : CLLocation { return CLLocation(latitude: latitude, longitude: longtitude) }
    var location2D : CLLocationCoordinate2D { return CLLocationCoordinate2DMake(latitude, longtitude) }
    
    enum CodingKeys : String, CodingKey {
        case stopId = "StopId"
        case name = "Name"
        case latitude = "Latitude"
        case longtitude = "Longitude"
    }
}
