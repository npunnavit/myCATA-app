//
//  RouteMapModel.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/27/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation

class RouteMapViewModel {
    
    static let sharedInstance = RouteMapViewModel()
    let myCATAModel = MyCATAModel.sharedInstance
    
    fileprivate init() {
        
    }
    
    func stops(forRoutes routesId: [RouteID]) -> [Stop] {
        var stops = [Stop]()
        var stopsId = Set<StopID>()
        
        for routeId in routesId {
            let routeDetail = myCATAModel.routeDetailFor(route: routeId)
            let stops = routeDetail.stops
            for stop in stops {
                stopsId.insert(stop.stopId)
            }
        }
        
        for stopId in stopsId {
            let stop = myCATAModel.stopFor(stop: stopId)
            stops.append(stop)
        }
        
        return stops
    }
    
}
