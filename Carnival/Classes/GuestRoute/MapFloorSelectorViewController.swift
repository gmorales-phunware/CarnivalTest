//
//  MapFloorSelectorViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/19/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit

import PWMapKit

protocol FloorChangeable {
    func changeFloor(to floor: PWFloor)
}

class MapFloorSelectorViewController: BaseViewController {
    
    var delegate: FloorChangeable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension MapFloorSelectorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapView.building.floors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let floor = mapView.building.floors[indexPath.row] as? PWFloor {
            cell.textLabel?.text = floor.name
            cell.accessoryType = floor == mapView.currentFloor ? .checkmark : .none
        }
        return cell
    }
}

extension MapFloorSelectorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let floor = mapView.building.floors[indexPath.row] as? PWFloor {
            self.delegate?.changeFloor(to: floor)
        }
        dismiss(animated: true, completion: nil)
    }
}
