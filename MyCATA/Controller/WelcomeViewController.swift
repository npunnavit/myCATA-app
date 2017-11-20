//
//  ViewController.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/13/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import UIKit
import MapKit

class WelcomeViewController: UIViewController {
    
    let model = MyCATAModel.sharedInstance
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: UserDefaultsKeys.firstLaunch)
        defaults.synchronize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .notDetermined, .denied:
                locationManager.requestWhenInUseAuthorization()
            default:
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

