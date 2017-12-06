//
//  OrderImageCell.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/20/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit

class OrderImageCell: UITableViewCell {
    
    @IBOutlet weak var orderImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure() {
        self.orderImageView.image = #imageLiteral(resourceName: "old_fashioned")
    }
}
