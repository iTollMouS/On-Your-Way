//
//  ActiveListenerService.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/18/20.
//


import Foundation
import Firebase
import FirebaseFirestoreSwift

class ActiveListenerService {
    
    static let shared = ActiveListenerService()
    var typingListener: ListenerRegistration!
    
    private init () {}
    
    func createTypingObserver(chatRoomId: String, completion: @escaping(_ isTyping: Bool) -> Void){
        
        typingListener = Firestore.firestore().collection("active").document(chatRoomId).addSnapshotListener({ (snapshot, error) in
            
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
                Firestore.firestore().collection("active").document(chatRoomId).setData([User.currentId: false])
            }
            
        })
    }
    
    class func saveTypingCounter(typing: Bool, chatRoomId: String) {
        Firestore.firestore().collection("active").document(chatRoomId).updateData([User.currentId: typing])
    }
    
    func removeTypingListener(){
        self.typingListener.remove()
    }
    
    
}

