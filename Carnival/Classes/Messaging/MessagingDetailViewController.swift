//
//  MessagingDetailViewController.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/30/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWEngagement

class MessagingDetailViewController: UIViewController {
    
    var message: PWMEZoneMessage!
    
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let promotBody = message.promotionBody else { return }
        let content = promotBody
        self.webView.loadHTMLString(content, baseURL: nil)
        
        // Do any additional setup after loading the view.
    }
}

extension MessagingDetailViewController {
    @IBAction func onDismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
