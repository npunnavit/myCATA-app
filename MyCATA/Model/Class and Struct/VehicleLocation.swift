//
//  VehicleLocation.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/30/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation
import MapKit

typealias VehicleID = Int

struct VehicleLocation : Codable {
    let blockFareboxId : Int
    let communicationStatus : String
    let destination : String
    let deviation : Int?
    let direction : String
    let directionLong : String
    let displayStatus : String?
    let driverName : String
    let gpsStatus : Int
    let heading : Int
    let lastStop : String
    let latitude : CLLocationDegrees
    let longtitude : CLLocationDegrees
    let onBoard : Int
    let operationStatus : String
    let routeId : RouteID
    let runId : Int
    let speed : Double
    let tripId : Int
    let vehicleId : VehicleID
    
    var location : CLLocationCoordinate2D { return CLLocationCoordinate2D(latitude: latitude, longitude: longtitude) }
    
    enum CodingKeys : String, CodingKey {
        case blockFareboxId = "BlockFareboxId"
        case communicationStatus = "CommStatus"
        case destination = "Destination"
        case deviation = "Deviation"
        case direction = "Direction"
        case directionLong = "DirectionLong"
        case displayStatus = "DisplayStatus"
        case driverName = "DriverName"
        case gpsStatus = "GPSStatus"
        case heading = "Heading"
        case lastStop = "LastStop"
        case latitude = "Latitude"
        case longtitude = "Longitude"
        case onBoard = "OnBoard"
        case operationStatus = "OpStatus"
        case routeId = "RouteId"
        case runId = "RunId"
        case speed = "Speed"
        case tripId = "TripId"
        case vehicleId = "VehicleId"
    }
}
