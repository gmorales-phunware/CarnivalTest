//
//  GuestRouteViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/19/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWMapKit

class GuestRouteViewController: UIViewController {
    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var toolbar: ToolbarView!
    
    weak var mapViewController: GuestMapViewController!
    
    var cancelButton: UIBarButtonItem!
    var routeListButton: UIBarButtonItem!
    var newPosition: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        assignViewControllers()
        configureView()
        showMap()
        NotificationCenter.default.addObserver(self, selector: #selector(showRoutingUI(notification:)), name: .plotRoute, object: nil)
        newPosition = CGFloat(70)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension GuestRouteViewController {
    func assignViewControllers() {
        for viewController in childViewControllers {
            if let viewController = viewController as? GuestMapViewController {
                mapViewController = viewController
                mapViewController.toolbar = toolbar
            }
        }
    }
    
    func configureView() {
        cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        routeListButton = UIBarButtonItem(title: "Directions", style: .plain, target: self, action: #selector(showRouteList))
    }
}

extension GuestRouteViewController {

    
    func showMap() {
        mapViewController.segmentedViewWillAppear()
        mapContainer.isHidden = false
        self.mapContainer.alpha = 1.0
    }
    
}

extension GuestRouteViewController {
    func routingMode() -> Bool {
        return navigationItem.leftBarButtonItem != nil
    }
    
    @objc func showRoutingUI(notification: Notification) {
        guard let _ : PWRoute = notification.object as? PWRoute else { return }
        // Set route to list view controller if we have feature to show route list
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = routeListButton
        
        if #available(iOS 11.0, *) {
            
        } else {
            UIView.animate(withDuration: 0.3) {
                self.mapContainer.transform = CGAffineTransform(translationX: 0, y: -self.newPosition)
                self.mapContainer.frame = CGRect(x: 0, y: 0, width: self.mapContainer.frame.width, height: self.mapContainer.frame.height + self.newPosition)
            }
        }
    }
    
    @objc func cancelButtonTapped() {
        if routingMode() {
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
            mapViewController.cancelRouting()
            mapViewController.mapView.trackingMode = .none
            UIView.animate(withDuration: 0.3) {
                self.mapContainer.transform = .identity
            }
            
        }
    }
    
    @objc func showRouteList() {
        if routingMode() {
            mapViewController.showRoutingList()
        }
    }
}
