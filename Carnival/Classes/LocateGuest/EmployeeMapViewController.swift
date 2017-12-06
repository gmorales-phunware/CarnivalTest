//
//  EmployeeMapViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 11/3/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWMapKit
import PWLocation

class EmployeeMapViewController: BaseViewController {

    @IBOutlet weak var orderContainerView: UIView!
    @IBOutlet weak var orderNumberLabel: UILabel! {
        didSet {
            guard let orderNumber = selectedOrder?.orderNumber else { fatalError("Invalid order number") }
            orderNumberLabel.text = "\(orderNumber)"
        }
    }
    
    var sharedLocations = Set<PWSharedLocation>()
    var sharedLocationAnnotations = [String : SharedLocationAnnotation]()
    var annotationColors = [String : UIColor]()
    var selectedOrder: Order?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        view.addSubview(mapView)
        view.sendSubview(toBack: mapView)
        mapView.isHidden = false
        
        mapView.locationSharingDelegate = self
        mapView.sharedLocationUserType = "Employee"
        mapView.sharedLocationDisplayName = "Carnival Employee 1"
        
        loadMap()
        configureMapConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clearSharedLocations()
    }
}

// MARK: - Setup
// As an employee, you do not want to share your location with guests. You only need to retrieve shared locations by customers.
// Ideally you only show the location based on an guest order, this order would need to inclide its shareLocationUserType and sharedLocationDisplayName to filter through PWSharedLocations
extension EmployeeMapViewController {
    func loadMap() {
        let buildingID = Configuration.sharedInstance.currentMaaSConfiguration.buildingID
        PWBuilding.building(withIdentifier: buildingID!) { [weak self] (building, error) in
            guard let building = building else { return }
            self?.mapView.setBuilding(building)
            
            let managedLocationProvider = PWManagedLocationManager.init(buildingId: buildingID!)
            DispatchQueue.main.async {
                self?.mapView.register(managedLocationProvider)
                
                // An employee does not need to share its location with the customer.
                // An employee will be able to see his location on the map via blue dot.
                self?.mapView.startRetrievingSharedLocations()
            }
        }
    }
    
    func configureMapConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: orderContainerView.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
}

// MARK: - PWMapViewDelegate
extension EmployeeMapViewController: PWMapViewDelegate {
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
    
    func clearSharedLocations() {
        self.mapView.stopRetrievingSharedLocations()
        sharedLocations.removeAll()
        sharedLocationAnnotations.removeAll()
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

// MARK: - PWLocationSharingDelegate
extension EmployeeMapViewController: PWLocationSharingDelegate {
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
