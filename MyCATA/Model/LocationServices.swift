//
//  LocationServices.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/28/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation
import MapKit

protocol LocationServicesDelegate {
    func updateUsersLocation(to newLocation: CLLocation)
}

class LocationServices : NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance = LocationServices()
    
    private let locationManager = CLLocationManager()
    var delegate : LocationServicesDelegate?
    var location : CLLocation? { return locationManager.location }
    
    fileprivate override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    //MARK: - CLLocationManagerDelegate Method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue : CLLocation = manager.location!
        delegate?.updateUsersLocation(to: locValue)
    }
}
