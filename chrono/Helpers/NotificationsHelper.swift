//
//  Utilities.swift
//  chrono
//
//  Created by blackbriar on 3/23/17.
//  Copyright © 2017 Teressa Eid. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class NotificationsHelper {
    
    
    
    typealias successResponse = (Bool) -> ()
    
    
    static func scheduleLocalNotification(delay: TimeInterval, body: String, title: String?, soundName: String?) {
        
        let localNotification = UILocalNotification()
        localNotification.fireDate = Date.init(timeIntervalSinceNow: delay)
        
        localNotification.alertBody = body
        localNotification.applicationIconBadgeNumber = 0
        
        if let soundName = soundName {
            localNotification.soundName = soundName
        }
        else {
            localNotification.soundName = UILocalNotificationDefaultSoundName
        }
        
        if title != nil {
            if #available(iOS 8.2, *) {
                localNotification.alertTitle = title
            } else {
                // Fallback on earlier versions
            }
        }
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    
    // MARK : - ONLY FOR iOS 10
    
    // https://swifting.io/blog/2016/08/22/23-notifications-in-ios-10/
    @available(iOS 10.0, *)
    static func scheduleLocalNotificationIos10(delay: TimeInterval, body: String, title: String?, soundName: String?, imageName: String?, category: String?) {
        let content = UNMutableNotificationContent()
        content.body = body
        
        if title != nil {
            content.title = title!
        }
        
        if let soundName = soundName {
            content.sound = UNNotificationSound(named: soundName)
        }
        else {
            content.sound = UNNotificationSound.default()
        }
        if imageName != nil {
            //To Present image in notification
            if let path = Bundle.main.path(forResource: imageName!, ofType: "jpg") {
                let url = URL(fileURLWithPath: path)
                do {
                    let attachment = try UNNotificationAttachment(identifier: "sampleImage", url: url, options: nil)
                    content.attachments = [attachment]
                } catch {
                    print("attachment not found.")
                }
            }
        }
        if category != nil {
            content.categoryIdentifier = category!
        }
        
        content.subtitle = "Subtitle"
        content.launchImageName = "croix"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        
        let request = UNNotificationRequest(identifier: "TimerUp", content: content, trigger: trigger)
        
        // Schedule the request.
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
        /*
         let attachment = try? UNNotificationAttachment(identifier: "myimage",
         url: url,
         options: [:])
         if let attachment = attachment {
         content.attachments.append(attachment)
         }*/
    }
    
    static func registerNotifications() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    print("Yay!")
                } else {
                    print("D'oh")
                }
            }
        }
        else {
            let application = UIApplication.shared
            
            let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
            let settings = UIUserNotificationSettings(types: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
    @available(iOS 10.0, *)
    private static func requestAuthorization(completionHandler: @escaping successResponse) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            
            completionHandler(success)
        }
    }

    static func cancelNotifications() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
        }
        else {
            let app = UIApplication.shared
            let notifications = app.scheduledLocalNotifications
            
            if notifications != nil {
                app.cancelAllLocalNotifications()
            }
        }
    }
    
//    func dismissNotification() {
//        let center = UNUserNotificationCenter.current()
//        let category = UNNotificationCategory(identifier: "JUST_DISMISS", actions: [], intentIdentifiers: [], options: .customDismissAction)
//        center.setNotificationCategories([category])
//    }
    
    static func registerCategories() {
        let center = UNUserNotificationCenter.current()

        let remind = UNNotificationAction(identifier: "Snooze", title: "Remind Me in Another Minute", options: .foreground)
        let stop = UNNotificationAction(identifier: "Stop", title: "Okay thanks for reminding me", options: .foreground)
        let category = UNNotificationCategory(identifier: "timerOptions",
                                              actions: [remind,stop],
                                              intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])
    }
    
    /*
    func textInputNotification() {
        
                let inputAction = UNTextInputNotificationAction(identifier: <#T##String#>, title: <#T##String#>, options: <#T##UNNotificationActionOptions#>, textInputButtonTitle: <#T##String#>, textInputPlaceholder: <#T##String#>)
    }
 */
    
    @available(iOS 10.0, *)
    static func checkAuthorizationIos10() {
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }
                    
                })
            case .authorized:
                print()
            case .denied:
                print("Application Not Allowed to Display Notifications")
            }
        }
    }
    

    

    
    
}


