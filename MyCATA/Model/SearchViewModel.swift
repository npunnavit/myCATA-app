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
    let sharedInstance = SearchViewModel()
    let myCATAModel = MyCATAModel.sharedInstance
    
    var routeGroups : [RouteGroup]
    
    fileprivate init() {
        let defaults = UserDefaults.standard
        routeGroups = defaults.array(forKey: UserDefaultsKeys.routeGroups) as? [RouteGroup] ?? []
    }
    
    //Methods for Search Table View
    var numberOfSections : Int { return 2 }
    
    func numberOfRows(inSection section: Int) {
        
    }
}
