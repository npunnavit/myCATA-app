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
    let myCATAModel = MyCATAModel.sharedInstance
    let locationManager = CLLocationManager()
    let locationServices = LocationServices.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        let firstLaunch = defaults.bool(forKey: UserDefaultsKeys.firstLaunch)
        if firstLaunch {
            performSegue(withIdentifier: SegueIdentifiers.welcomeSegue, sender: nil)
        }
        
        self.navigationItem.title = "myCATA"
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(FavoritesTableViewController.dataDownloaded(notification:)), name: NSNotification.Name.StopDepartureDataDownloaded, object: nil)
        
        if CLLocationManager.locationServicesEnabled() {
            locationServices.delegate = myCATAModel
            myCATAModel.usersLocation = locationServices.location
        }
        
        tableView.register(UINib(nibName: "DepartureTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: ReuseIdentifier.departureHeaderView)
        
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Now Refreshing!")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshData(_ sender: UIRefreshControl) {
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
        
        headerView.configureHeader(routeName: title.routeTitle, stopName: title.stopTitle, section: section)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.departureCell, for: indexPath) as! DepartureTableViewCell
        let departure = myCATAModel.departure(forIndexPath: indexPath)
        let sdt = departure.scheduledDepartureTime!
        let edt = departure.estimatedDepartureTime!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        let scheduledTime = dateFormatter.string(from: sdt)
        let estimatedTime = dateFormatter.string(from: edt)
        let timeInterval = edt.timeIntervalSinceNow
        let remainingTime = Int(timeInterval / Constants.secondsInMinute)
        
        let isLate = edt > sdt && edt.timeIntervalSince(sdt) > Constants.secondsInMinute
        
        let section = indexPath.section
        let backgroundColor = myCATAModel.routeDetailFor(section: section).color.withAlphaComponent(FavoritesTableViewController.departureCellAlpha)
        
        cell.configureCell(scheduledTime: scheduledTime, estimatedTime: estimatedTime, remainingTime: "\(remainingTime) mins", isLate: isLate, backgroundColor: backgroundColor)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FavoritesTableViewController.departureCellHeight
    }
    
    //MARK: - DepartureTableHeaderViewDelegate Method
    func performRouteMapSegue(forSection section: Int) {
        let routeId = myCATAModel.routeDetailFor(section: section).routeId
        performSegue(withIdentifier: SegueIdentifiers.routeMapSegue, sender: routeId)
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
