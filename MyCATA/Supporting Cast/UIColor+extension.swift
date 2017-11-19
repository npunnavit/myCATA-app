//
//  UIColor+extension.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/16/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(rgb: UInt32) {
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255
        let alpha : CGFloat = 1.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    var myCATAGreen : UIColor { return UIColor(rgb: 0x2cb673) }
    var myCATABlue : UIColor { return UIColor(rgb: 0x5ca8dc) }
    var myCATARed : UIColor { return UIColor(rgb: 0xcd3a34) }
    var myCATAYellow : UIColor { return UIColor(rgb: 0xf5ee79) }
    var myCATADarkGray : UIColor { return UIColor(rgb: 0x5a5b5f) }
    var myCATARausch : UIColor { return UIColor(rgb: 0xff4f55) }
    var myCATAHof : UIColor { return UIColor(rgb: 0x4c5052) }
    var myCATAFoggy : UIColor { return UIColor(rgb: 0xc7cbc5) }
    var myCATAKazan : UIColor { return UIColor(rgb: 0x006f7c) }
}
