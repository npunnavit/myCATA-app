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
    let estimatedDepartureTime : String
    let scheduledDepartureTime : String
    let deviation : String
    let lastUpdated : String
    
    enum CodingKeys : String, CodingKey {
        case estimatedDepartureTime = "EDTLocalTime"
        case scheduledDepartureTime = "SDTLocalTime"
        case deviation = "Dev"
        case lastUpdated = "LastUpdatedLocalTime"
    }
}

struct RouteDirection : Codable {
    let routeId : Int
    let departures : [Departure]
    let direction : Direction
    let isDone : Bool
    
    enum CodingKeys : String, CodingKey {
        case routeId = "RouteId"
        case departures = "Departures"
        case direction = "Direction"
        case isDone = "IsDone"
    }
    
    enum Direction : String, Codable {
        case outbound = "Outbound"
        case inbound = "Inbound"
        case loop = "Loop"
    }
}
