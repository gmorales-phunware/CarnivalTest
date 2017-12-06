//
//  POISearchable.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/24/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import Foundation
import PWMapKit

protocol POISearchable: class {
    
    var tableView: UITableView! { get set }
    var directoryPOIs: [PWPointOfInterest]! { get set }
    var sectionedPOIs: [String : [PWPointOfInterest]]! { get set }
    var sortedSectionedPOIKeys: [String]! { get set }
    
    func search(keyword: String?)
    func buildSectionedPOIs()
    func loadData()
}

extension POISearchable {
    
    func search(keyword: String?) {
        guard let building = Configuration.sharedInstance.currentMaaSConfiguration.loadedBuilding, let floors = building.floors as? [PWFloor] else {
            print("No building loaded")
            return
        }
        
        var pois = [PWPointOfInterest]()
        for floor in floors {
            if let floorPOIs = floor.pointsOfInterest(of: nil, containing: keyword) as? [PWPointOfInterest] {
                pois.append(contentsOf: floorPOIs)
            }
        }
        
        directoryPOIs = pois.sorted(by: {
            guard let title0 = $0.title, let title1 = $1.title else {
                return false
            }
            return title0.lowercased() < title1.lowercased()
        })
        
        buildSectionedPOIs()
        tableView.reloadData()
    }
    
    func buildSectionedPOIs() {
        sectionedPOIs.removeAll()
        for pointOfInterest in directoryPOIs {
            if let title = pointOfInterest.title, let firstChar = title.first {
                let firstCharString = String(describing: firstChar)
                if sectionedPOIs[firstCharString] != nil {
                    var sectionPOI = sectionedPOIs[firstCharString]!
                    sectionPOI.append(pointOfInterest)
                    sectionedPOIs[firstCharString] = sectionPOI
                } else {
                    sectionedPOIs[firstCharString] = [pointOfInterest]
                }
            }
        }
        
        sortedSectionedPOIKeys = sectionedPOIs.keys.sorted(by: {
            $0.lowercased() < $1.lowercased()
        })
    }
    
    func loadData() {
        search(keyword: nil)
    }
}
