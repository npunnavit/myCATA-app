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
    
    static let myCATAGreen = UIColor(rgb: 0x2cb673)
    static let myCATABlue = UIColor(rgb: 0x5ca8dc)
    static let myCATARed = UIColor(rgb: 0xcd3a34)
    static let myCATAYellow = UIColor(rgb: 0xf5ee79)
    static let myCATADarkGray = UIColor(rgb: 0x5a5b5f)
    static let myCATARausch = UIColor(rgb: 0xff4f55)
    static let myCATAHof = UIColor(rgb: 0x4c5052)
    static let myCATAFoggy = UIColor(rgb: 0xc7cbc5)
    static let myCATAKazan = UIColor(rgb: 0x006f7c)
}
