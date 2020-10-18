//
//  MessageService.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/16/20.
//
import Foundation
import Firebase
import FirebaseFirestoreSwift

class MessageService {
    
    static let shared = MessageService()
    var newChatListener: ListenerRegistration!
    var updatedChatListener: ListenerRegistration!
    
    private init () {}
    
    
    
    // MARK: - listenForNewChats
    func listenForNewChats(_ documentId: String, collectionId: String, lastMessageDate: Date) {
        newChatListener = Firestore.firestore().collection("messages")
            .document(documentId).collection(collectionId)
            .whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (snapshot, error) in
                guard let snapshot = snapshot else {return}
                
                for change in snapshot.documentChanges {
                    if change.type == .added {
                        let result = Result {
                            try? change.document.data(as: LocalMessage.self)
                        }
                        
                        switch result {
                        case .success(let messageObject):
                            if let message = messageObject {
                                RealmService.shared.saveToRealm(message)
                            } else {
                                print("DEBUG: ducoment doesnt exists")
                            }
                            
                        case .failure(let error):
                            print("DEBUG: error while getting \(error.localizedDescription)")
                        }
                    }
                }
                
            })
    }
    
    func listenForReadStatusChange(_ documentId: String, collectionId: String, completion: @escaping(_ updatedMessage: LocalMessage) -> Void){
        updatedChatListener = Firestore.firestore().collection("messages").document(documentId).collection(collectionId).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else {return}
            
            for change in snapshot.documentChanges {
                if change.type == .modified {
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
//                    switch result {
//
//                    case .success(let localMessage?):
//
//                    case .failure(let error):
//
//                    }
                }
            }
            
            
        })
    }
    
    // MARK: - checkForOldChats
    func checkForOldChats(_ documentId: String, collectionId: String) {
        Firestore.firestore().collection("messages").document(documentId).collection(collectionId).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot?.documents else {return}
            
            var oldMessages = snapshot.compactMap { (queryDocumentSnapshot) -> LocalMessage? in
                return try? queryDocumentSnapshot.data(as: LocalMessage.self)
            }
            
            oldMessages.sort(by: {$0.date < $1.date})
            for message in oldMessages {
                RealmService.shared.saveToRealm(message)
            }
            
        }
    }
    
    // MARK: - add message
    func addMessage(_ message: LocalMessage, memberId: String){
        do {
            let _ = try Firestore.firestore().collection("messages")
                .document(memberId)
                .collection(message.chatRoomId)
                .document(message.id).setData(from: message)
        } catch (let error) {
            print("DEBUG: error while uploading message\(error)")
        }
    }
    
    func updateMessageInFirebase(_ message: LocalMessage, memberIds: [String]){
        let values = [kSTATUS: kREAD,
                      kREADDATE: Date()] as [String : Any]
        for userId in memberIds {
            Firestore.firestore().collection("messages")
                .document(userId)
                .collection(message.chatRoomId)
                .document(message.id).updateData(values)
        }
    }
    
    
    func removeListener(){
        newChatListener.remove()
        updatedChatListener.remove()
    }
    
}
