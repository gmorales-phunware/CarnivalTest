//
//  EmployeeOrderConfirmationViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 11/6/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit

class EmployeeOrderConfirmationViewController: BaseViewController {

    var selectedOrder: Order?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension EmployeeOrderConfirmationViewController {
    
    @IBAction func onFindGuestButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: String(describing: EmployeeMapViewController.self), sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == String(describing: EmployeeMapViewController.self), let destination = segue.destination as? EmployeeMapViewController {
            destination.mapView = mapView
            destination.selectedOrder = selectedOrder
        }
    }
}
