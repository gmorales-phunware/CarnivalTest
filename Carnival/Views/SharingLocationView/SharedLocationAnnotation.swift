//
//  SharedLocationAnnotation.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/19/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import MapKit
import PWMapKit

class SharedLocationAnnotation: MKPointAnnotation {

    var sharedLocation: PWSharedLocation!
    
    init(sharedLocation: PWSharedLocation) {
        super.init()
        self.sharedLocation = sharedLocation
    }
}
