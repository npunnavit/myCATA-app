//
//  FavoritesTableViewController.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/19/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import UIKit
import MapKit

//Favorite table view shows the departure times of user's favorites/daily bus at the closest stop based on user's location
//Beta App doesn't find closest stop. It gets data for Pattee Library stop
class FavoritesTableViewController: UITableViewController, DepartureTableHeaderViewDelegate {
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem!
    
    let myCATAModel = MyCATAModel.sharedInstance
    let locationServices = LocationServices.sharedInstance
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        let firstLaunch = defaults.bool(forKey: UserDefaultsKeys.firstLaunch)
        if firstLaunch {
            performSegue(withIdentifier: SegueIdentifiers.welcomeSegue, sender: nil)
        }
        
        self.navigationItem.title = "myCATA"
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(FavoritesTableViewController.dataDownloaded(notification:)), name: NSNotification.Name.StopDepartureDataDownloaded, object: myCATAModel)
        center.addObserver(self, selector: #selector(FavoritesTableViewController.userNotificationScheduled(notification:)), name: NSNotification.Name.ArrivalNotificationScheduled, object: myCATAModel)
        
        if CLLocationManager.locationServicesEnabled() {
            locationServices.delegate = myCATAModel
            myCATAModel.usersLocation = locationServices.location
        }
        
        //register nib
        tableView.register(UINib(nibName: "DepartureTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: ReuseIdentifier.departureHeaderView)
        tableView.register(UINib(nibName: "NextDepartureTableViewCell", bundle: nil), forCellReuseIdentifier: ReuseIdentifier.nextDepartureCell)
        tableView.register(UINib(nibName: "NoDepartureTableViewCell", bundle: nil), forCellReuseIdentifier: ReuseIdentifier.noDepartureCell)
    
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Now Refreshing!")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        forceUpdateDeparturesData()
        timer = Timer.scheduledTimer(timeInterval: Constants.TimeInterval.halfMinute, target: self, selector: #selector(forceUpdateDeparturesData), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(FavoritesTableViewController.userNotificationScheduled(notification:)), name: NSNotification.Name.ArrivalNotificationScheduled, object: myCATAModel)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.ArrivalNotificationScheduled, object: myCATAModel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshData(_ sender: UIRefreshControl) {
        myCATAModel.forceUpdateClosestStopForFavoriteRoutes()
    }
    
    @objc func forceUpdateDeparturesData() {
        myCATAModel.forceUpdateClosestStopForFavoriteRoutes()
    }
    
    @objc func dataDownloaded(notification: Notification) {
        let block = {
            self.tableView.reloadData()
            if self.refreshControl?.isRefreshing == true {
                self.refreshControl?.endRefreshing()
            }
        }
        DispatchQueue.main.async(execute: block)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return myCATAModel.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ReuseIdentifier.departureHeaderView) as! DepartureTableHeaderView
        let title = myCATAModel.titleFor(section: section)
        let routeIcon = myCATAModel.routeIconFor(route: title.routeId)
        
        headerView.configureHeader(routeName: title.routeTitle, stopName: title.stopTitle, section: section, routeIcon: routeIcon)
        headerView.delegate = self
        
        let backgroundView = UIView(frame: headerView.frame)
        backgroundView.backgroundColor = UIColor.white
        headerView.backgroundView = backgroundView
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return FavoritesTableViewController.departureHeaderViewHeight
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myCATAModel.numberOfRow(inSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let backgroundColor = myCATAModel.routeDetailFor(section: section).color.withAlphaComponent(FavoritesTableViewController.departureCellAlpha)
        
        switch myCATAModel.departureType(forSection: indexPath.section) {
        case .regular:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.departureCell, for: indexPath) as! DepartureTableViewCell
            let departure = myCATAModel.departure(forIndexPath: indexPath)
            let sdt = departure.scheduledDepartureTime!
            let edt = departure.estimatedDepartureTime!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            
            let scheduledTime = dateFormatter.string(from: sdt)
            let estimatedTime = dateFormatter.string(from: edt)
            let timeInterval = edt.timeIntervalSinceNow
            let minuteRemainingTime = Int((timeInterval.truncatingRemainder(dividingBy: Constants.TimeInterval.anHour) /  Constants.secondsInMinute))
            let hourRemainingTime = Int(timeInterval / Constants.TimeInterval.anHour)
            var remainingTime : String
            if hourRemainingTime > 0 {
                remainingTime = "\(hourRemainingTime) hr \(minuteRemainingTime) mins"
            } else {
                remainingTime = "\(minuteRemainingTime) mins"
            }
            
            let isLate = edt > sdt && edt.timeIntervalSince(sdt) > Constants.secondsInMinute
            
            cell.configureCell(scheduledTime: scheduledTime, estimatedTime: estimatedTime, remainingTime: remainingTime, isLate: isLate, backgroundColor: backgroundColor)
            return cell
        case .loop:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.nextDepartureCell, for: indexPath) as! NextDepartureTableViewCell
            let headwayDeparture = myCATAModel.headwayDeparture(forIndexPath: indexPath)
            cell.backgroundColor = backgroundColor
            cell.nextDepartureLabel.text = headwayDeparture.nextDeparture
            return cell
        case .noDeparture:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.noDepartureCell, for: indexPath)
            cell.backgroundColor = backgroundColor
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FavoritesTableViewController.departureCellHeight
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard myCATAModel.departureType(forSection: indexPath.section) == .regular else { return [] }
        
        let alertAction = UITableViewRowAction(style: .normal, title: "Alert", handler: { (action, indexPath) in
            self.alertRowAction(action: action, indexPath: indexPath)
        })
        
        return [alertAction]
    }
    
    //MARK: - DepartureTableHeaderViewDelegate Method
    func performRouteMapSegue(forSection section: Int) {
        let routeId = myCATAModel.routeDetailFor(section: section).routeId
        performSegue(withIdentifier: SegueIdentifiers.routeMapSegue, sender: routeId)
    }
    
    //MARK: - Table View Row Action Method
    func alertRowAction(action: UITableViewRowAction, indexPath: IndexPath) {
        myCATAModel.createArrivalAlert(forIndexPath: indexPath)
    }
    
    @objc func userNotificationScheduled(notification: Notification) {
        let userInfo = notification.userInfo!
        let title = userInfo["title"] as! String
        let message = userInfo["message"] as! String
        
        displayAlert(withTitle: title, message: message)
    }
    
    func displayAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Got it!", style: .default, handler: nil)
        
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case SegueIdentifiers.routeMapSegue:
            let routeMapViewController = segue.destination as! RouteMapViewController
            let routeId = sender as! RouteID
            routeMapViewController.configure(route: routeId)
        case SegueIdentifiers.settingsSegue:
            break
        case SegueIdentifiers.welcomeSegue:
            break
        case SegueIdentifiers.searchSegue:
            break
        default:
            assert(false, "Unhandled Segue")
        }
    }
}

enum departureCellType : String {
    case regular = "Regular"
    case loop = "Loop"
    case noDeparture = "No Departure"
}
