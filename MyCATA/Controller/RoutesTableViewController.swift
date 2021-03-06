//
//  RouteTableViewController.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/16/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import UIKit

class RoutesTableViewController: UITableViewController {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    let myCATAModel = MyCATAModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Route"
        self.navigationItem.prompt = "Select up to 3 routes"
        
        for indexPath in myCATAModel.getFavoriteIndices() {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
        }
        
        //register nib
        tableView.register(UINib(nibName: "RouteTableViewCell", bundle: nil), forCellReuseIdentifier: ReuseIdentifier.routeCell)
        
        updateDoneButton()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myCATAModel.numberOfRoutes
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.routeCell, for: indexPath) as! RouteTableViewCell
        
        //configure cell
        let routeDetail = myCATAModel.route(forIndexPath: indexPath)
        let routeName = routeDetail.longName
        let routeIcon = myCATAModel.routeIconFor(route: routeDetail.routeId)
        cell.configureCell(routeName: routeName, routeIcon: routeIcon)
        
        if myCATAModel.isFavorite(indexPath: indexPath) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchTableViewController.routeCellHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if myCATAModel.isFavorite(indexPath: indexPath) {
                myCATAModel.removeFromFavorite(indexPath: indexPath)
                cell.accessoryType = .none
            } else {
                if myCATAModel.addToFavorite(indexPath: indexPath) {
                    cell.accessoryType = .checkmark
                }
            }
        }
        
        updateDoneButton()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //enable when user select at least one favorites
    func updateDoneButton() {
        if myCATAModel.favorites.isEmpty {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
