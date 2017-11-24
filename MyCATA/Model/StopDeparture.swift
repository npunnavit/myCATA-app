//
//  StopDeparture.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/18/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation

struct StopDeparture : Codable {
    let stopId : StopID
    let routeDirections : [RouteDirection]
    
    enum CodingKeys : String, CodingKey {
        case stopId = "StopId"
        case routeDirections = "RouteDirections"
    }
}

struct Departure : Codable {
    let estimatedDepartureTimeRawData : String
    let scheduledDepartureTimeRawData : String
    let deviationRawData : String
    let lastUpdatedRawData : String
    
    enum CodingKeys : String, CodingKey {
        case estimatedDepartureTimeRawData = "EDT"
        case scheduledDepartureTimeRawData = "SDT"
        case deviationRawData = "Dev"
        case lastUpdatedRawData = "LastUpdated"
    }
    
    var estimatedDepartureTime : Date? { return Date(jsonDate: estimatedDepartureTimeRawData) }
    var scheduledDepartureTime : Date? { return Date(jsonDate: scheduledDepartureTimeRawData) }
}

struct RouteDirection : Codable {
    let routeId : RouteID
    let departures : [Departure]?
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
