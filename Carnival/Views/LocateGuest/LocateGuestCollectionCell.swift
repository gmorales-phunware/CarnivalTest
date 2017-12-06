//
//  LocateGuestCollectionCell.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/19/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit

class LocateGuestCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with title: String) {
        self.titleLabel.text = title
    }
}
