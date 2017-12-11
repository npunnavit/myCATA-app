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
    let lastUpdatedRawData : String
    
    enum CodingKeys : String, CodingKey {
        case stopId = "StopId"
        case routeDirections = "RouteDirections"
        case lastUpdatedRawData = "LastUpdated"
    }
    
    var lastUpdatedTime : Date? { return Date(jsonDate: lastUpdatedRawData) }
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
    var lastUpdatedTime : Date? { return Date(jsonDate: lastUpdatedRawData) }
}

struct RouteDirection : Codable {
    let routeId : RouteID
    let departures : [Departure]?
    let direction : Direction
    let isDone : Bool
    let headwayDepartures : [HeadwayDeparture]?
    
    enum CodingKeys : String, CodingKey {
        case routeId = "RouteId"
        case departures = "Departures"
        case direction = "Direction"
        case isDone = "IsDone"
        case headwayDepartures = "HeadwayDepartures"
    }
    
    enum Direction : String, Codable {
        case outbound = "Outbound"
        case inbound = "Inbound"
        case loop = "Loop"
    }
}

struct HeadwayDeparture : Codable {
    let tripId : Int
    let serviceDescription : String
    let headwayIntervalScheduled : TimeInterval
    let headwayIntervalTarget : TimeInterval
    let nextDeparture : String
    
    enum CodingKeys : String, CodingKey {
        case tripId = "TripId"
        case serviceDescription = "ServiceDescription"
        case headwayIntervalScheduled = "HeadwayIntervalScheduled"
        case headwayIntervalTarget = "HeadwayIntervalTarget"
        case nextDeparture = "NextDeparture"
    }
}
