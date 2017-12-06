//
//  FindMyFriendListViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 11/3/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWMapKit
import PWLocation
import DZNEmptyDataSet

class FindMyFriendListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var sharedLocations = Set<PWSharedLocation>()
    var sharedLocationAnnotations = [String : SharedLocationAnnotation]()
    let loadingErrorEmptyDataSource = CarnivalEmptyDataSource()
    var locations = [PWSharedLocation]()
    var mapView = PWMapView()
    var firstLocationAcquired = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.emptyDataSetSource = self.loadingErrorEmptyDataSource
        print(sharedLocations)
        locations = sharedLocations.flatMap({$0})
        print(locations)
    }

}

extension FindMyFriendListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sharedLocation = locations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(sharedLocation.displayName) - (\(sharedLocation.userType))"
        cell.detailTextLabel?.text = "\(sharedLocation.floorId)"
        return cell
    }
}

extension FindMyFriendListViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        
    }
}

extension FindMyFriendListViewController {
    @IBAction func onDismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
