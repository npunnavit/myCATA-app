//
//  SearchResultsViewModel.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 12/2/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation

class SearchResultsViewModel {
    let myCATAModel = MyCATAModel.sharedInstance
    
    var routes : [RouteID]?
    var stop : StopID?
    var stopDeparture : StopDeparture?
    
    //MARK: - configure model
    func configure(routes: [RouteID], stop: StopID) {
        self.routes = routes
        self.stop = stop
    }
    
    //MARK: - Support for SearchResultsTableView
    var numberOfSections : Int {
        if routes != nil {
            return routes!.count
        } else {
            return 0
        }
    }
    
    func numberOfRow(inSection section: Int) -> Int {
        if let routes = routes {
            let routeId = routes[section]
            return departuresFor(route: routeId).count
        } else {
            return 0
        }
    }
    
    func departure(forIndexPath indexPath: IndexPath) -> Departure {
        let section = indexPath.section
        let row = indexPath.row
        let routeId = routes![section]
        let departures = departuresFor(route: routeId)
        return departures[row]
    }
    
    func routeDetailFor(section: Int) -> RouteDetail {
        let routeId = routes![section]
        return myCATAModel.routeDetailFor(route: routeId)
    }
    
    func titleFor(section: Int) -> (routeTitle: String, stopTitle: String) {
        var routeTitle = "N/A"
        var stopTitle = "N/A"
        
        if let routes = routes {
            let routeId = routes[section]
            let routeDetail = myCATAModel.routeDetailFor(route: routeId)
            routeTitle = routeDetail.longName
        }
        
        if let stopId = stop {
            stopTitle = myCATAModel.stopFor(stop: stopId).name
        }
        return (routeTitle, stopTitle)
    }
    
    func departuresFor(route routeId: RouteID) -> [Departure] {
        if let routeDirection = routeStopDepartureFor(route: routeId) {
            return routeDirection.departures!
        } else {
            return []
        }
    }
    
    func routeStopDepartureFor(route routeId: RouteID) -> RouteDirection? {
        if let stopDeparture = stopDeparture {
            for routeDirection in stopDeparture.routeDirections {
                if routeDirection.routeId == routeId && routeDirection.isDone == false {
                    return routeDirection
                }
            }
        }
        
        return nil
    }
    
    //MARK: - Network Request
    func requestStopDeparture(at stopId: StopID) {
        let urlString = MyCATAModel.stopDepartureURL + String(stopId)
        let url = URL(string: urlString)!
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else { print(error!.localizedDescription); return }
            self.stopDeparture = self.decodeStopDeparture(data!)
            
            let center = NotificationCenter.default
            let userInfo : [AnyHashable:Any] = ["StopId": stopId]
            center.post(name: Notification.Name.StopDepartureDataDownloaded, object: self, userInfo: userInfo)
        }
        task.resume()
    }
    
    func decodeStopDeparture(_ data: Data) -> StopDeparture? {
        var _stopDeparture : [StopDeparture]?
        let decoder = JSONDecoder()
        
        ////////////////////////////TEST/////////////////////////////
        let bundle = Bundle.main
        let fileManager = FileManager.default
        let path = bundle.path(forResource: "data", ofType: "json")!
        let testData = fileManager.contents(atPath: path)!
        ////////////////////////////TEST/////////////////////////////
        
        do {
            if !MyCATAModel.useTestData {
                _stopDeparture = try decoder.decode([StopDeparture].self, from: data)
            } else {
                _stopDeparture = try decoder.decode([StopDeparture].self, from: testData)
            }
            return _stopDeparture![0]
        } catch let error as NSError {
            print("Unresolved Error \(String(describing: error)))" )
            //            print(String(data: data, encoding: String.Encoding.utf8) ?? "Data could not be printed")
        }
        
        return nil
    }
}
