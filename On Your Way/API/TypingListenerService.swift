//
//  TypingListenerService.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/17/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class TypingListenerService {
    
    static let shared = TypingListenerService()
    var typingListener: ListenerRegistration!
    
    private init () {}
    
    func createTypingObserver(chatRoomId: String, completion: @escaping(_ isTyping: Bool) -> Void){
        
        typingListener = Firestore.firestore().collection("typing").document(chatRoomId).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            if snapshot.exists {
                for data in snapshot.data()! {
                    print("DEBUG: the user in typing class is \(User.currentId)")
                    if data.key != User.currentId {
                        completion(data.value as! Bool)
                    }
                }
            } else {
                completion(false)
                Firestore.firestore().collection("typing").document(chatRoomId).setData([User.currentId: false])
            }
            
        })
    }
    
    class func saveTypingCounter(typing: Bool, chatRoomId: String) {
        Firestore.firestore().collection("typing").document(chatRoomId).updateData([User.currentId: typing])
    }
    
    func removeTypingListener(){
        self.typingListener.remove()
    }
    
    
}
