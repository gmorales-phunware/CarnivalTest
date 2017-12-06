//
//  LandingViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/19/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit

class LandingViewController: BaseViewController {
    let usecases = Usecase.items
    fileprivate let identifiers: [Identifier] = [.locateGuest, .guestRoute, .messaging, .findMyFriend]

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.stopSharingUserLocation()
        mapView.stopRetrievingSharedLocations()
    }
}

extension LandingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let identifier: Identifier = self.identifiers[indexPath.row]
        performSegue(withIdentifier: identifier.Identifier(), sender: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        
        let logoImageView = UIImageView()
        logoImageView.image = #imageLiteral(resourceName: "logo")
        view.addSubview(logoImageView)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        logoImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 182).isActive = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 92
    }
}

extension LandingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usecases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let usecase = usecases[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "USE CASE \(indexPath.row+1):"
        cell.detailTextLabel?.text = usecase.title
        return cell
    }
}

extension LandingViewController {
    fileprivate enum Identifier: Int {
        case locateGuest, guestRoute, messaging, findMyFriend
        
        func Identifier() -> String {
            switch self {
            case .locateGuest: return String(describing: LocateGuestViewController.self)
            case .guestRoute: return String(describing: GuestRouteViewController.self)
            case .messaging: return String(describing: MessagingViewController.self)
            case .findMyFriend: return String(describing: FindMyFriendViewController.self)
            }
        }
    }
}
