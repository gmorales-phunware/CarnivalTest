//
//  UILabel+Extension.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/24/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit

extension UILabel {
    func configureHelper(with title: String) -> UILabel {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.text = title
        self.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.bold)
        self.textColor = AppColor.alternate.color()
        self.isAccessibilityElement = false
        return self
    }
}
