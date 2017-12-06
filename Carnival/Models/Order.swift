//
//  Order.swift
//  Carnival
//
//  Created by Gabriel Morales on 11/3/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import Foundation

struct Order {
    var orderTitle = ""
    var orderDescription = ""
    var orderNumber = 0
}

extension Order {
    static let items = [first, second, third]
    static let first = Order(orderTitle: "Martini", orderDescription: "Gin and Vermouth, garnished with an olive.", orderNumber: 48)
    static let second = Order(orderTitle: "Cosmo", orderDescription: "Vodka, triple sec, cranberry juice, and fresh...", orderNumber: 150)
    static let third = Order(orderTitle: "Old Fashioned", orderDescription: "Cocktail made by muddling sugar with bitters, then adding alcohol, such as whiskey or brandy, and a twist of citrus rind. It is traditionally served in a short, round, tumbler-like glass, which is called an Old Fashioned glass, named after the drink.", orderNumber: 200)
}
