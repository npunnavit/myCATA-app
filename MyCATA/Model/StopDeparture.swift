//
//  StopDeparture.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/18/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation

struct StopDeparture : Codable {
    let stopId : Int
    let routeDirections : [RouteDirection]
    
    enum CodingKeys : String, CodingKey {
        case stopId = "StopId"
        case routeDirections = "RouteDirections"
    }
}

struct Departure : Codable {
    let estimatedDepartureTime : Date
    let scheduledDepartureTime : Date
    let deviation : Date
    let lastUpdated : Date
    
    enum CodingKeys : String, CodingKey {
        case estimatedDepartureTime = "EDT"
        case scheduledDepartureTime = "SDT"
        case deviation = "Dev"
        case lastUpdated = "LastUpdated"
    }
}

struct RouteDirection : Codable {
    let departures : [Departure]
    
    enum CodingKeys : String, CodingKey {
        case departures = "Departures"
    }
}
