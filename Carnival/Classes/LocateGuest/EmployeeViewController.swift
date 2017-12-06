//
//  EmployeeViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/20/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWMapKit
import PWLocation

class EmployeeViewController: BaseViewController {
    let orders = Order.items
    var selected: Order?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension EmployeeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        configure(cell: cell, forRowAtIndexPath: indexPath)
        return cell
    }
    
    func configure(cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        let order = orders[indexPath.row]
        cell.textLabel?.text = "Order # \(order.orderNumber)"
        cell.detailTextLabel?.text = "\(order.orderTitle)"
    }
}

extension EmployeeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let order = orders[indexPath.row]
        debugPrint("Order #: \(order.orderNumber)")
        selected = order
        performSegue(withIdentifier: String(describing: EmployeeOrderConfirmationViewController.self), sender: nil)
    }
}

extension EmployeeViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == String(describing: EmployeeOrderConfirmationViewController.self), let destination = segue.destination as? EmployeeOrderConfirmationViewController {
            destination.mapView = mapView
            destination.selectedOrder = selected
        }
    }
}
