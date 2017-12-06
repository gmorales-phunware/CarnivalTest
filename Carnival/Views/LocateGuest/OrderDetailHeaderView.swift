//
//  OrderDetailHeaderView.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/20/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit

class OrderDetailHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var orderTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 2
        
    }
    
    func configure() {
        orderTitle.text = "Old Fashioned"
    }
}
