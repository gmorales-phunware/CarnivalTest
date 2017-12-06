//
//  SharingItem.swift
//  Carnival
//
//  Created by Gabriel Morales on 11/3/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit

let kSharingNotification = "kSharingNotification"

struct SharingItem {
    enum SharingType: Int {
        case location
        
        var title: String {
            switch self {
            case .location: return "location"
            }
        }
    }
    
    var title: String?
    var prefKey: String!
    var sharingType: SharingType!
    var selectedStatusChanged: (Bool) -> Void
}

extension SharingItem {
    static let sharingItems = [locationNotificationItem]
    
    static let locationNotificationItem = SharingItem(title: "Location Notification", prefKey: kSharingNotification, sharingType: .location) { (on:Bool) in
        if (on) {
            UserDefaults.standard.set(true, forKey: kSharingNotification)
        } else {
            UserDefaults.standard.set(false, forKey: kSharingNotification)
        }
    }
}
