//
//  RouteMapViewController.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/27/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import UIKit
import MapKit
import Kml_swift

class StopPin : NSObject, MKAnnotation {
    var coordinate : CLLocationCoordinate2D
    var stopId : StopID
    
    init(stopId: StopID, coordinate: CLLocationCoordinate2D) {
        self.stopId = stopId
        self.coordinate = coordinate
    }
    
    func setCoordinate(newCoordinate:CLLocationCoordinate2D) {
        coordinate = newCoordinate
    }
}

class RouteMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    
    let routeMapViewModel = RouteMapViewModel.sharedInstance
    let myCATAModel = MyCATAModel.sharedInstance
    let locationServices = LocationServices.sharedInstance
    
    var routes : [RouteID]?
    var stopPins = [StopPin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.mapType = .standard
        mapView.delegate = self
        
        locationServices.delegate = self
        mapView.showsUserLocation = true
        
        if let userLocation = locationServices.location {
            centerMapAt(location: userLocation, withSpanDelta: RouteMapViewController.zoomedSpanDelta)
        }
        
        configureRoute()
    }
    
    fileprivate func configureRoute() {
        if let routesId = routes {
            var title = String()
            
            for routeId in routesId {
                let routeDetail = myCATAModel.routeDetailFor(route: routeId)
                
                title.append(" \(routeDetail.shortName)")
                
                if let routeTraceFilename = routeDetail.routeTraceFilename {
                    let urlString = RouteMapViewModel.kmlURL + routeTraceFilename
                    loadKml(urlString)
                }
            }
            self.navigationItem.title = String(title.dropFirst()) // Drop leading space
            
            addAnnotation(forRoutes: routesId)
        }
    }
    
    fileprivate func loadKml(_ path: String) {
        let url = URL(string: path)
        KMLDocument.parse(url!, callback:
            { [unowned self] (kml) in
                self.mapView.addOverlays(kml.overlays)
            }
        )
    }
    
    func centerMapAt(location: CLLocation, withSpanDelta spanDelta: CLLocationDegrees) {
        let center = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
    }
    
    //MARK: - Configure View Controller
    func configure(route: RouteID) {
        self.routes = [route]
    }
    
    func configure(routes: [RouteID]) {
        self.routes = routes
    }
    
    //MARK: - Add Annotation For Stops
    private func addAnnotation(forRoutes routesId: [RouteID]) {
        let stops = routeMapViewModel.stops(forRoutes: routesId)
        for stop in stops {
            let stopId = stop.stopId
            let location = stop.location2D
            let stopPin = StopPin(stopId: stopId, coordinate: location)
            stopPins.append(stopPin)
        }
        mapView.addAnnotations(stopPins)
    }
    
    //MARK: - Annotation View
    func annotationView(forPin stopPin: StopPin) -> MKAnnotationView {
        var view : MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifiers.stopPin) as? MKPinAnnotationView {
            dequeuedView.annotation = stopPin
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: stopPin, reuseIdentifier: AnnotationIdentifiers.stopPin)
        }
        return view
    }
    
    //MARK: IBActions
    
    @IBAction func changeZoomRegion(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            if let userLocation = locationServices.location {
                centerMapAt(location: userLocation, withSpanDelta: RouteMapViewController.zoomedSpanDelta)
            }
        case 1:
            mapView.showAnnotations(stopPins, animated: true)
        default:
            assert(false, "Unhandled zoom segmented control case")
        }
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is StopPin:
            return annotationView(forPin: annotation as! StopPin)
        default:
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlayPolyline = overlay as? KMLOverlayPolyline {
            // return MKPolylineRenderer
            return overlayPolyline.renderer()
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

extension RouteMapViewController : LocationServicesDelegate {
    func updateUsersLocation(to newLocation: CLLocation) {
        return
    }
}
