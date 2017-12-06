//
//  CustomerOrderConfirmationViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 11/3/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWMapKit

class CustomerOrderConfirmationViewController: BaseViewController {
    
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var orderNumberLabel: UILabel!
    
    var sharedLocations = Set<PWSharedLocation>()
    var sharedLocationAnnotations = [String : SharedLocationAnnotation]()
    var annotationColors = [String : UIColor]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let orders = Order.items
        var orderNumbers = [Int]()
        for order in orders {
            orderNumbers.append(order.orderNumber)
        }
        
        let orderNumber = orderNumbers.random()
        orderNumberLabel.text = "\(orderNumber)"

        // In order for sharing location to work, we need to have a map view and blue dot.
        // In this case, since we are not showing a map view and customer is only sharing location but not fetching,
        // We need to add a map view and then hide it. ¯\_(ツ)_/¯
        // Location share only works while being on the map view. Meaning, this screen will have to remain shown if user wants to show location.
        // If user moves away from this view, user's location will remain on employee view for ~2-5 minutes. (This is a current limitation with mapping servers)
        mapView.delegate = self
        mapContainerView.addSubview(mapView)
        mapView.isHidden = true
        
        // Shared Location only returns 2 strings.
        // Location User Type and Location Display Name.
        // For POC purposes, just assigning a random order number.
        mapView.locationSharingDelegate = self
        mapView.sharedLocationUserType = UIDevice.current.name
        mapView.sharedLocationDisplayName = "Order # \(orderNumber)"
        
        loadMap()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // This doesn't really work, but ideally we would need to deallocate the entire map view.
        self.mapView.stopSharingUserLocation()
    }
}

extension CustomerOrderConfirmationViewController {
    func loadMap() {
        let buildingID = Configuration.sharedInstance.currentMaaSConfiguration.buildingID
        PWBuilding.building(withIdentifier: buildingID!) { [weak self] (building, error) in
            guard let building = building else { return }
            self?.mapView.setBuilding(building)
            
            let managedLocationProvider = PWManagedLocationManager.init(buildingId: buildingID!)
            DispatchQueue.main.async {
                self?.mapView.register(managedLocationProvider)
                
                // A customer does not need to fetch other user's locations.
                self?.mapView.startSharingUserLocation()
            }
        }
    }
}

extension CustomerOrderConfirmationViewController: PWLocationSharingDelegate {
    func didUpdate(_ sharedLocations: Set<PWSharedLocation>!) {
        self.sharedLocations = sharedLocations
        
        for updatedSharedLocation in sharedLocations {
            if let annotation = sharedLocationAnnotations[updatedSharedLocation.deviceId] {
                annotation.sharedLocation = updatedSharedLocation
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5, animations: {
                        annotation.title = "\(updatedSharedLocation.displayName!) (\(updatedSharedLocation.userType!))"
                        annotation.coordinate = updatedSharedLocation.location
                    })
                }
            }
        }
        
        NotificationCenter.default.post(name: .didUpdateAnnotation, object: nil)
    }
    
    func didAdd(_ addedSharedLocations: Set<PWSharedLocation>!) {
        for addedSharedLocation in addedSharedLocations {
            DispatchQueue.main.async { [weak self] in
                
                guard let displayName = addedSharedLocation.displayName,
                    let userType = addedSharedLocation.userType else { return }
                let annotation = SharedLocationAnnotation(sharedLocation: addedSharedLocation)
                annotation.title = "\(displayName) \(userType)"
                annotation.coordinate = addedSharedLocation.location
                
                self?.sharedLocationAnnotations[addedSharedLocation.deviceId] = annotation
                self?.mapView.add(annotation)
            }
        }
    }
    
    func didRemove(_ removedSharedLocations: Set<PWSharedLocation>!) {
        for removedSharedLocation in removedSharedLocations {
            DispatchQueue.main.async { [weak self] in
                if let annotation = self?.sharedLocationAnnotations[removedSharedLocation.deviceId] {
                    self?.mapView.remove(annotation)
                    self?.sharedLocationAnnotations.removeValue(forKey: removedSharedLocation.deviceId)
                }
            }
        }
    }
}

extension CustomerOrderConfirmationViewController: PWMapViewDelegate {
    func mapView(_ mapView: PWMapView!, locationManager: PWLocationManager!, didUpdateIndoorUserLocation userLocation: PWIndoorLocation!) {
        if !firstLocationAcquired {
            firstLocationAcquired = true
            mapView.trackingMode = .follow
            mapView.trackingMode = .none
        }
    }
    
    func mapView(_ mapView: MKMapView!, viewFor annotation: MKAnnotation!) -> MKAnnotationView! {
        var annotationView = MKAnnotationView()
        
        if let annotation = annotation as? SharedLocationAnnotation {
            annotationView = sharedLocationAnnotationView(sharedLocationAnnotation: annotation, mapView: mapView)
        }
        
        return annotationView
    }
    
    func sharedLocationAnnotationView(sharedLocationAnnotation: SharedLocationAnnotation, mapView: MKMapView) -> SharedLocationAnnotationView {
        var dotView = mapView.dequeueReusableAnnotationView(withIdentifier: sharedLocationAnnotation.sharedLocation.deviceId) as? SharedLocationAnnotationView
        
        if dotView == nil {
            dotView = SharedLocationAnnotationView(annotation: sharedLocationAnnotation, reuseIdentifier: sharedLocationAnnotation.sharedLocation.deviceId)
            if let title = sharedLocationAnnotation.title {
                dotView!.addFloatingText(title)
            }
        }
        
        if let color = annotationColors[sharedLocationAnnotation.sharedLocation.deviceId] {
            dotView!.annotationColor = color
        } else {
            let color = #colorLiteral(red: 0.02819324657, green: 0.3261851668, blue: 0.6127479076, alpha: 1)
            dotView!.annotationColor = color
            annotationColors[sharedLocationAnnotation.sharedLocation.deviceId] = color
        }
        
        return dotView!
    }
}

extension Array {
    func random() -> Element {
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}
