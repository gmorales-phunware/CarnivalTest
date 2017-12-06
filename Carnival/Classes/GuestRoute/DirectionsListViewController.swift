//
//  DirectionsListViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/24/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWMapKit

class DirectionsListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var currentRoute: PWRoute?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension DirectionsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = currentRoute?.routeInstructions.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let instruction = self.currentRoute?.routeInstructions?[indexPath.row] as? PWRouteInstruction {
            cell.configureCell(with: instruction)
        }
        
        return cell
    }
}

extension DirectionsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension UITableViewCell {
    func configureCell(with step: PWRouteInstruction) {
        textLabel?.text = step.movement
        imageView?.image = CommonSettings.imageFromDirection(direction: step.movementDirection)
        configureSubtitle(with: step)
    }
    
    func configureSubtitle(with step: PWRouteInstruction) {
        detailTextLabel?.isHidden = step.isLastInstruction()
        detailTextLabel?.text = step.isLastInstruction() ? nil : "Next: " + step.turn
    }
}

extension DirectionsListViewController {
    @IBAction func onDismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
