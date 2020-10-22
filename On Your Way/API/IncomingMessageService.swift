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
        
        return mkMessage
    }
    
}
