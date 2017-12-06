//
//  CustomPresentationController.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/19/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit

class CustomPresentationController: UIPresentationController {
    lazy var dimmingView: UIView = {
        let instanceView = UIView()
        instanceView.frame = self.containerView!.bounds
        instanceView.backgroundColor = UIColor(white: 0, alpha: 0.55)
        return instanceView
    }()
    
    override func presentationTransitionWillBegin() {
        guard
            let presentedView = self.presentedViewController.view,
            let containerView = containerView
            else {return}
        
        presentedView.layer.shadowColor = UIColor.black.cgColor
        presentedView.layer.shadowOffset = CGSize(width: 0, height: 10)
        presentedView.layer.shadowRadius = 10
        presentedView.layer.shadowOpacity = 0.5
        
        self.dimmingView.frame = containerView.bounds
        self.dimmingView.alpha = 0
        self.containerView?.addSubview(self.dimmingView)
        
        let touchGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        touchGesture.delegate = self
        self.dimmingView.addGestureRecognizer(touchGesture)
        
        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { (context) in
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            self.dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { (context) in
                self.dimmingView.alpha = 0
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            self.dimmingView.removeFromSuperview()
        }
    }
    
    override var frameOfPresentedViewInContainerView : CGRect {
        guard let containerFrame = self.containerView?.frame else {return CGRect()}
        let height = containerFrame.height * 0.75
        let frame: CGRect
        if self.presentedViewController is MapFloorSelectorViewController {
            self.presentedViewController.view.roundCorners([.topLeft, .topRight], radius: 10)
            frame = CGRect(x: 0, y: containerFrame.height - height, width: containerFrame.width, height: height)
        } else {
            frame = CGRect(x: 0, y: 0, width: containerFrame.width, height: containerFrame.height)
        }
        return frame
    }
    
    override func containerViewWillLayoutSubviews() {
        guard let bounds = self.containerView?.bounds else {return}
        self.dimmingView.frame = bounds
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
}

extension CustomPresentationController: UIGestureRecognizerDelegate {
    
     @objc func handleTap(_ gesture: UIGestureRecognizer) {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}
