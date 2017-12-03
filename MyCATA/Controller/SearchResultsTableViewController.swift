//
//  SearchResultsTableViewController.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 12/2/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {
    
    let myCATAModel = MyCATAModel.sharedInstance
    let searchResultsModel = SearchResultsViewModel()
    var routes : [RouteID]?
    var stop : StopID?
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let routes = routes, let stop = stop {
            searchResultsModel.configure(routes: routes, stop: stop)
        }
        
        //register nib
        tableView.register(UINib(nibName: "DepartureTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: ReuseIdentifier.departureHeaderView)
        tableView.register(UINib(nibName: "DepartureTableViewCell", bundle: nil), forCellReuseIdentifier: ReuseIdentifier.departureCell)
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(dataDownloaded(notification:)), name: NSNotification.Name.StopDepartureDataDownloaded, object: searchResultsModel)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateDepartureData()
        timer = Timer.scheduledTimer(timeInterval: Constants.TimeInterval.halfMinute, target: self, selector: #selector(updateDepartureData), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    @objc func dataDownloaded(notification: Notification) {
        let block = {
            self.tableView.reloadData()
        }
        DispatchQueue.main.async(execute: block)
    }
    
    @objc func updateDepartureData() {
        if let stop = stop {
            searchResultsModel.requestStopDeparture(at: stop)
        }
    }
    
    //MARK: - Configure View Controller
    func configure(routes: [RouteID], stop: StopID) {
        self.routes = routes
        self.stop = stop
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return searchResultsModel.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ReuseIdentifier.departureHeaderView) as! DepartureTableHeaderView
        let title = searchResultsModel.titleFor(section: section)
        
        headerView.configureHeader(routeName: title.routeTitle, stopName: title.stopTitle, section: section)
        
        let backgroundView = UIView(frame: headerView.frame)
        backgroundView.backgroundColor = UIColor.white
        headerView.backgroundView = backgroundView
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return FavoritesTableViewController.departureHeaderViewHeight
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResultsModel.numberOfRow(inSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.departureCell, for: indexPath) as! DepartureTableViewCell
        let departure = searchResultsModel.departure(forIndexPath: indexPath)
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
        let backgroundColor = searchResultsModel.routeDetailFor(section: section).color.withAlphaComponent(FavoritesTableViewController.departureCellAlpha)
        
        cell.configureCell(scheduledTime: scheduledTime, estimatedTime: estimatedTime, remainingTime: "\(remainingTime) mins", isLate: isLate, backgroundColor: backgroundColor)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FavoritesTableViewController.departureCellHeight
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
