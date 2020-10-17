//
//  PushNotificationService.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/18/20.
//

import Foundation

class PushNotificationService {
    static let shared = PushNotificationService()
    private init () {}
    
    func sendPushNotification(userIds: [String], body: String, title: String){
        
        UserServices.shared.downloadUsersFromFirebase(withIds: userIds) { users in
            for user in users {
                print("DEBUG: user puhs s \(user.pushId)")
                self.sendNotificationToUser(to: user.pushId, title: user.username, body: body)
            }
        }
        
    }
    
    private func sendNotificationToUser(to token: String, title: String, body: String){
        
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        let paramString : [String: Any] = ["to": token, "notification": [
            "title": title,
            "body": body,
            "badge": "1",
            "sound": "default"
        ]]
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(kSERVERKEY)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
        
        }
        task.resume()
    }
    
}


func removeCurrentUserFrom(userIds: [String]) -> [String] {
    
    var allIds = userIds
    
    for id in allIds {
        
        if id == User.currentId {
            allIds.remove(at: allIds.firstIndex(of: id)!)
        }
    }
    
    return allIds
}
