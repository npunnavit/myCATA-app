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
    let routeIdToIndex : [Int: Int] //map routeId to index in routeDetails array
    let stops : [Stop]
    var favorites : [Int] //store user's daily buses by routeId
    var stopDepartures = [Int: StopDeparture]()
    
    //App doesn't find closest stop right now. Use Pattee stop (stopId: 4) for testing
    var closestStop : Int = 4 /////////////////////For Testing////////////////////
    
    fileprivate init() {
        let defaults = UserDefaults.standard
        favorites = defaults.array(forKey: UserDefaultsKeys.favorites) as? [Int] ?? []
        
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
        updateUserDefaultsFavorites()
        return true
    }
    
    func removeFromFavorite(indexPath: IndexPath) {
        let id = route(forIndexPath: indexPath).routeId
        if let index = favorites.index(of: id) {
            favorites.remove(at: index)
        }
        updateUserDefaultsFavorites()
    }
    
    //update favorites in UserDefaults for persistance
    func updateUserDefaultsFavorites() {
        let defaults = UserDefaults.standard
        defaults.set(favorites, forKey: UserDefaultsKeys.favorites)
        defaults.synchronize()
    }
    
    //return the indexPaths of favorite routes in RoutesTableView
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
        
        do {
            _stopDeparture = try decoder.decode([StopDeparture].self, from: data)
            return _stopDeparture![0]
        } catch let error as NSError {
            print("Unresolved Error \(String(describing: error)))" )
            print(String(data: data, encoding: String.Encoding.utf8) ?? "Data could not be printed")
        }
        
        return nil
    }
    
    //network request returns all the departures at a stop
    //there was a problem parsing the departure times
    //this is a temporary remedy
    func parseDeparture(departure: Departure) -> [String: String] {
        var departureString = [String: String]()
        
        let sdtDateTimeString = departure.scheduledDepartureTime.split(separator: "T")
        let sdtTimeString = String(sdtDateTimeString[1])
        
        let edtDateTimeString = departure.estimatedDepartureTime.split(separator: "T")
        let edtTimeString = String(edtDateTimeString[1])
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        
        let edtTime = dateFormatter.date(from: edtTimeString)!
        let sdtTime = dateFormatter.date(from: sdtTimeString)!
    
        
        dateFormatter.dateFormat = "hh:mm"
        departureString["edt"] = dateFormatter.string(from: edtTime)
        departureString["sdt"] = dateFormatter.string(from: sdtTime)
        return departureString
    }
    
    //MARK: - Micellanous Methods
    func getRouteDetail(forRoute routeId: Int) -> RouteDetail {
        let index = routeIdToIndex[routeId]!
        return routeDetails[index]
    }
}
