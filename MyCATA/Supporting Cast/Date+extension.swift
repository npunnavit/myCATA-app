//
//  Date+extension.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/22/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation

extension Date {
    init?(jsonDate: String) {
        let pattern = "\\/Date\\((\\d+)(([+-])(\\d{4}))\\)\\/"
        let regex = try! NSRegularExpression(pattern: pattern)
        guard let match = regex.firstMatch(in: jsonDate, range: NSMakeRange(0, jsonDate.utf16.count)) else { return nil }
        
        let dateString = (jsonDate as NSString).substring(with: match.range(at: 1))
        let timeStamp = Double(dateString)! / 1000.0
        self.init(timeIntervalSince1970: timeStamp)
    }
}
