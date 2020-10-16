//
//  File.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/16/20.
//

import MessageKit

// it automatically prompts your to the required func
extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
            return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
            
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        
    }
    
    
}
