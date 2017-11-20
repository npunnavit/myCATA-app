//
//  MyCATAModel.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/15/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation

class MyCATAModel {
    static let sharedInstance = MyCATAModel()
    
    //MARK: - Properties
    let routeDetails : [RouteDetail]
    let routeNames : [String]
    let routeIdToIndex : [Int: Int]
    let stops : [Stop]
    var favorites : [Int] = []
    var stopDepartures = [Int: StopDeparture]()
    var closestStop : Int = 39 /////////////////////For Testing////////////////////
    
    fileprivate init() {
        let fileManager = FileManager.default
        let bundle = Bundle.main
        let decoder = JSONDecoder()
        
        //Decode Route Data
        var path = bundle.path(forResource: FileName.routeData, ofType: "json")!
        var data = fileManager.contents(atPath: path)!
        do {
            routeDetails = try decoder.decode([RouteDetail].self, from: data)
            var _routeNames = [String]()
            var _routeIdToIndex = [Int: Int]()
            var index = 0
            for routeDetail in routeDetails {
                _routeNames.append(routeDetail.longName)
                _routeIdToIndex[routeDetail.routeId] = index
                index += 1
            }
            routeNames = _routeNames
            routeIdToIndex = _routeIdToIndex
        } catch let error as NSError {
            routeDetails = []
            routeNames = []
            routeIdToIndex = [:]
            print("Unresolved Error \(String(describing: error)))" )
        }
        
        //Decode Stop Data
        path = bundle.path(forResource: FileName.stopData, ofType: "json")!
        data = fileManager.contents(atPath: path)!
        do {
            stops = try decoder.decode([Stop].self, from: data)
        } catch let error as NSError {
            stops = []
            print("Unresolved Error \(String(describing: error)))" )
        }
    }
    
    //MARK: - Support for RoutesTableView
    var numberOfRoutes : Int { return routeDetails.count }
    
    func route(forIndexPath indexPath: IndexPath) -> RouteDetail {
        let index = indexPath.row
        return routeDetails[index]
    }
    
    func routeName(atIndexPath indexPath: IndexPath) -> String {
        let index = indexPath.row
        return routeNames[index]
    }
    
    func isFavorite(indexPath: IndexPath) -> Bool {
        let id = route(forIndexPath: indexPath).routeId
        return favorites.contains(id)
    }
    
    func addToFavorite(indexPath: IndexPath) -> Bool {
        guard favorites.count < 3 else { return false }
        let id = route(forIndexPath: indexPath).routeId
        favorites.append(id)
        return true
    }
    
    func removeFromFavorite(indexPath: IndexPath) {
        let id = route(forIndexPath: indexPath).routeId
        if let index = favorites.index(of: id) {
            favorites.remove(at: index)
        }
    }
    
    func getFavoriteIndices() -> [IndexPath] {
        var indices = [IndexPath]()
        for id in favorites {
            if let index = routeIdToIndex[id] {
                let indexPath = IndexPath(row: index, section: 1)
                indices.append(indexPath)
            }
        }
        return indices
    }
    
    //MARK: - Support for FavoritesTableVIew
    var numberOfSections : Int { return favorites.count }
    
    func numberOfRow(inSection section: Int) -> Int {
        let routeId = favorites[section]
        return getDepartures(forRoute: routeId, atStop: closestStop).count
    }
    
    func departure(forIndexPath indexPath: IndexPath) -> Departure {
        let section = indexPath.section
        let row = indexPath.row
        let routeId = favorites[section]
        let departures = getDepartures(forRoute: routeId, atStop: closestStop)
        return departures[row]
    }
    
    func titleFor(section: Int) -> String {
        let routeId = favorites[section]
        let index = routeIdToIndex[routeId]!
        return routeDetails[index].longName
    }
    
    func getDepartures(forRoute routeId: Int, atStop stopId: Int) -> [Departure] {
        if let routeDirection = getRouteStopDeparture(forRoute: routeId, atStop: stopId) {
            if routeDirection.isDone {
                return []
            } else {
                return routeDirection.departures
            }
        } else {
            return []
        }
    }
    
    func getRouteStopDeparture(forRoute routeId: Int, atStop stopId: Int) -> RouteDirection? {
        if let stopDeparture = getStopDeparture(atStop: stopId) {
            for routeDirection in stopDeparture.routeDirections {
                if routeDirection.routeId == routeId {
                    return routeDirection
                }
            }
        }
        return nil
    }
    
    func getStopDeparture(atStop stopId: Int) -> StopDeparture? {
        return stopDepartures[stopId]
//        if let stopDeparture = stopDepartures[stopId] {
//            return stopDeparture
//        } else {
//            requestStopDeparture(at: stopId)
//            return nil
//        }
    }
    
    
    //MARK: - Network Request
    func requestStopDeparture(at stopId: Int) {
        let urlString = MyCATAModel.stopDepartureURL + String(stopId)
        let url = URL(string: urlString)!
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else { print(error!.localizedDescription); return }
            self.stopDepartures[stopId] = self.decodeStopDeparture(data!)
            
            let center = NotificationCenter.default
            let userInfo : [AnyHashable:Any] = ["StopId": stopId]
            center.post(name: Notification.Name.StopDepartureDataDownloaded, object: self, userInfo: userInfo)
        }
        task.resume()
    }
    
    func decodeStopDeparture(_ data: Data) -> StopDeparture? {
        var _stopDeparture : [StopDeparture]?
        let decoder = JSONDecoder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return nil
        
        do {
            _stopDeparture = try decoder.decode([StopDeparture].self, from: data)
            return _stopDeparture![0]
        } catch let error as NSError {
            print("Unresolved Error \(String(describing: error)))" )
            print(String(data: data, encoding: String.Encoding.utf8) ?? "Data could not be printed")
        }
        
        return nil
    }
    
    //MARK: - Micellanous Methods
    func getRouteDetail(forRoute routeId: Int) -> RouteDetail {
        let index = routeIdToIndex[routeId]!
        return routeDetails[index]
    }
}
