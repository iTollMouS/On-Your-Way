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
        
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        mkMessages.count
    }
    
    //MARK: - Cell top Labels
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if indexPath.section % 3 == 0 {
            
            let showLoadMore = false
            let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ?  UIFont.systemFont(ofSize: 14) : UIFont.systemFont(ofSize: 10)
            let color = showLoadMore ? UIColor.systemBlue : UIColor.darkGray
            return NSAttributedString(string: text, attributes: [.font : font,
                                                                 .foregroundColor: color])
        }
        return nil
    }

    
    //Cell bottom label
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if isFromCurrentSender(message: message) {
            let message = mkMessages[indexPath.section]
            let status = indexPath.section == mkMessages.count - 1 ? message.status + " " + message.readDate.convertDate(formattedString: .formattedType4) : ""
            
            return NSAttributedString(string: status, attributes: [.font : UIFont.boldSystemFont(ofSize: 10),
                                                                   .foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        }
        
        return nil
    }

    //Message bottom Label
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // we want to show the timestamp of the lst message in diff format
        if indexPath.section != mkMessages.count - 1 {
                        
            return NSAttributedString(string: message.sentDate.convertDate(formattedString: .formattedType4), attributes: [.font : UIFont.boldSystemFont(ofSize: 10), .foregroundColor: UIColor.darkGray])
        }
        
        return nil
    }
}


