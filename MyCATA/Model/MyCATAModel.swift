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
    
    //MARK: - Properties
    let routeDetails : [RouteDetail]
    let routeNames : [String]
    let routeIdToIndex : [Int: Int]
    let stops : [Stop]
    var favorites : [Int] = []
    
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
            var _routeIdToIndex = [Int: Int]()
            var index = 0
            for routeDetail in routeDetails {
                _routeNames.append(routeDetail.longName)
                _routeIdToIndex[routeDetail.routeId] = index
                index += 1
            }
            routeNames = _routeNames
            routeIdToIndex = _routeIdToIndex
        } catch let error as NSError {
            routeDetails = []
            routeNames = []
            routeIdToIndex = [:]
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
    
    //MARK: - Support for TableView
    var numberOfRoutes : Int { return routeDetails.count }
    
    func route(forIndexPath indexPath: IndexPath) -> RouteDetail {
        let index = indexPath.row
        return routeDetails[index]
    }
    
    func routeName(atIndexPath indexPath: IndexPath) -> String {
        let index = indexPath.row
        return routeNames[index]
    }
    
    func isFavorite(indexPath: IndexPath) -> Bool {
        let id = route(forIndexPath: indexPath).routeId
        return favorites.contains(id)
    }
    
    func addToFavorite(indexPath: IndexPath) -> Bool {
        guard favorites.count < 3 else { return false }
        let id = route(forIndexPath: indexPath).routeId
        favorites.append(id)
        return true
    }
    
    func removeFromFavorite(indexPath: IndexPath) {
        let id = route(forIndexPath: indexPath).routeId
        if let index = favorites.index(of: id) {
            favorites.remove(at: index)
        }
    }
    
    func getFavoriteIndices() -> [IndexPath] {
        var indices = [IndexPath]()
        for id in favorites {
            if let index = routeIdToIndex[id] {
                let indexPath = IndexPath(row: index, section: 1)
                indices.append(indexPath)
            }
        }
        return indices
    }
}
