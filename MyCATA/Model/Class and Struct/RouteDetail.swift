//
//  RouteDetail.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/14/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation
import UIKit

typealias RouteID = Int
typealias StopID = Int

struct RouteDetail : Decodable {
    let routeId : RouteID
    let shortName : String
    let longName : String
    let routeAbbreviation : String
    let colorString : String
    let textColorString : String
    let sortOrder : Int
    let stops : [Stop]
    let routeStops : [RouteStop]
    let routeTraceFilename : String?
    var color : UIColor { return hexToColor(hex: colorString) }
    var textColor : UIColor { return hexToColor(hex: textColorString) }
    
    enum CodingKeys : String, CodingKey {
        case routeId = "RouteId"
        case shortName = "ShortName"
        case longName = "LongName"
        case routeAbbreviation = "RouteAbbreviation"
        case colorString = "Color"
        case textColorString = "TextColor"
        case sortOrder = "SortOrder"
        case stops = "Stops"
        case routeStops = "RouteStops"
        case routeTraceFilename = "RouteTraceFilename"
    }
    
    func hexToColor(hex: String) -> UIColor {
        let rgb = UInt32(hex, radix: 16)!
        return UIColor(rgb: rgb)
    }
}
