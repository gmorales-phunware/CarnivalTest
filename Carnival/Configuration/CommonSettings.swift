//
//  CommonSettings.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/24/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import PWMapKit


enum AppColor {
    case main, button, mainText, subtitleText, modalNav, textField, alternate
    
    func color() -> UIColor {
        switch self {
        case .main: return #colorLiteral(red: 0.02819324657, green: 0.3261851668, blue: 0.6127479076, alpha: 1)
        case .button: return #colorLiteral(red: 0.1649022698, green: 0.6432071328, blue: 0.8029385805, alpha: 1)
        case .mainText: return #colorLiteral(red: 0.7607843137, green: 0.7607843137, blue: 0.7607843137, alpha: 1)
        case .subtitleText: return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .modalNav: return #colorLiteral(red: 0.1184639707, green: 0.1185882017, blue: 0.118483223, alpha: 1)
        case .textField: return #colorLiteral(red: 0.803833425, green: 0.8039723635, blue: 0.8038246036, alpha: 1)
        case .alternate: return #colorLiteral(red: 0.801287353, green: 0.0002524638257, blue: 0.1987538934, alpha: 1)
        }
    }
}


class CommonSettings: NSObject {
    static func imageFromDirection(direction: PWRouteInstructionDirection) -> UIImage {
        switch direction {
        case .straight: return #imageLiteral(resourceName: "straight")
        case .left: return #imageLiteral(resourceName: "sharpleft")
        case .right: return #imageLiteral(resourceName: "sharpright")
        case .bearLeft: return #imageLiteral(resourceName: "slightleft")
        case .bearRight: return #imageLiteral(resourceName: "slightright")
        case .elevatorUp: return #imageLiteral(resourceName: "elevator_up")
        case .elevatorDown: return #imageLiteral(resourceName: "elevator_down")
        case .stairsUp: return #imageLiteral(resourceName: "stairs_up")
        case .stairsDown: return #imageLiteral(resourceName: "stairs_down")
        default: return UIImage()
        }
    }
}
