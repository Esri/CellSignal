//
//  CustomNotification.swift
//  AR-DevSummit-2018
//
//  Created by Al Pascual on 12/19/17.
//  Copyright © 2017 Al Pascual. All rights reserved.
//

import UIKit
import UserNotifications

class CustomNotification: NSObject {
    
    static var lastLabelText = ""
    
    public class func show(parent: ViewController, title: String, description: String, checkForDuplicates: Bool = true) {
        
        // Avoid seeing the same error multiple times.
        if checkForDuplicates {
            if description == lastLabelText {
                return
            }        
            lastLabelText = description
        }
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: description, arguments: nil)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1,
                                                        repeats: false)
        
        let request = UNNotificationRequest(identifier: "UYLLocalNotification",
                                            content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.delegate = parent
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print("Notification failed \(error)")
            }
        })
    }
}

extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
}

