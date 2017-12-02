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
    
    var vehicles = [RouteID: [VehicleLocation]]()
    
    init() {
        
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
    
    func vehiclesFor(route routeId: RouteID) -> [VehicleLocation]? {
        return vehicles[routeId]
    }
    
    func requestVehicles(forRoute routeId: RouteID) {
        let urlString = RouteMapViewModel.vehicleLocationURL + String(routeId)
        let url = URL(string: urlString)!
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else { print(error!.localizedDescription); return }
            
            self.vehicles[routeId] = self.decodeVehicleLocation(data!)
            
            let center = NotificationCenter.default
            let userInfo : [AnyHashable:Any] = ["RouteId": routeId]
            center.post(name: Notification.Name.VehicleLocationDataDownloaded, object: self, userInfo: userInfo)
        }
        task.resume()
    }
    
    func requestVehicles(forRoutes routesId: [RouteID]) {
        for routeId in routesId {
            requestVehicles(forRoute: routeId)
        }
    }
    
    func decodeVehicleLocation(_ data: Data) -> [VehicleLocation]? {
        var vehiclesLocations : [VehicleLocation]?
        let decoder = JSONDecoder()
        
        do {
            vehiclesLocations = try decoder.decode([VehicleLocation].self, from: data)
            return vehiclesLocations
        } catch let error as NSError {
            print("Unresolved Error \(String(describing: error))")
        }
        
        return nil
    }
    
    //MARK: - Micellaneous function
}
