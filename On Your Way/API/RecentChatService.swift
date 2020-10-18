//
//  FirebaseRecentService.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/11/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class RecentChatService {
    
    static let shared = RecentChatService()
    
    private init () {}
    
    // step 6 
    func saveRecent(_ recent: RecentChat, completion: ((Error?) -> Void)?){
        do {
            try Firestore.firestore().collection("recents").document(recent.id).setData(from: recent, merge: true, completion: completion)
        } catch (let error){
            print("DEBUG: error while making a char \(error.localizedDescription)")
        }
    }
    
    // step 9 + also you when you are in the chat room , you should make the recent zero
    func clearUnreadCounter(recent: RecentChat){
        var recentTemp = recent
        recentTemp.unreadCounter = 0
        saveRecent(recentTemp, completion: nil)
    }
    
    // step 10 make the counter = 0 while inside chat , gets active when we only leave the chat room
    func resetRecentCounter(chatRoomId: String){
        Firestore.firestore().collection("recents").whereField(kCHATROOMID, isEqualTo: chatRoomId)
            .whereField(kSENDERID, isEqualTo: User.currentId).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot?.documents else {return}
                let allRecent = snapshot.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                    return try? queryDocumentSnapshot.data(as: RecentChat.self)
                }
                if allRecent.count > 0 {
                    guard let firstRecent = allRecent.first else { return }
                    self.clearUnreadCounter(recent: firstRecent)
                }
            }
    }
    
    func deleteRecent(_ recent: RecentChat, completion: ((Error?) -> Void)?){
        Firestore.firestore().collection("recents").document(recent.id).delete(completion: completion)
    }
    
    // step 8 : after we get the user who are news / or who deleted the recent chat , we upload it under his id kSENDERID
    func fetchRecentChatFromFirestore(completion: @escaping([RecentChat]) -> Void) {
        Firestore.firestore().collection("recents").whereField(kSENDERID, isEqualTo: User.currentId).addSnapshotListener { (snapshot, error) in
            var recents: [RecentChat] = []
            guard let snapshot = snapshot?.documents else {return}
            
            let allRecent = snapshot.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            // check if the last message is empty or not so that we dont override it
            for recent in allRecent {
                if recent.lastMessage != "" {
                    recents.append(recent)
                }
            }
            
            recents.sort(by: { $0.date! > $1.date! })
            completion(recents)
        }
    }
    
    func updateRecent(chatRoomId: String, lastMessage: String){
        // go and find all recent that belongs to the chat room
        Firestore.firestore().collection("recents").whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
            if let error = error {
                print("DEBUG: error while finding \(error.localizedDescription)")
                return
            }
            
            
            guard let snapshot = snapshot?.documents else {return}
            let allRecent = snapshot.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            for recent in allRecent {
                self.updateRecentItemWithNewMessage(recent: recent, lastMessage: lastMessage)
            }
            
        }
    }
    
    func updateRecentItemWithNewMessage(recent: RecentChat, lastMessage: String){
        var recent = recent
        if recent.senderId != User.currentId {
            recent.unreadCounter += 1
        }
        recent.lastMessage = lastMessage
        recent.date = Date()
        
        saveRecent(recent, completion: nil)
    }
    
}
