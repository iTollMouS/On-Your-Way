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
            
        }
        
        return mkMessage
    }
    
}
