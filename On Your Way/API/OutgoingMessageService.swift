//
//  OutgoingMessageService.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/16/20.
//
import Foundation
import Firebase
import FirebaseFirestoreSwift

class OutgoingMessageService {
    
    class func send(chatId: String, text: String?, photo: UIImage?, video: String?, audio: String?,
                    audioDuration: Float = 0.0, location: String?, memberIds:[String]){
        
        
        guard let currentUser = User.currentUser else { return }

        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.username
        message.senderinitials = String()
        message.date = Date()
        message.status = kSENT
        /* when we send message , we do :
         1- update recent message
         2- send notification
         3- re set read counter
         */
        
        if text != nil {
            
            print("DEBUG: We proint the txt here \(text)")
            // only for text message

            sendTextMessage(message: message, text: text!, memberIds: memberIds)
        }
        
    }
    
    class func sendMessage(message: LocalMessage, memberIds: [String]){
        RealmService.shared.saveToRealm(message)
        /*we make a loop so that we save the message for each user
         we used chatRoomId and users Id and the message.id to generate new messages inside the collections
         */
        print("DEBUG: \(message.message)")
        for memberId in memberIds {
            MessageService.shared.addMessage(message, memberId: memberId)
        }
    }
    
}

func sendTextMessage(message: LocalMessage, text: String, memberIds: [String]){
    print("DEBUG: \(text).")
    message.message = text
    message.type = kTEXT
    OutgoingMessageService.sendMessage(message: message, memberIds: memberIds)
    
}
