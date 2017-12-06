//
//  TrackingModeView.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/24/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWMapKit

class TrackingModeView: UIBarButtonItem {
    fileprivate var mapView: PWMapView!
    var noTrackingButton: UIButton!
    var trackingFollowButton: UIButton!
    var trackingFollowWithHeadingButton: UIButton!
    
    convenience init(withMapView mapView: PWMapView) {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        self.init(customView: containerView)
        self.mapView = mapView
        setupButtons()
        updateButtonState(animated: false)
    }
    
    init(customView: UIView) {
        super.init()
        self.customView = customView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension TrackingModeView {
    func setupButtons() {
        noTrackingButton = UIButton(type: .system)
        noTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        noTrackingButton.tintColor = AppColor.main.color()
        noTrackingButton.backgroundColor = .clear
        noTrackingButton.setImage(UIImage().locateMe(tintColor: noTrackingButton.tintColor), for: .normal)
        noTrackingButton.isHidden = true
        noTrackingButton.addTarget(self, action: #selector(locateAndTrackIndoorUser), for: .touchUpInside)
        self.customView?.addSubview(noTrackingButton)
        addConstaints(toButton: noTrackingButton)
        
        trackingFollowButton = UIButton(type: .custom)
        trackingFollowButton.translatesAutoresizingMaskIntoConstraints = false
        trackingFollowButton.backgroundColor = .clear
        trackingFollowButton.setImage(UIImage().locateMeFilled(tintColor: noTrackingButton.tintColor), for: .normal)
        trackingFollowButton.setImage(UIImage().locateMeFilled(tintColor: noTrackingButton.tintColor), for: .highlighted)
        trackingFollowButton.isHidden = true
        trackingFollowButton.addTarget(self, action: #selector(locateAndTrackIndoorUserWithHeading), for: .touchUpInside)
        self.customView?.addSubview(trackingFollowButton)
        addConstaints(toButton: trackingFollowButton)
        
        trackingFollowWithHeadingButton = UIButton(type: .custom)
        trackingFollowWithHeadingButton.translatesAutoresizingMaskIntoConstraints = false
        trackingFollowWithHeadingButton.backgroundColor = .clear
        trackingFollowWithHeadingButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 1, bottom: 0, right: 0)
        trackingFollowWithHeadingButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        trackingFollowWithHeadingButton.setImage(UIImage().trackMe(tintColor: noTrackingButton.tintColor), for: .normal)
        trackingFollowWithHeadingButton.setImage(UIImage().trackMe(tintColor: noTrackingButton.tintColor), for: .highlighted)
        trackingFollowWithHeadingButton.isHidden = true
        trackingFollowWithHeadingButton.addTarget(self, action: #selector(disableIndoorTracking), for: .touchUpInside)
        self.customView?.addSubview(trackingFollowWithHeadingButton)
        addConstaints(toButton: trackingFollowWithHeadingButton)
    }
    
    func addConstaints(toButton button: UIButton) {
        button.leftAnchor.constraint(equalTo: self.customView!.leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: self.customView!.rightAnchor).isActive = true
        button.topAnchor.constraint(equalTo: self.customView!.topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: self.customView!.bottomAnchor).isActive = true
        
    }
    
    func updateButtonState(animated: Bool) {
        var buttonToDisplay: UIButton!
        let animation: TimeInterval = animated ? 0.3 : 0
        var buttonsToHide:[UIButton] = []
        
        switch self.mapView.trackingMode {
        case .none:
            buttonToDisplay = self.noTrackingButton
            buttonsToHide = [self.trackingFollowButton, self.trackingFollowWithHeadingButton]
            
        case .follow:
            buttonToDisplay = self.trackingFollowButton
            buttonsToHide = [self.noTrackingButton, self.trackingFollowWithHeadingButton]
            
        case .followWithHeading:
            buttonToDisplay = self.trackingFollowWithHeadingButton
            buttonsToHide = [self.noTrackingButton, self.trackingFollowButton]
        }
        
        UIView.animate(withDuration: animation) {
            for button in buttonsToHide {
                button.alpha = 0.0
                button.isHidden = true
            }
            
            buttonToDisplay.isHidden = false
            buttonToDisplay.alpha = 1
            buttonToDisplay.transform = CGAffineTransform.identity
        }
    }
}

extension TrackingModeView {
    @objc func disableIndoorTracking() {
        self.mapView.trackingMode = .none
    }
    
    @objc func locateAndTrackIndoorUser() {
        self.mapView.trackingMode = .follow
    }
    
    @objc func locateAndTrackIndoorUserWithHeading() {
        self.mapView.trackingMode = .followWithHeading
    }
}
