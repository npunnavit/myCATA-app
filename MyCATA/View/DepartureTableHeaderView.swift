//
//  DepartureTableHeaderView.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/19/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import UIKit

class DepartureTableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var stopLabel: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func configureHeader(routeName: String, stopName: String) {
        routeLabel.text = routeName
        stopLabel.text = stopName
    }

}
