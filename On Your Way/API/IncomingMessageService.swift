//
//  IncomingMessageService.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/17/20.
//

import Foundation
import CoreLocation
import MessageKit

class IncomingMessageService {
    
    var messageCollectionView: MessagesViewController
    
    init(_collectionView: MessagesViewController){
        messageCollectionView = _collectionView
    }
    
    // MARK: - Create Message
    
    func createMessage(localMessage: LocalMessage) -> MKMessage? {
        let mkMessage = MKMessage(message: localMessage)
        
        if localMessage.type == kPHOTO {
            let photoItem = PhotoMessage(path: localMessage.pictureUrl)
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { imageView in
                guard let image = imageView else {return}
                mkMessage.photoItem?.image = image
                // once we download the image , we set it and reload the data
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        if localMessage.type == kVIDEO {
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { thumbnailImage in
                guard let thumbnailImage = thumbnailImage else  {return}
                FileStorage.downloadVideo(videoLink: localMessage.videoUrl) { (isReadyToPlay, fileName) in
                    let videUrl = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
                    let videoItem = VideoMessage(url: videUrl)
                    mkMessage.videoItem = videoItem
                    mkMessage.kind = MessageKind.video(videoItem)
                }
                
                mkMessage.videoItem?.image = thumbnailImage
                self.messageCollectionView.messagesCollectionView.reloadData()
                
            }
        }
        
        if localMessage.type == kLOCATION {
            let locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude, longitude: localMessage.longitude))
            mkMessage.kind = MessageKind.location(locationItem)
            mkMessage.locationItem = locationItem
            
        }
        
        if localMessage.type == kAUDIO{
            let audioItem = AudioMessage(duration: Float(localMessage.audioDuration))
            mkMessage.audioItem = audioItem
            mkMessage.kind = MessageKind.audio(audioItem)
            
            FileStorage.downloadAudio(audioLink: localMessage.audioUrl) { audioFileName in
                let audioURL = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: audioFileName))
                mkMessage.audioItem?.url = audioURL
            }
            self.messageCollectionView.messagesCollectionView.reloadData()
        }
        
        return mkMessage
    }
    
}
