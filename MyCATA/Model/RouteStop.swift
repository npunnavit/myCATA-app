//
//  RouteStop.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/14/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation

struct RouteStop : Codable {
    
    enum Direction : String, Codable {
        case inbound = "I"
        case outbound = "O"
    }
    
    let routeId : Int
    let stopId : Int
    let sortOrder : Int
    let direction : Direction
    
    enum CodingKeys : String, CodingKey {
        case routeId = "RouteId"
        case stopId = "StopId"
        case sortOrder = "SortOrder"
        case direction = "Direction"
    }
}
