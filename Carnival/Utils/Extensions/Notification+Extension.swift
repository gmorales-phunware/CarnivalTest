//
//  Notification+Extension.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/24/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let startNavigatingRoute = Notification.Name("startNavigatingRoute")
    static let headingUpdated = Notification.Name("headingUpdated")
    static let updateIndoorLocation = Notification.Name("updateIndoorLocation")
    static let plotRoute = Notification.Name("PlotRouteNotification")
    static let dismissKeyboard = Notification.Name("ParkingDismissKeyboard")
    static let resetMapView = Notification.Name("ResetMapView")
}
