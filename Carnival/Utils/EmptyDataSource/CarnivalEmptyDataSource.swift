//
//  CarnivalEmptuDataSource.swift
//  Carnival
//
//  Created by Gabriel Morales on 11/5/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class CarnivalEmptyDataSource: NSObject, DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "img_emptystate")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16, weight: .bold),
                          NSAttributedStringKey.foregroundColor: AppColor.mainText.color()]
        
        return NSAttributedString(string: "\nOops!", attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16, weight: .medium),
                          NSAttributedStringKey.foregroundColor: AppColor.mainText.color()]
        
        return NSAttributedString(string: "\nLooks like something went wrong!\nPlease check if you have BLE enabled.\n", attributes: attributes)
    }
    
//    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
//        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16, weight: .medium),
//                          NSAttributedStringKey.foregroundColor: UIColor.white]
//        
//        return NSAttributedString(string: "RETRY", attributes: attributes)
//    }
    
    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        let capInset = UIEdgeInsets(top: 22, left: 22, bottom: 22, right: 22)
        let rectInsets = UIEdgeInsets(top: 0, left: -60, bottom: 0, right: -60)
        
        var imageName: String!
        if state == .normal {
            imageName = "live_empty_button"
        }
        if state == .highlighted {
            imageName = "live_empty_button_highlighter"
        }
        
        return UIImage(named: imageName)?.resizableImage(withCapInsets: capInset, resizingMode: .stretch).withAlignmentRectInsets(rectInsets)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 0
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 15
    }
}
