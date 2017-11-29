//
//  RouteMapViewController.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/27/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import UIKit
import MapKit

class RouteMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    
    let routeMapModel = RouteMapViewModel.sharedInstance
    let myCATAModel = MyCATAModel.sharedInstance
    let locationManager = CLLocationManager()
    
    var route : RouteID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        if let routeId = route {
            if let routeTraceFilename = myCATAModel.routeDetailFor(route: routeId).routeTraceFilename {
                let urlString = RouteMapViewModel.kmlURL + routeTraceFilename
                //            loadKml(urlString)
            }
            
        }
        //TEST///////////////////////////////////////////////////////////
        let testLocation = CLLocation(latitude: 40.801127, longitude: -77.861394)
        //////////////////////////////////////////////////////////
        
        centerMapAt(location: testLocation, withSpanDelta: RouteMapViewModel.defaultSpanDelta)
        mapView.mapType = .standard
    }
    
//    fileprivate func loadKml(_ path: String) {
//        let url = Bundle.main.url(forResource: path, withExtension: "kml")
//        KMLDocument.parse(url!, callback:
//            { [unowned self] (kml) in
//                // Add and Zoom to annotations.
//                self.mapView.showAnnotations(kml.annotations, animated: true)
//            }
//        )
//    }
    
    func centerMapAt(location: CLLocation, withSpanDelta spanDelta: CLLocationDegrees) {
        let center = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
    }
    
    //MARK: - Configure View Controller
    func configure(route: RouteID) {
        self.route = route
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RouteMapViewController : MKMapViewDelegate {
    
}
