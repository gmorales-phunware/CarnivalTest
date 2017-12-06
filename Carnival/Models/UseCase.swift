//
//  UseCase.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/19/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit

struct Usecase {
    var title = ""
}

extension Usecase {
    static let items = [usecaseOne, usecaseTwo, usecaseThree, usecaseFour]
    static let usecaseOne = Usecase(title: "Employee Locates Guest")
    static let usecaseTwo = Usecase(title: "Guest Routes to POI")
    static let usecaseThree = Usecase(title: "Proximity Messaging")
    static let usecaseFour = Usecase(title: "Find My Friend")
}
