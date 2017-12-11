//
//  SearchViewModel.swift
//  MyCATA
//
//  Created by Punnavit Akkarapitakchai on 12/10/17.
//  Copyright © 2017 Punnavit Akkarapitakchai. All rights reserved.
//

import Foundation

struct RouteGroup {
    var groupId : Int
    var groupName : String
    var routes : [RouteID]
}

class SearchViewModel {
    static let sharedInstance = SearchViewModel()
    let myCATAModel = MyCATAModel.sharedInstance
    
    var routeGroups : [[RouteID]]
    
    fileprivate init() {
        let defaults = UserDefaults.standard
        routeGroups = defaults.array(forKey: UserDefaultsKeys.routeGroups) as? [[RouteID]] ?? []
    }
    
    //Methods for Search Table View
    var numberOfSections : Int { return 2 }
    
    func numberOfRows(inSection section: Int) -> Int{
        if section == 0 {
            return routeGroups.count
        } else {
            return myCATAModel.numberOfRoutes
        }
    }
    
//    func group(forIndexPath indexPath: IndexPath) -> 
    
    func route(forIndexPath indexPath: IndexPath) -> RouteDetail {
        let newIndexPath = IndexPath(row: indexPath.row, section: 0)
        return myCATAModel.route(forIndexPath: newIndexPath)
    }
    
    //Handle route groups
    func isRouteGroup(routes: [RouteID]) -> Bool {
        for group in routeGroups {
            if group == routes {
                return true
            }
        }
        return false
    }
    
    func addRouteGroup(routes: [RouteID]) {
        let lastGroupId = routeGroups.last?.groupId ?? -1
        let groupId = lastGroupId + 1
        var groupName = String()
        for route in routes {
            let name = myCATAModel.routeShortNameFor(route: route)
            groupName.append("-\(name)")
        }
        groupName = String(groupName.dropFirst())
        let newGroup = RouteGroup(groupId: groupId, groupName: groupName, routes: routes)
        routeGroups.append(newGroup)
        updateUserDefaultsRouteGroups()
    }
    
    func removeRouteGroup(routes: [RouteID]) {
        for i in routeGroups.indices {
            if routeGroups[i] == routes {
                routeGroups.remove(at: i)
            }
        }
        updateUserDefaultsRouteGroups()
    }
    
    func updateUserDefaultsRouteGroups() {
        let defaults = UserDefaults.standard
        defaults.set(routeGroups, forKey: UserDefaultsKeys.routeGroups)
        defaults.synchronize()
    }
}
