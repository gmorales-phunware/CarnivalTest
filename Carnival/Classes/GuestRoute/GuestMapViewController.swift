//
//  GuestMapViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/24/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWMapKit
import PWLocation

class GuestMapViewController: BaseViewController {

    let manager = Configuration.sharedInstance
    var toolbar: ToolbarView!
    var trackingModeView: TrackingModeView!
    var turnByTurnView: TurnByTurnView!
    
    lazy var floorSelectBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(image: UIImage(named:"floor"), style: .plain, target: self, action:#selector(selectFloor))
        return barButton
    }()
    
    lazy var routeSelectBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(image: #imageLiteral(resourceName: "navigation"), style: .plain, target: self, action: #selector(presentStandardRouteBuilder))
        return barButton
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        view.addSubview(mapView)
        view.sendSubview(toBack: mapView)
        configureMapConstraints()
        loadMap()
        trackingModeView = TrackingModeView(withMapView: self.mapView)
        
        configureTBT()
        
        NotificationCenter.default.addObserver(self, selector: #selector(startRoute(notification:)), name: .startNavigatingRoute, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notifyShowRoute(notification:)), name: .plotRoute, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reset(notification:)), name: .resetMapView, object: nil)
    }
    
    func segmentedViewWillAppear() {
        configureToolbar()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.unregisterLocationManager()
    }
}


// MARK: - Setup
extension GuestMapViewController {
    
    func configureTBT() {
        turnByTurnView = TurnByTurnView()
        turnByTurnView.translatesAutoresizingMaskIntoConstraints = false
        turnByTurnView.delegate = self
        self.view.addSubview(turnByTurnView)
        
        self.turnByTurnView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        self.turnByTurnView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.turnByTurnView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.turnByTurnView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        showRouteInstructions(show: false)
    }
    
    func loadMap() {
        let buildingID = Configuration.sharedInstance.currentMaaSConfiguration.buildingID
        PWBuilding.building(withIdentifier: buildingID!) { [weak self] (building, error) in
            guard let building = building else { return }
            self?.manager.currentMaaSConfiguration.loadedBuilding = building
            self?.mapView.setBuilding(building)
            
            
            let managedLocationProvider = PWManagedLocationManager.init(buildingId: buildingID!)
            DispatchQueue.main.async {
                self?.mapView.register(managedLocationProvider)
            }
        }
    }
    
    func configureMapConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    func configureToolbar() {
        let fixedSpace = toolbar.fixedBarSpace
        let flexSpace = toolbar.flexibleBarSpace
        
        toolbar.setItems([flexSpace, self.trackingModeView, flexSpace, routeSelectBarButton, fixedSpace, floorSelectBarButton, flexSpace], animated: true)
    }
}


// MARK: - TurnByTurnDelegate
extension GuestMapViewController: TurnByTurnDelegate {
    func route(route: PWRoute, changeRouteInstruction instruction: PWRouteInstruction) {
        self.mapView.setRouteManeuver(instruction)
    }
}


// MARK: - FloorChangeable
extension GuestMapViewController: FloorChangeable {
    func changeFloor(to floor: PWFloor) {
        mapView.setFloor(floor)
    }
}


// MARK: - PWMapViewDelegate
extension GuestMapViewController: PWMapViewDelegate {
    func mapView(_ mapView: PWMapView!, locationManager: PWLocationManager!, didUpdateIndoorUserLocation userLocation: PWIndoorLocation!) {
        if !firstLocationAcquired {
            firstLocationAcquired = true
            mapView.trackingMode = .follow
        }
        NotificationCenter.default.post(name: .updateIndoorLocation, object: userLocation)
    }
    
    func mapView(_ mapView: PWMapView!, didUpdate heading: CLHeading!) {
        NotificationCenter.default.post(name: .headingUpdated, object: heading)
    }
    
    func mapView(_ mapView: PWMapView!, didSelect view: PWBuildingAnnotationView!, with poi: PWPointOfInterest!) {
        if self.mapView.currentRoute == nil {
            self.mapView.deselectPoint(poi, animated: false)
            showRouteBuilder(with: poi)
        }
    }
    
    func mapView(_ mapView: PWMapView!, didDeselect view: PWBuildingAnnotationView!, with poi: PWPointOfInterest!) {
        resetMapView()
    }
    
    func mapView(_ mapView: PWMapView!, didChange mode: PWTrackingMode) {
        self.trackingModeView.updateButtonState(animated: true)
    }
}


// MARK: - RouteDelegate
extension GuestMapViewController: RouteDelegate {
    func deselectSelectedPOI(poi: PWPointOfInterest) {
        resetMapView()
        mapView.deselectPoint(poi, animated: true)
    }
    
    func dismiss() {
        resetMapView()
    }
}


// MARK: - Helpers and Actions
extension GuestMapViewController {
    @objc func notifyShowRoute(notification: NSNotification) {
        guard let route: PWRoute = notification.object as? PWRoute else { return }
        plot(with: route)
    }
    
    func plot(with route: PWRoute) {
        self.mapView.delegate = self
        self.mapView.navigate(with: route)
        showRoutingUI()
    }
    
    func showRouteInstructions(show: Bool) {
        self.turnByTurnView.isHidden = !show
        if show {
            self.turnByTurnView.route = self.mapView.currentRoute
            self.turnByTurnView.collectionView.reloadData()
        }
    }
    
    func cancelRouting() {
        resetMapView()
        showStandardModeUI()
    }
    
    func showStandardModeUI() {
        showRouteInstructions(show: false)
        configureToolbar()
    }
    
    func showRoutingUI() {
        showRouteInstructions(show: true)
        
        if (self.mapView.userLocation != nil) {
            self.mapView.trackingMode = .followWithHeading
        }
        
        self.title = "Direction"
        
        toolbar.setItems([toolbar.flexibleBarSpace, self.trackingModeView], animated: true)
    }
    
    func showRoutingList() {
        guard let route = self.mapView.currentRoute else { return }
        let list = DirectionsListViewController.instantiate(fromAppStoryboard: .POIList)
        list.currentRoute = route
        present(list, animated: true, completion: nil)
        
    }
    
    func resetMapView() {
        self.mapView.delegate = self
        self.mapView.cancelRouting()
        self.mapView.currentRoute = nil
    }
    
    @objc func reset(notification: NSNotification) {
        resetMapView()
    }
    
    @objc func startRoute(notification: Notification) {
        if let route = notification.object as? PWRoute {
            mapView.navigate(with: route)
            mapView.trackingMode = .followWithHeading
        }
    }
    
    @objc func selectFloor() {
        let toViewController = MapFloorSelectorViewController.instantiate(fromAppStoryboard: .MapFloorPicker)
        toViewController.delegate = self
        toViewController.mapView = mapView
        present(toViewController, animated: true, completion: nil)
    }
    
    func showRouteBuilder(with poi: PWPointOfInterest) {
        let routeBuilder = RouteBuilderViewController.instantiate(fromAppStoryboard: .RouteBuilder)
        routeBuilder.endPOI = poi
        routeBuilder.mapView = mapView
        routeBuilder.delegate = self
        present(routeBuilder, animated: true, completion: nil)
    }
    
    @objc func presentStandardRouteBuilder() {
        let routeBuilder = RouteBuilderViewController.instantiate(fromAppStoryboard: .RouteBuilder)
        routeBuilder.mapView = mapView
        routeBuilder.delegate = self
        present(routeBuilder, animated: true, completion: nil)
    }
}
