//
//  CustomerViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/20/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWMapKit

class CustomerViewController: BaseViewController {
    
    @IBOutlet weak var orderImageView: UIImageView! {
        didSet {
            orderImageView.image = #imageLiteral(resourceName: "order_confirmation")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}



extension CustomerViewController {
    @IBAction func onSubmitButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Confirmation", message: "Your order has been submitted.", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "OK", style: .default) { [weak self] (finished) in
            self?.performSegue(withIdentifier: String(describing: CustomerOrderConfirmationViewController.self), sender: nil)
        }
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == String(describing: CustomerOrderConfirmationViewController.self), let destination = segue.destination as? CustomerOrderConfirmationViewController {
            destination.mapView = mapView
        }
    }
}
