//
//  ToolbarView.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/24/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit

class ToolbarView: UIToolbar {

    let flexibleBarSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let fixedBarSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        barTintColor = #colorLiteral(red: 0.9843137255, green: 0.9843137255, blue: 0.9882352941, alpha: 1)
        tintColor = AppColor.main.color()
        fixedBarSpace.width = 50
    }

}
