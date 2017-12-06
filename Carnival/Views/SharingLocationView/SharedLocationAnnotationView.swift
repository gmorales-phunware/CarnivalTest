//
//  SharedLocationAnnotationView.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/19/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import SVPulsingAnnotationView

extension Notification.Name {
    static let didUpdateAnnotation = Notification.Name("didUpdateAnnotation")
}

class SharedLocationAnnotationView: SVPulsingAnnotationView {
    let floatingTextLabel = UILabel()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateAnnotation), name: .didUpdateAnnotation, object: nil)
        
        configureFloatingTextLabel()
        
        outerColor = .clear
        pulseColor = #colorLiteral(red: 0.801287353, green: 0.0002524638257, blue: 0.1987538934, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SharedLocationAnnotationView {
    func configureFloatingTextLabel() {
        addSubview(floatingTextLabel)
        
        translatesAutoresizingMaskIntoConstraints = false
        floatingTextLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addFloatingText(_ text: String) {
        floatingTextLabel.text = text
        floatingTextLabel.sizeToFit()
        
        floatingTextLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 14.0).isActive = true
        floatingTextLabel.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 16.0).isActive = true
    }
    
    @objc func didUpdateAnnotation() {
        DispatchQueue.main.async { [weak self] in
            guard let annotation = self?.annotation as? SharedLocationAnnotation,
                let displayName = annotation.sharedLocation.displayName,
                let userType = annotation.sharedLocation.userType else { return }
            self?.addFloatingText("\(displayName) \(userType)")
        }
    }
}
