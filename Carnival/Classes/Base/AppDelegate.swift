//
//  AppDelegate.swift
//  Carnival
//
//  Created by Gabriel Morales on 10/19/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import UIKit
import PWEngagement
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        Configuration.bootstrap()
        Configuration.appearence()
        
        PWEngagement.didFinishLaunching(options: launchOptions) { [weak self] (notif) -> Bool in
            if let notif = notif {
                self?.deeplinkToWebView(with: notif.message)
            }
            return true
        }
        return true
    }
}

// MARK: - PWEngagement
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PWEngagement.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PWEngagement.didFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        PWEngagement.didReceive(notification) { [weak self] (notif) in
            guard let notif = notif else { return }
            self?.prompt(with: notif)
        }
    }
}

// MARK: - Deeplinking
extension AppDelegate {
    func prompt(with notification: PWMELocalNotification) {
        if UIApplication.shared.applicationState == .active {
            guard let title = (notification.alertTitle != nil) ? notification.alertTitle : notification.message.alertTitle,
                let body = notification.alertBody else { return }
            let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Not Now", style: .default, handler: nil)
            let checkInAction = UIAlertAction(title: "OK", style: .default, handler: { [weak self] (action) in
                self?.deeplinkToWebView(with: notification.message)
            })
            alert.addAction(okAction)
            alert.addAction(checkInAction)
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func deeplinkToWebView(with message: PWMEZoneMessage) {
        let messageDetail = AppStoryboard.Messaging.viewController(viewControllerClass: MessagingDetailViewController.self)
        messageDetail.message = message
        guard let rootViewController = self.window?.rootViewController as? UINavigationController else { return }
        rootViewController.pushViewController(messageDetail, animated: true)
    }
}

