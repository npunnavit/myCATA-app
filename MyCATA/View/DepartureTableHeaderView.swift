//
//  DepartureTableHeaderView.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/19/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import UIKit

protocol DepartureTableHeaderViewDelegate {
    func performRouteMapSegue(forSection section: Int)
}

class DepartureTableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var stopLabel: UILabel!
    
    var section : Int!
    var delegate : DepartureTableHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeader)))
    }
    
    func configureHeader(routeName: String, stopName: String, section: Int) {
        routeLabel.text = routeName
        stopLabel.text = stopName
        self.section = section
    }
    
    @objc private func didTapHeader() {
        if let delegate = delegate, let section = section {
            delegate.performRouteMapSegue(forSection: section)
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    


}
