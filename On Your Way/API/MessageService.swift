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
    
    private init () {}
    
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
    
}
