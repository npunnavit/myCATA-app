//
//  DepartureTableViewCell.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/19/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import UIKit

class DepartureTableViewCell: UITableViewCell {

    @IBOutlet weak var scheduledTimeLabel: UILabel!
    @IBOutlet weak var estimatedTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    var scheduledTime : Date?
    var estimatedTime : Date?
    var remainingTime : TimeInterval?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(scheduledTime: String, estimatedTime: String, remainingTime: String, isLate: Bool, backgroundColor: UIColor = UIColor.clear) {
        scheduledTimeLabel.text = scheduledTime
        estimatedTimeLabel.text = estimatedTime
        remainingTimeLabel.text = remainingTime
        
        self.backgroundColor = backgroundColor
        estimatedTimeLabel.textColor = isLate ? UIColor.myCATARed : UIColor.myCATAGreen
    }
}
