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
        
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        UserServices.shared.fetchUser(userId: uid) { currentUser in
            
            let message = LocalMessage()
            message.id = UUID().uuidString
            message.chatRoomId = chatId
            message.senderId = currentUser.id
            message.senderinitials = String(currentUser.username.first!)
            message.date = Date()
            message.status = kSENT
            /* when we send message , we do :
             1- update recent message
             2- send notification
             3- re set read counter
             */
            
            if text != nil {
                
                sendTextMessage(message: message, text: text!, memberIds: memberIds)
            }
            
            if photo != nil {
                sendPictureMessage(message: message, photo: photo!, memberIds: memberIds)
            }
            
            RecentChatService.shared.updateRecent(chatRoomId: chatId, lastMessage: message.message)
            
        }
        
    }
    
    class func sendMessage(message: LocalMessage, memberIds: [String]){
        RealmService.shared.saveToRealm(message)
        /*we make a loop so that we save the message for each user
         we used chatRoomId and users Id and the message.id to generate new messages inside the collections
         */
        for memberId in memberIds {
            MessageService.shared.addMessage(message, memberId: memberId)
        }
    }
    
}

func sendTextMessage(message: LocalMessage, text: String, memberIds: [String]){
    message.message = text
    message.type = kTEXT
    OutgoingMessageService.sendMessage(message: message, memberIds: memberIds)
}

func sendPictureMessage(message: LocalMessage, photo: UIImage, memberIds: [String]){
    
    print("DEBUG: sending photo")
    message.message = "Picture Message"
    message.type = kPHOTO
    
    let fileName = Date().convertDate(formattedString: .formattedType3)
    let fileDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    
    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.5)! as NSData, fileName: fileName)
    
    FileStorage.uploadImage(photo, directory: fileDirectory) { imageUrl in
        guard let imageUrl = imageUrl else {return}
        message.pictureUrl = imageUrl
        OutgoingMessageService.sendMessage(message: message, memberIds: memberIds)
    }
}



