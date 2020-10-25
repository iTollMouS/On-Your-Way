//
//  OutgoingMessageService.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/16/20.
//
import Foundation
import Firebase
import FirebaseFirestoreSwift
import Gallery
import AVFoundation

class OutgoingMessageService {
    
    class func send(chatId: String, text: String?, photo: UIImage?, video: Video?, audio: String?,
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
            
            if video != nil {
                sendVideoMessage(message: message, video: video!, memberIds: memberIds)
            }
            
            if location != nil {
                sendLocationMessage(message: message, memberIds: memberIds)
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

func sendVideoMessage(message: LocalMessage, video: Video, memberIds: [String]){
    
    message.message = "Video Message"
    message.type = kVIDEO
    
    let fileName = Date().convertDate(formattedString: .formattedType10)
    let thumbnailDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    let videoDirectory = "MediaMessages/video/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".mov"
    
    let editor = VideoEditor()
    editor.process(video: video) { (processedVideo, videoUrl) in
        if let tempPath = videoUrl {
            let thumbnail = videoThumbnail(video: tempPath)
            FileStorage.saveFileLocally(fileData: thumbnail.jpegData(compressionQuality: 0.5)! as NSData, fileName: fileName)
            FileStorage.uploadImage(thumbnail, directory: thumbnailDirectory) {  imageUrl in
                guard let imageUrl = imageUrl else {return}
                guard let videoData = NSData(contentsOfFile: tempPath.path) else {return}
                FileStorage.saveFileLocally(fileData: videoData, fileName: fileName + ".mov")
                FileStorage.uploadVideo(videoData, directory: videoDirectory) { videoUrl in
                    guard let videoUrl = videoUrl  else {return}
                    message.pictureUrl = imageUrl
                    message.videoUrl = videoUrl
                    OutgoingMessageService.sendMessage(message: message, memberIds: memberIds)
                }
            }
        }
    }
}

func videoThumbnail(video: URL) -> UIImage {
    let asset = AVURLAsset(url: video, options: nil)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    var image: CGImage?
    
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
        
    } catch (let error) {
        print("DEBUG: error \(error.localizedDescription)")
    }
    
    if image != nil {
        return UIImage(cgImage: image!)
    } else {
        return UIImage(systemName: "photo")!
    }
    
}

func sendTextMessage(message: LocalMessage, text: String, memberIds: [String]){
    message.message = text
    message.type = kTEXT
    OutgoingMessageService.sendMessage(message: message, memberIds: memberIds)
}

func sendLocationMessage(message: LocalMessage, memberIds: [String]){
    
    guard let currentLocation = LocationManager.shared.currentLocation else {return}
    message.message = "Location Message"
    message.type = kLOCATION
    message.latitude = currentLocation.latitude
    message.longitude = currentLocation.longitude
    OutgoingMessageService.sendMessage(message: message, memberIds: memberIds)
}

