//
//  UIImage+Extension.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/24/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit

extension UIImage {
    func locateMe(tintColor: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 24, height: 24)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 13.53, y: 24))
        bezierPath.addLine(to: CGPoint(x: 13.44, y: 10.62))
        bezierPath.addLine(to: CGPoint(x: 0, y: 10.71))
        bezierPath.addLine(to: CGPoint(x: 24, y: 0))
        bezierPath.addLine(to: CGPoint(x: 13.53, y: 24))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 14.31, y: 9.74))
        bezierPath.addLine(to: CGPoint(x: 14.38, y: 19.85))
        bezierPath.addLine(to: CGPoint(x: 22.29, y: 1.7))
        bezierPath.addLine(to: CGPoint(x: 4.16, y: 9.81))
        bezierPath.addLine(to: CGPoint(x: 14.31, y: 9.74))
        bezierPath.close()
        bezierPath.miterLimit = 4
        
        tintColor.setFill()
        bezierPath.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func locateMeFilled(tintColor: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 22, height: 22)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 12.4, y: 22))
        bezierPath.addLine(to: CGPoint(x: 12.33, y: 9.74))
        bezierPath.addLine(to: CGPoint(x: 0, y: 9.81))
        bezierPath.addLine(to: CGPoint(x: 22, y: 0))
        bezierPath.addLine(to: CGPoint(x: 12.4, y: 22))
        bezierPath.close()
        bezierPath.miterLimit = 4
        
        tintColor.setFill()
        bezierPath.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func trackMe(tintColor: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 15, height: 26)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 6.98, y: 0))
        bezierPath.addLine(to: CGPoint(x: 8, y: 0))
        bezierPath.addLine(to: CGPoint(x: 8, y: 6.01))
        bezierPath.addLine(to: CGPoint(x: 6.98, y: 6.01))
        bezierPath.addLine(to: CGPoint(x: 6.98, y: 0))
        bezierPath.close()
        
        bezierPath.move(to: CGPoint(x: 7.44, y: 19.01))
        bezierPath.addLine(to: CGPoint(x: 0, y: 26))
        bezierPath.addLine(to: CGPoint(x: 7.39, y: 8.01))
        bezierPath.addLine(to: CGPoint(x: 15, y: 25.91))
        bezierPath.addLine(to: CGPoint(x: 7.44, y: 19.01))
        
        tintColor.setFill()
        bezierPath.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func scaledToMax(_ dimension: CGFloat) -> UIImage {
        
        // Get the size to scale the image to
        
        var new_size = self.size
        if size.width > size.height {
            let mod: CGFloat = size.height / size.width
            new_size = CGSize(width: dimension, height: CGFloat(dimension * mod))
        } else {
            let mod: CGFloat = size.width / size.height
            new_size = CGSize(width: CGFloat(dimension * mod), height: dimension)
        }
        
        // Open the context
        UIGraphicsBeginImageContext(new_size)
        
        // Render the image
        self.draw(in: CGRect(x: 0, y: 0, width: new_size.width, height: new_size.height))
        
        // Retrieve the image and end the render
        let new_image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return new_image ?? UIImage()
    }
}
