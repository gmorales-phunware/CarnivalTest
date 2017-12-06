//
//  OrderDetail.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/20/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import Foundation

struct OrderDetail {
    var title = ""
    var subtitle = ""
}

extension OrderDetail {
    static let items = [main, ingredients, preparation, served, garnish, drinkware]
    static let main = OrderDetail(title: "Main Alcohol:",
                                  subtitle: "Whisky")
    static let ingredients = OrderDetail(title: "Ingredients:",
                                         subtitle: "1 1/2 oz Bourbon or Rye whiskey, 2 dashes Angostura bitters, 1 Sugar cube, Few dashes plain water.")
    static let preparation = OrderDetail(title: "Preparation:",
                                         subtitle: "Place sugar cube in old fashioned glass and saturate with bitters, add a dash of plain water. Muddle until dissolved. Fill the glass with ice cubes and add whiskey. Garnish with orange slice, and a cocktail cherry.")
    static let served = OrderDetail(title: "Served:",
                                    subtitle: "On the rocks; poured over ice.")
    static let garnish = OrderDetail(title: "Standard Garnish:",
                                     subtitle: "Orange slice, Cocktail cherry.")
    static let drinkware = OrderDetail(title: "Drinkware:",
                                       subtitle: "Old Fashioned Glass.")
}
