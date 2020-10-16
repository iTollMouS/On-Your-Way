//
//  FirebaseRecentService.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/11/20.
//

import Foundation
import Firebase

class FirebaseRecentService {
    
    static let shared = FirebaseRecentService()
    
    private init () {}
    
    // step 6 
    func addRecent(_ recent: RecentChat, completion: ((Error?) -> Void)?){
        do {
            try Firestore.firestore().collection("recents").document(recent.id).setData(from: recent, merge: true, completion: completion)
        } catch (let error){
            print("DEBUG: error while making a char \(error.localizedDescription)")
        }
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
    
}
