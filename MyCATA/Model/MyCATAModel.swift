//
//  MyCATAModel.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/15/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation
import MapKit
import UserNotifications

class MyCATAModel : NSObject {
    static let sharedInstance = MyCATAModel()
    
    //MARK: - Properties
    let routeDetails : [RouteDetail]
    let routeNames : [String]
    let routeIdToIndex : [RouteID: Int] //map routeId to index in routeDetails array
    let stops : [Stop]
    let stopIdToIndex : [StopID: Int]
    var favorites : [RouteID] //store user's daily buses by routeId
    var stopDepartures = [StopID: StopDeparture]() //stopId to StopDeparture
    var usersLocation : CLLocation! {
        didSet {
            if usersLocation != nil { updateClosestStopForFavoriteRoutes() }
        }
    }

    
    //App doesn't find closest stop right now. Use Pattee stop (stopId: 4) for testing
    var closestStopForRoute : [RouteID: StopID] //RouteID to closest stop
    
    fileprivate override init() {
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
            var _stopIdToIndex = [StopID: Int]()
            var index = 0
            for stop in stops {
                _stopIdToIndex[stop.stopId] = index
                index += 1
            }
            stopIdToIndex = _stopIdToIndex
        } catch let error as NSError {
            stops = []
            stopIdToIndex = [:]
            print("Unresolved Error \(String(describing: error)))" )
        }
        
        closestStopForRoute = [:]
        
        super.init()
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
    
    
    //MARK: - Network Request
    func requestStopDeparture(at stopId: StopID) {
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
        }
        
        return nil
    }
    
    //MARK: - Find closestStop
    func updateClosestStop(forRoute routeId: RouteID, atUserLocation location: CLLocation, forceUpdate: Bool = false) {
        var minDistance = CLLocationDistance.infinity
        var closestStop : StopID?
        let routeDetail = routeDetailFor(route: routeId)
        let stops = routeDetail.stops
        for stop in stops {
            let stopLocation = stop.location
            let distance = stopLocation.distance(from: location)
            if distance < minDistance {
                minDistance = distance
                closestStop = stop.stopId
            }
        }
        print(stopFor(stop: closestStop!).name)
        let oldClosestStop = closestStopForRoute.updateValue(closestStop!, forKey: routeId)
        
        if forceUpdate {
            requestStopDeparture(at: closestStop!)
        } else if (oldClosestStop != closestStop) {
            //if closestStop changes, request for new data
            requestStopDeparture(at: closestStop!)
        } else {
            //if data was updated more than a minute ago, request for new data
            if let stopDeparture = stopDepartureAt(stop: closestStop!), let lastUpdatedTime = stopDeparture.lastUpdatedTime {
                if lastUpdatedTime.timeIntervalSinceNow.magnitude > Constants.secondsInMinute {
                    requestStopDeparture(at: closestStop!)
                }
            }
        }
    }
    
    func updateClosestStopForFavoriteRoutes() {
        for routeID in favorites {
            updateClosestStop(forRoute: routeID, atUserLocation: usersLocation)
        }
    }
    
    func forceUpdateClosestStopForFavoriteRoutes() {
        if usersLocation != nil {
            for routeID in favorites {
                updateClosestStop(forRoute: routeID, atUserLocation: usersLocation, forceUpdate: true)
            }
        }
    }
    
    //MARK: - Compute Travel Time
    func calculateWalkingTime(from sourceLocation: CLLocationCoordinate2D, to destinationLocation: CLLocationCoordinate2D, completionHandler: @escaping (TimeInterval) -> Void ) {
        let request = MKDirectionsRequest()
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        let destinationMapItem = MKMapItem(placemark: destinationPlaceMark)
        
        request.source = sourceMapItem
        request.destination = destinationMapItem
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            guard error == nil else { print(error?.localizedDescription ?? "Error"); return }
            
            if let route = response?.routes[0] {
                completionHandler(route.expectedTravelTime)
            }
        }
    }
    
    //MARK: - Micellanous Methods
    func routeDetailFor(route routeId: RouteID) -> RouteDetail {
        let index = routeIdToIndex[routeId]!
        return routeDetails[index]
    }
    
    func stopFor(stop stopId: StopID) -> Stop {
        let index = stopIdToIndex[stopId]!
        return stops[index]
    }
    
    func routeShortNameFor(route routeId: RouteID) -> String {
        return routeDetailFor(route: routeId).shortName
    }
    
    private func routeIconNameFor(route routeId: RouteID) -> String {
        let routeShortName = routeShortNameFor(route: routeId)
        let iconName = "\(routeShortName)-RouteIcon"
        return iconName
    }
    
    func routeIconFor(route routeId: RouteID) -> UIImage {
        let iconName = routeIconNameFor(route: routeId)
        if let icon = UIImage(named: iconName) {
            return icon
        } else {
            return UIImage(named: "Default-RouteIcon")!
        }
    }
}

