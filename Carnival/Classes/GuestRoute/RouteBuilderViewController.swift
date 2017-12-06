//
//  RouteBuilderViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/24/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWMapKit
import PWLocation

protocol RouteDelegate {
    func deselectSelectedPOI(poi: PWPointOfInterest) -> Void
    func dismiss()
}

class RouteBuilderViewController: BaseViewController, POISearchable {
    let currentLocationText = "Current Location"
    
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    @IBOutlet weak var swapButton: UIButton!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var routeBuilderContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var startPOI: PWPointOfInterest!
    var endPOI: PWPointOfInterest!
    var directoryPOIs: [PWPointOfInterest]!
    var departmentPOIs: [PWPointOfInterest]!
    var filtered: [PWPointOfInterest]!
    var tableData: [PWPointOfInterest]!
    var lastLocation : PWIndoorLocation!
    var userLocation: PWCustomLocation?
    var route: PWRoute?
    var delegate: RouteDelegate?

    var map: PWMapView {
        set(newMap) {
            mapView = newMap
        }
        get {
            return self.mapView
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    init(withPOI poi: PWPointOfInterest) {
        self.init()
        self.endPOI = poi
    }
    
    convenience init(poi: PWPointOfInterest) {
        self.init(withPOI: poi)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        loadData()
        mapView.delegate = self
        self.startTextField.becomeFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    class func showBuilder(targetVC: UIViewController?, with destination: PWPointOfInterest, andMapView mapview: PWMapView) {
//        let builder = RouteBuilderViewController(withPOI: destination)
        showBuilder(targetVC: targetVC, withPOI: destination, andMapView: mapview)
    }
}

// MARK: - Startup
extension RouteBuilderViewController {
    func configureViews() {
        startTextField.leftViewMode = .always
        startTextField.leftView = UILabel().configureHelper(with: " Start:")
        
        endTextField.leftViewMode = .always
        endTextField.leftView = UILabel().configureHelper(with: " End:  ")
        
        if endPOI != nil {
            endTextField.text = endPOI.title
        }
    }
}

// MARK: - UITableViewDataSource
extension RouteBuilderViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let pois = directoryPOIs else { return 0 }
        return pois.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! POITableViewCell
        let poi = directoryPOIs[indexPath.row]
        cell.configure(with: poi)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension RouteBuilderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        selectedPOI = directoryPOIs[indexPath.row]
        
        if self.startTextField.isEditing {
            self.startTextField.text = selectedPOI?.title
            self.startPOI = selectedPOI
            self.endTextField.becomeFirstResponder()
            search(keyword: self.endTextField.text)
        } else if self.endTextField.isEditing {
            self.endTextField.text = selectedPOI?.title
            self.endPOI = selectedPOI
            self.startTextField.becomeFirstResponder()
            search(keyword: self.startTextField.text)
        }
    }
}

// MARK: - UITextFieldDelegate
extension RouteBuilderViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text: NSString = textField.text != nil ? textField.text! as NSString : "" as NSString
        if range.length > 0 {
            search(keyword: text.substring(with: NSMakeRange(0, range.location)))
        } else {
            search(keyword: text.appending(string))
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField.isEqual(self.startTextField) {
            self.startPOI = nil
        } else if textField.isEqual(self.endTextField) {
            self.endPOI = nil
        }
        search(keyword: nil)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = AppColor.main.color().cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 7
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = AppColor.textField.color().cgColor
    }
}


// MARK: - IBActions
extension RouteBuilderViewController {
    @IBAction func onSwapButtonTapped(_ sender: UIButton) {
        
        guard self.startPOI != nil else {
            self.showAlert(with: "Alert!", message: "Please enter a valid starting point and try again please.")
            return }
        
        self.startTextField.text = self.endPOI.title
        self.endTextField.text = self.startPOI.title
        
        let startPOICopy = self.startPOI
        self.startPOI = self.endPOI
        self.endPOI = startPOICopy
    }
    
    @IBAction func onDimissButtonTapped(_ sender: UIButton) {
        if let poi = endPOI {
            self.delegate?.deselectSelectedPOI(poi: poi)
        } else {
            self.delegate?.dismiss()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onRouteButtonTapped(_ sender: UIButton) {
        if startTextField.isFirstResponder == true {
            startTextField.resignFirstResponder()
        } else {
            endTextField.resignFirstResponder()
        }
        
        var startPoint: PWMapPoint? = startPOI
        if startPoint == nil, let startText = startTextField.text {
            if startText == currentLocationText {
                startPoint = mapView.userLocation
            }
        }
        
        var endPoint: PWMapPoint? = endPOI
        if endPoint == nil, let endText = endTextField.text {
            if endText == currentLocationText {
                endPoint = mapView.userLocation
            }
        }
        
        
        guard let start = startPoint,
            let end = endPoint else {
                self.showAlert(with: "Alert!", message: "Both start and end are needed for route.")
                return }
        
        if !self.isValid() {
            self.showAlert(with: "Alert!", message: "Start and end cannot be the same. Please try again.")
            return
        }
        
        PWRoute.createRoute(from: start, to: end, accessibility: true, excludedPoints: nil) { [weak self] (route, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let route = route else {
                self?.showAlert(with: "Alert", message: "Invalid Route, please try again")
                self?.delegate?.deselectSelectedPOI(poi: (self?.endPOI)!)
                return
            }
            
            self?.route = route
            NotificationCenter.default.post(name: .plotRoute, object: route)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCurrentLocationTapped(_ sender: UIButton) {
        if endTextField.isEditing {
            endTextField.text = currentLocationText
            startTextField.becomeFirstResponder()
        } else {
            startTextField.text = currentLocationText
            endTextField.becomeFirstResponder()
        }
    }
}

// MARK: - PWMapViewDelegate
extension RouteBuilderViewController : PWMapViewDelegate {
    func mapView(_ mapView: PWMapView!, locationManager: PWLocationManager!, didUpdateIndoorUserLocation userLocation: PWIndoorLocation!) {
        if (userLocation == nil) {
            return
        }
        
        if lastLocation == nil || abs(lastLocation.timestamp.timeIntervalSinceNow) > 2 {
            lastLocation = userLocation
        }
    }
}

extension RouteBuilderViewController {
    class func showRouteBuilder<T: RouteDelegate>(targetVC: UIViewController?, with poi: PWPointOfInterest, andMapView mapView: PWMapView, _ delegate: T) {
        let routeBuilder = RouteBuilderViewController.show()
        routeBuilder?.endPOI = poi
        routeBuilder?.mapView = mapView
        routeBuilder?.delegate = delegate
        targetVC?.present(routeBuilder!, animated: true, completion: nil)
    }
    
    private class func showBuilder(targetVC: UIViewController?, withPOI poi: PWPointOfInterest, andMapView mapView: PWMapView) {
        let routeBuilder = RouteBuilderViewController.show()
        routeBuilder?.endPOI = poi
        routeBuilder?.mapView = mapView
        routeBuilder?.delegate = nil
        targetVC?.present(routeBuilder!, animated: true, completion: nil)
    }
    
    class func show() -> RouteBuilderViewController? {
        let storyboard = RouteBuilderViewController.instantiate(fromAppStoryboard: .RouteBuilder)
        return storyboard
    }
}


// MARK: - Route Check
fileprivate extension RouteBuilderViewController {
    func isValid() -> Bool {
        return Validate.isValidRoute(self.startPOI, self.endPOI)
    }
}
