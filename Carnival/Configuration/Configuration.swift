//
//  Configuration.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/19/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import Foundation
import UIKit
import PWCore
import PWEngagement

final class Configuration {
    static let sharedInstance = Configuration()
    
    var currentMaaSConfiguration: MaaSConfiguration!
    
    private lazy var defaultConfiguration: MaaSConfiguration? = {
        if let path = MaaSConfiguration.getDictionaryFromPlist(plist: "MaasConfiguration") {
            let configuration = MaaSConfiguration(dictionary: path)
            return configuration
        }
        
        return nil
    }()
    
    private init() {
        if let defaultConfiguration = defaultConfiguration {
            currentMaaSConfiguration = defaultConfiguration
        } else {
            fatalError("Unable to load any configuration. Please check the MaasConfiguration.plist for syntax")
        }
    }
    
    class func bootstrap() {
        guard let dict = MaaSConfiguration.getDictionaryFromPlist(plist: "MaasConfiguration") else { fatalError("Unable to load any configuration. Please check the MaasConfiguration.plist for syntax") }
        guard let maasConfigurationDictionary = dict["App"] as? [String : AnyObject],
            let appID = maasConfigurationDictionary["appId"] as? String,
            let accessKey = maasConfigurationDictionary["accessKey"] as? String,
            let signatureKey = maasConfigurationDictionary["signatureKey"] as? String else { fatalError("Please check the MaasConfiguration.plist") }
        
        PWCore.setApplicationID(appID, accessKey: accessKey, signatureKey: signatureKey)
        PWEngagement.start(withMaasAppId: appID, accessKey: accessKey, signatureKey: signatureKey, completion: nil)
    }
    
    class func appearence() {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)]
    }
}
