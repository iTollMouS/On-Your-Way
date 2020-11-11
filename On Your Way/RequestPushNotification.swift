//
//  RequestPushNotification.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 11/11/20.
//

import UIKit
class RequestPushNotification: NSObject, UNUserNotificationCenterDelegate  {
    
    static let shared = RequestPushNotification()
    
    private override init() {
        super.init()
    }
    
    func requestPushNotification(completion: @escaping((Bool, Error?) -> Void)){
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: completion)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
}
