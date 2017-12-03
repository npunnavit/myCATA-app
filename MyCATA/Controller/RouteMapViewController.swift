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

class BusAnnotation : MKPointAnnotation {
    let routeId : RouteID
    let vehicleId : VehicleID
    
    init(routeId: RouteID, vehicleId: VehicleID) {
        self.routeId = routeId
        self.vehicleId = vehicleId
    }
    
    init(vehicle: VehicleLocation) {
        self.routeId = vehicle.routeId
        self.vehicleId = vehicle.vehicleId
        super.init()
        self.coordinate = vehicle.location
    }
    
    convenience init(routeId: RouteID, vehicleId: VehicleID, coordinate: CLLocationCoordinate2D) {
        self.init(routeId: routeId, vehicleId: vehicleId)
        self.coordinate = coordinate
    }
}

class RouteMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var showStopPinsSwitch: UISwitch!
    @IBOutlet weak var zoomSegmentedControl: UISegmentedControl!
    
    let routeMapViewModel = RouteMapViewModel()
    let myCATAModel = MyCATAModel.sharedInstance
    let locationServices = LocationServices.sharedInstance
    var timer = Timer()
    
    var routes : [RouteID]?
    var stopPins = [StopPin]()
    var busAnnotations = [RouteID: [VehicleID: BusAnnotation]]()
    
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
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(RouteMapViewController.busDataDownloaded(notification:)), name: Notification.Name.VehicleLocationDataDownloaded, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
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
            routeMapViewModel.requestVehicles(forRoutes: routesId)
            scheduleBusLocationUpdate()
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
    
    @objc func busDataDownloaded(notification: Notification) {
        let block = {
            let userInfo = notification.userInfo
            if let routeId = userInfo!["RouteId"] as? RouteID {
                let vehicles = self.routeMapViewModel.vehiclesFor(route: routeId)!
                if self.busAnnotations[routeId] != nil {
                    //update annotation coordinate
                    for vehicle in vehicles {
                        let vehicleId = vehicle.vehicleId
                        let location = vehicle.location
                        UIView.animate(withDuration: 1, animations: {
                            self.busAnnotations[routeId]?[vehicleId]?.coordinate = location
                        }, completion:  { success in
                            if success {
                                // handle a successfully ended animation
                            } else {
                                // handle a canceled animation, i.e move to destination immediately
                                self.busAnnotations[routeId]?[vehicleId]?.coordinate = location
                            }
                        })
                    }
                } else {
                    //create new annotation
                    for vehicle in vehicles {
                        let vehicleId = vehicle.vehicleId
                        let busAnnotation = BusAnnotation(vehicle: vehicle)
                        self.mapView.addAnnotation(busAnnotation)
                        self.busAnnotations[routeId] = [vehicleId: busAnnotation]
                    }
                }
            }
            
        }
        DispatchQueue.main.async(execute: block)
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
    
    func annotationView(forBusAnnotation busAnnotation: BusAnnotation) -> MKAnnotationView {
        var view : MKAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifiers.busAnnotation) {
            dequeuedView.annotation = busAnnotation
            view = dequeuedView
        } else {
            view = MKAnnotationView(annotation: busAnnotation, reuseIdentifier: AnnotationIdentifiers.busAnnotation)
            view.isUserInteractionEnabled = false
        }
        
        let routeId = busAnnotation.routeId
        view.image = myCATAModel.routeIconFor(route: routeId)
        
        let size = CGSize(width: RouteMapViewController.busIconSize, height: RouteMapViewController.busIconSize)
        view.frame.size = size
        
        return view
    }
    
    //MARK: - bring bus annotion to front/back
    func bringAllBusAnnotationsToFront() {
//        for aBusAnnotation in allBusAnnotations() {
//            if let anAnnotationView = mapView.view(for: aBusAnnotation) {
//                anAnnotationView.superview?.bringSubview(toFront: anAnnotationView)
//            }
//        }
    }
    
    func sendAllBusAnnotationsToBack() {
//        for aBusAnnotation in allBusAnnotations() {
//            if let anAnnotationView = mapView.view(for: aBusAnnotation) {
//                anAnnotationView.superview?.sendSubview(toBack: anAnnotationView)
//            }
//        }
    }
    
    //MARK: - show/hide stops
    func showStopPins() {
        for aStopPin in stopPins {
            mapView.view(for: aStopPin)?.isHidden = false
        }
    }
    
    func hideStopPins() {
        for aStopPin in stopPins {
            mapView.view(for: aStopPin)?.isHidden = true
        }
    }
    
    //MARK: IBActions
    @IBAction func changeZoomRegion(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            if let userLocation = locationServices.location {
                centerMapAt(location: userLocation, withSpanDelta: RouteMapViewController.zoomedSpanDelta)
                sendAllBusAnnotationsToBack()
            }
        case 1:
            mapView.showAnnotations(stopPins, animated: true)
            bringAllBusAnnotationsToFront()
        default:
            assert(false, "Unhandled zoom segmented control case")
        }
    }
    
    @IBAction func toggleShowStopPins(_ sender: UISwitch) {
        if sender.isOn {
            showStopPins()
        } else {
            hideStopPins()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Micellaneous functions
    func allBusAnnotations() -> [BusAnnotation] {
        var allAnnotations = [BusAnnotation]()
        for (_, annotationByVehicle) in busAnnotations {
            for (_, anAnnotation) in annotationByVehicle {
                allAnnotations.append(anAnnotation)
            }
        }
        return allAnnotations
    }
    
    func scheduleBusLocationUpdate() {
        timer = Timer.scheduledTimer(timeInterval: Constants.TimeInterval.halfMinute, target: self, selector: #selector(updateBusLocation), userInfo: nil, repeats: true)
    }
    
    @objc func updateBusLocation() {
        if let routesId = routes {
            routeMapViewModel.requestVehicles(forRoutes: routesId)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case SegueIdentifiers.searchResultsSegue:
            let searchResultsViewController = segue.destination as! SearchResultsTableViewController
            let routeStop = sender as! (routesId: [RouteID], stopId: StopID)
            searchResultsViewController.configure(routes: routeStop.routesId, stop: routeStop.stopId)
        default:
            assert(false, "Unhandled Segue")
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = "Map"
        navigationItem.backBarButtonItem = backItem
    }
    

}

//MARK: - MKMapViewDelegate Methods
extension RouteMapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is StopPin:
            return annotationView(forPin: annotation as! StopPin)
        case is BusAnnotation:
            return annotationView(forBusAnnotation: annotation as! BusAnnotation)
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if showStopPinsSwitch.isOn {
            showStopPins()
        } else {
            hideStopPins()
        }
        zoomSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        switch view.annotation {
        case is StopPin:
            let stopPin = view.annotation as! StopPin
            let stopId = stopPin.stopId
            let routesId = routes
            performSegue(withIdentifier: SegueIdentifiers.searchResultsSegue, sender: (routesId, stopId))
        default:
            break
        }
    }
}

//MARK: - LocationServicesDelegate Methods
extension RouteMapViewController : LocationServicesDelegate {
    func updateUsersLocation(to newLocation: CLLocation) {
        return
    }
}
