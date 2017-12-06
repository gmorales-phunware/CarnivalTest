//
//  PWEngagement+Extension.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/30/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import Foundation
import PWEngagement
import PWCore

extension PWEngagement {
    class func monitoredZones() -> [PWMEGeozone] {
        var monitoredZones = [PWMEZone]()
        
        if let zones = PWEngagement.geozones() {
            monitoredZones = zones.filter { (zone) -> Bool in
                return (zone as! PWMEGeozone).monitored
            } as! [PWMEZone]
        }
        return monitoredZones as! [PWMEGeozone]
    }
    
    class func insideZones() -> [PWMEGeozone] {
        var insideZones = [PWMEZone]()
        
        if let zones = PWEngagement.geozones() {
            insideZones = zones.filter { (zone) -> Bool in
                return (zone as! PWMEGeozone).inside
            } as! [PWMEZone]
        }
        
        return insideZones as! [PWMEGeozone]
    }
}
