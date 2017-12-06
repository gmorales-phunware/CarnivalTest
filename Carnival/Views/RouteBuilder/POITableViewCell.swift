//
//  POITableViewCell.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/24/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWMapKit

class POITableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with poi: PWPointOfInterest) {
        if let image = poi.image {
            self.imageView?.image = image
            
            let size = CGSize(width: 32.0, height: 32.0)
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            let imageRect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
            self.imageView?.image?.draw(in: imageRect)
            self.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        if let title = poi.title {
            self.textLabel?.text = title
        }
        
        if let floorName = poi.floor.name {
            self.detailTextLabel?.text = floorName
        }
    }
}
