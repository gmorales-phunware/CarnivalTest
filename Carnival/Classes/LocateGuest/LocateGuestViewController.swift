//
//  LocateGuestViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/19/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit

class LocateGuestViewController: BaseViewController {
    @IBOutlet weak var collectionView: UITableView!
    fileprivate let identifiers: [Identifier] = [.guest, .employee]
    
    weak var employeeViewController: EmployeeViewController!
    weak var customerViewController: CustomerViewController!
    
    let titles = ["GUEST", "EMPLOYEE"]
    let descriptions = ["Submit Order to begin sharing location", "Receive Order info and Guest location"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

// MARK: - UITableViewDataSource
extension LocateGuestViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = titles[indexPath.row]
        let subtitle = descriptions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.configure(withTitle: title, andDescription: subtitle)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LocateGuestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let identifier: Identifier = self.identifiers[indexPath.row]
        performSegue(withIdentifier: identifier.Identifier(), sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        
        let dividerView = UIView()
        dividerView.backgroundColor = #colorLiteral(red: 0.5761576295, green: 0.5841612816, blue: 0.5965723395, alpha: 1)
        
        let label = UILabel()
        label.text = "Select User Type"
        view.addSubview(label)
        view.addSubview(dividerView)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 1).isActive = true
        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        dividerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24).isActive = true
        dividerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true
        return view
    }
}

// MARK: - Setup
extension LocateGuestViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == String(describing: CustomerViewController.self), let destination = segue.destination as? CustomerViewController {
            destination.mapView = mapView
        } else {
            if let destination = segue.destination as? EmployeeViewController {
                destination.mapView = mapView
            }
        }
    }
    
    fileprivate enum Identifier: Int {
        case guest, employee
        
        func Identifier() -> String {
            switch self {
            case .guest: return String(describing: CustomerViewController.self)
            case .employee: return String(describing: EmployeeViewController.self)
            }
        }
    }
}

extension UITableViewCell {
    func configure(withTitle title: String, andDescription description: String) {
        self.textLabel?.text = title
        self.detailTextLabel?.text = description
    }
}