extension MyCATAModel : LocationServicesDelegate {
    func updateUsersLocation(to newLocation: CLLocation) {
        usersLocation = newLocation
    }
}

//MARK: - Support for FavoriteTableView
extension MyCATAModel {
    var numberOfSections : Int { return favorites.count }
    
    func numberOfRow(inSection section: Int) -> Int {
        let routeId = favorites[section]
        if let closestStop = closestStopForRoute[routeId] {
            return departuresFor(route: routeId, atStop: closestStop).count
        } else {
            return 0
        }
    }
    
    func departure(forIndexPath indexPath: IndexPath) -> Departure {
        let section = indexPath.section
        let row = indexPath.row
        let routeId = favorites[section]
        let closestStop = closestStopForRoute[routeId]!
        let departures = departuresFor(route: routeId, atStop: closestStop)
        return departures[row]
    }
    
    func routeDetailFor(section: Int) -> RouteDetail {
        let routeId = favorites[section]
        return routeDetailFor(route: routeId)
    }
    
    func titleFor(section: Int) -> (routeTitle: String, stopTitle: String, routeId: RouteID) {
        let routeId = favorites[section]
        let routeDetail = routeDetailFor(route: routeId)
        let routeTitle = routeDetail.longName
        
        if let stopId = closestStopForRoute[routeId] {
            let stopTitle = stopFor(stop: stopId).name
            return (routeTitle, stopTitle, routeId)
        } else {
            return (routeTitle, "N/A", routeId)
        }
    }
    
    func departuresFor(route routeId: RouteID, atStop stopId: StopID) -> [Departure] {
        if let routeDirection = routeStopDepartureFor(route: routeId, atStop: stopId) {
            return Array(routeDirection.departures!.prefix(MyCATAModel.departureResultsCount))
        } else {
            return []
        }
    }
    
    func routeStopDepartureFor(route routeId: RouteID, atStop stopId: StopID) -> RouteDirection? {
        if let stopDeparture = stopDepartureAt(stop: stopId) {
            for routeDirection in stopDeparture.routeDirections {
                if routeDirection.routeId == routeId && routeDirection.isDone == false {
                    return routeDirection
                }
            }
        }
        return nil
    }
    
    func stopDepartureAt(stop stopId: StopID) -> StopDeparture? {
        return stopDepartures[stopId]
    }
    
    // Create Alert
    func createArrivalAlert(forIndexPath indexPath: IndexPath) {
        let section = indexPath.section
        
        let routeId = favorites[section]
        let stopId = closestStopForRoute[routeId]!
        let aDeparture = departure(forIndexPath: indexPath)
        let scheduledTime = aDeparture.scheduledDepartureTime!
        
        createArrivalAlert(forRoute: routeId, atStop: stopId, withDepartureTime: scheduledTime)
    }
    
    func createArrivalAlert(forRoute routeId: RouteID, atStop stopId: StopID, withDepartureTime scheduledTime: Date) {
        guard usersLocation != nil else { return }
        
        let routeShortName = routeShortNameFor(route: routeId)
        let stop = stopFor(stop: stopId)
        let stopLocation = stop.location2D
        let stopName = stop.name
        
        calculateWalkingTime(from: usersLocation.coordinate, to: stopLocation) { (expectedTravelTime) in
            self.scheduleBusArrivalNotification(routeName: routeShortName, stopName: stopName, scheduledTime: scheduledTime, travelTime: expectedTravelTime)
        }
    }
    
    func scheduleBusArrivalNotification(routeName: String, stopName: String, scheduledTime: Date, travelTime: TimeInterval) {
        let triggerTimeInterval = travelTime + (5 * Constants.TimeInterval.aMinute)
        let minuteTriggerTimeInterval = Int(triggerTimeInterval / Constants.TimeInterval.aMinute)
        
        // Create Content
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "\(routeName) Bus Arriving", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "at \(stopName) in \(triggerTimeInterval) minutes", arguments: nil)
        content.sound = UNNotificationSound.default()
        
        // Configure the trigger
//        let trigger = UNCalendarNotificationTrigger(
        
        // Create teh request object
        let request = UNNotificationRequest(identifier: "Bus Arrival", content: content, trigger: trigger)
        
        // Schedule the request
        let userCenter = UNUserNotificationCenter.current()
        userCenter.delegate = self
        userCenter.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
        
        let center = NotificationCenter.default
        let userInfo : [AnyHashable:Any] = [
            "title": "Reminder Set",
            "message": "You will be notified \(minuteTriggerTimeInterval) minutes prior to bus arrival"
        ]
        center.post(name: Notification.Name.StopDepartureDataDownloaded, object: self, userInfo: userInfo)
    }
    
    func displayAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(action)
    }
}

extension MyCATAModel : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
