//
//  OrderDetailCell.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/20/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit

class OrderDetailCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with detail: OrderDetail) {
        self.textLabel?.text = detail.title
        self.detailTextLabel?.text = detail.subtitle
    }
}
