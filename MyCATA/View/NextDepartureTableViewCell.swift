//
//  NoDepartureTableViewCell.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 12/10/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import UIKit

class NextDepartureTableViewCell: UITableViewCell {

    @IBOutlet var nextDepartureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(nextDeparture: String) {
        nextDepartureLabel.text = nextDeparture
    }

}
