//
//  RouteTableViewCell.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 12/9/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {

    @IBOutlet weak var routeIconImageView: UIImageView!
    @IBOutlet weak var routeNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(routeName: String, routeIcon: UIImage) {
        routeIconImageView.image = routeIcon
        routeNameLabel.text = routeName
    }

}
