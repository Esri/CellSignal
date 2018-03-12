// Copyright 2018 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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

