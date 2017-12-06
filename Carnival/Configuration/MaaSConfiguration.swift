//
//  MaaSConfiguration.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/19/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import Foundation
import PWLocation
import PWMapKit

protocol MaaSConfigurable:class, Equatable {
    var appID: String! { get set }
    var accessKey: String! { get set }
    var signatureKey: String! { get set }
}

class MaaSConfiguration: MaaSConfigurable {
    var appID: String!
    var accessKey: String!
    var signatureKey: String!
    var buildingID: Int!
    
    var managedLocationProvider: PWManagedLocationManager?
    var name: String?
    
    var loadedBuilding: PWBuilding?
    
    init(dictionary:[String: AnyObject]) {
        let maasConfig = dictionary["App"] as! [String: AnyObject]
        appID = String(describing: maasConfig["appId"]!)
        accessKey = String(describing: maasConfig["accessKey"]!)
        signatureKey = String(describing: maasConfig["signatureKey"]!)
        buildingID = dictionary["buildingId"]! as! Int
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
    }
    
    static func ==(lhs: MaaSConfiguration, rhs: MaaSConfiguration) -> Bool {
        return lhs.appID == rhs.appID && lhs.accessKey == rhs.accessKey && lhs.signatureKey == rhs.signatureKey && lhs.buildingID == rhs.buildingID
    }
    
    class func getDictionaryFromPlist(plist: String) -> [String: AnyObject]? {
        guard let path = Bundle.main.path(forResource: plist, ofType: "plist") else { return nil }
        let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject]
        return dict
    }
}
