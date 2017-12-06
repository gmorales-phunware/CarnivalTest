//
//  Validate.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/24/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import Foundation
import PWMapKit

class Validate {
    class func isValidRoute(_ startPOI: PWPointOfInterest?, _ endPOI: PWPointOfInterest?) -> Bool {
        return startPOI != endPOI
    }
}
