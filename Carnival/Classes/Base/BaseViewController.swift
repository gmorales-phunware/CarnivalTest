//
//  BaseViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/19/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWMapKit

class BaseViewController: UIViewController {
    
    fileprivate let configurationManager = Configuration.sharedInstance
    var selectedPOI: PWPointOfInterest?
    var mapView = PWMapView()
    var sectionedPOIs: [String : [PWPointOfInterest]]!
    var sortedSectionedPOIKeys: [String]!
    var firstLocationAcquired = false
    
    let deviceTypeKey = "DeviceTypeKey"
    let deviceDisplayNameKey = "DeviceDisplayNameKey"
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sectionedPOIs = [String : [PWPointOfInterest]]()
    }
    
    func animate(constraint: NSLayoutConstraint, toConstant constant: CGFloat, withDuration duration: TimeInterval) {
        constraint.constant = constant
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
}

extension BaseViewController: UIViewControllerTransitioningDelegate {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
