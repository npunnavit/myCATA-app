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
}

extension FavoritesTableViewController {
    static let departureCellAlpha : CGFloat = 0.1
}

extension Notification.Name {
    static let StopDepartureDataDownloaded = NSNotification.Name("StopDepartureDataDownlaodedNotification")
}

struct FileName {
    static let routeData = "RouteData"
    static let stopData = "StopData"
}

struct ReuseIdentifier {
    static let routeCell = "RouteCell"
    static let departureCell = "DepartureCell"
}

struct UserDefaultsKeys {
    static let firstLaunch = "FirstLaunch"
    static let favorites = "Favorites"
}

struct SegueIdentifiers {
    static let welcomeSegue = "WelcomeSegue"
}

struct Constants {
    static let secondsInMinute = 60.0
}
