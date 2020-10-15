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
    
    
    func addRecent(_ recent: RecentChat, completion: ((Error?) -> Void)?){
        do {
            try Firestore.firestore().collection("recents").document(recent.id).setData(from: recent, merge: true, completion: completion)
        } catch (let error){
            print("DEBUG: error while making a char \(error.localizedDescription)")
        }
    }
    
    func fetchRecentChatFromFirestore(completion: @escaping([RecentChat]) -> Void) {
        Firestore.firestore().collection("recent").whereField(kSENDERID, isEqualTo: User.currentId).addSnapshotListener { (snapshot, error) in
            var recents: [RecentChat] = []
            guard let snapshot = snapshot else {return}
            
            let allRecent = snapshot.documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
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
