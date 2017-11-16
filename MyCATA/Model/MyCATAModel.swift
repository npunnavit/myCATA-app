//
//  MyCATAModel.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 11/15/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation

class MyCATAModel {
    static let sharedInstance = MyCATAModel()
    
    let routeDetails : [RouteDetail]
    let routeNames : [String]
    let stops : [Stop]
    
    fileprivate init() {
        let fileManager = FileManager.default
        let bundle = Bundle.main
        let decoder = JSONDecoder()
        
        //Decode Route Data
        var path = bundle.path(forResource: FileName.routeData, ofType: "json")!
        var data = fileManager.contents(atPath: path)!
        do {
            routeDetails = try decoder.decode([RouteDetail].self, from: data)
            var _routeNames = [String]()
            for routeDetail in routeDetails {
                _routeNames.append(routeDetail.longName)
            }
            routeNames = _routeNames
        } catch let error as NSError {
            routeDetails = []
            routeNames = []
            print("Unresolved Error \(String(describing: error)))" )
        }
        
        //Decode Stop Data
        path = bundle.path(forResource: FileName.stopData, ofType: "json")!
        data = fileManager.contents(atPath: path)!
        do {
            stops = try decoder.decode([Stop].self, from: data)
        } catch let error as NSError {
            stops = []
            print("Unresolved Error \(String(describing: error)))" )
        }
        
    }
    
    
}
