//
//  Constants.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/16/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation
import UIKit

extension MyCATAModel {
    static let stopDepartureURL = "http://realtime.catabus.com/InfoPoint/rest/stopdepartures/get/"
    static let departureResultsCount = 3
    static let useTestData = false
}

extension RouteMapViewModel {
    static let kmlURL = "http://realtime.catabus.com/InfoPoint/Resources/Traces/"
    static let vehicleLocationURL = "http://realtime.catabus.com/InfoPoint/rest/vehicles/getallvehiclesforroute?routeID="
}

extension FavoritesTableViewController {
    static let departureCellAlpha : CGFloat = 0.1
    static let departureCellHeight : CGFloat = 70
    static let departureHeaderViewHeight : CGFloat = 50
}

extension RouteMapViewController {
    static let defaultSpanDelta = 0.1
    static let zoomedSpanDelta = 0.01
    static let busIconSize = 40.0
}

extension SearchTableViewController {
    static let routeCellHeight : CGFloat = 50
}

extension Notification.Name {
    static let StopDepartureDataDownloaded = NSNotification.Name("StopDepartureDataDownloadedNotification")
    static let VehicleLocationDataDownloaded = NSNotification.Name("VehicleLocationDataDownloadedNotification")
    static let ArrivalNotificationScheduled = NSNotification.Name("ArrivalNotificationScheduled")
}

struct FileName {
    static let routeData = "RouteData"
    static let stopData = "StopData"
}

struct ReuseIdentifier {
    static let routeCell = "RouteCell"
    static let departureCell = "DepartureCell"
    static let departureHeaderView = "DepartureHeaderView"
}

struct UserDefaultsKeys {
    static let firstLaunch = "FirstLaunch"
    static let favorites = "Favorites"
}

struct SegueIdentifiers {
    static let welcomeSegue = "WelcomeSegue"
    static let routeMapSegue = "RouteMapSegue"
    static let settingsSegue = "SettingsSegue"
    static let searchSegue = "SearchSegue"
    static let searchResultsSegue = "SearchResultsSegue"
}

struct AnnotationIdentifiers {
    static let stopPin = "StopPin"
    static let busAnnotation = "BusAnnotation"
}

struct Constants {
    static let secondsInMinute = 60.0
    struct TimeInterval {
        static let aMinute = 60.0
        static let halfMinute = 30.0
    }
}
