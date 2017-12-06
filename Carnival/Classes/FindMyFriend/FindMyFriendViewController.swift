//
//  FindMyFriendViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/19/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWMapKit
import PWLocation

class FindMyFriendViewController: UIViewController {
    @IBOutlet weak var shareContainerView: UIView!
    @IBOutlet weak var shareLocationSwitch: UISwitch! {
        didSet {
            let locationEnabled = UserDefaults.standard.bool(forKey: locationSharingItem.prefKey)
            shareLocationSwitch.isOn = locationEnabled
        }
    }
    
    var locationSharingItem = SharingItem.locationNotificationItem
    var locationShareType = SharingItem.SharingType.location
    var sharedLocations = Set<PWSharedLocation>()
    var sharedLocationAnnotations = [String : SharedLocationAnnotation]()
    var annotationColors = [String : UIColor]()
    var mapView = PWMapView()
    var firstLocationAcquired = false
    
    let deviceTypeKey = "DeviceTypeKey"
    let deviceDisplayNameKey = "DeviceDisplayNameKey"
    
    var deviceDisplayName: String {
        get {
            if let displayName = UserDefaults.standard.object(forKey: deviceDisplayNameKey) as? String {
                return displayName
            }
            return "Friend"
        }
        set {
            mapView.sharedLocationDisplayName = newValue
            UserDefaults.standard.set(newValue, forKey: deviceDisplayNameKey)
        }
    }
    
    var deviceType: String {
        get {
            if let type = UserDefaults.standard.object(forKey: deviceTypeKey) as? String {
                return type
            }
            return UIDevice.current.name
        }
        set {
            mapView.sharedLocationUserType = newValue
            UserDefaults.standard.set(newValue, forKey: deviceTypeKey)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        view.addSubview(mapView)
        view.sendSubview(toBack: mapView)
        
        mapView.locationSharingDelegate = self
        mapView.sharedLocationDisplayName = deviceDisplayName
        mapView.sharedLocationUserType = deviceType
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Friend List", style: .plain, target: self, action: #selector(onFriendListButtonTapped(_:)))
        
        loadMap()
        configureMapConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.unregisterLocationManager()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Setup
extension FindMyFriendViewController {
    func loadMap() {
        let buildingID = Configuration.sharedInstance.currentMaaSConfiguration.buildingID
        PWBuilding.building(withIdentifier: buildingID!) { [weak self] (building, error) in
            guard let building = building else { return }
            self?.mapView.setBuilding(building)
            
            let managedLocationProvider = PWManagedLocationManager.init(buildingId: buildingID!)
            DispatchQueue.main.async {
                self?.mapView.register(managedLocationProvider)
                self?.mapView.startRetrievingSharedLocations()
            }
        }
    }
    
    func configureMapConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: shareContainerView.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
}

// MARK: - PWMapViewDelegate
extension FindMyFriendViewController: PWMapViewDelegate {
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
            let color = UIColor(red: .random(), green: .random(), blue: .random(), alpha: 1.0)
            dotView!.annotationColor = color
            annotationColors[sharedLocationAnnotation.sharedLocation.deviceId] = color
        }
        
        return dotView!
    }
}

// MARK: - PWLocationSharingDelegate
extension FindMyFriendViewController: PWLocationSharingDelegate {
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

// MARK: - IBActions
extension FindMyFriendViewController {
    
    @IBAction func locationSwitchStateChanged(_ sender: UISwitch) {
        if shareLocationSwitch.isOn == true {
            self.mapView.startSharingUserLocation()
        } else {
            self.mapView.stopSharingUserLocation()
        }
        
        let locationType = self.locationShareType
        locationSharingItem.selectedStatusChanged(shareLocationSwitch.isOn)
        debugPrint(locationType.title)
    }
    
    @IBAction func onFriendListButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "FindMyFriendListViewController", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == String(describing: FindMyFriendListViewController.self), let destination = segue.destination as? FindMyFriendListViewController {
            destination.mapView = mapView
            destination.sharedLocationAnnotations = sharedLocationAnnotations
            destination.sharedLocations = sharedLocations
        }
    }
}


extension CGFloat {
    
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
