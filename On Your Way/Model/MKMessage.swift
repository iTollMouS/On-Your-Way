//
//  MKMessage.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/16/20.
//

import MessageKit
import UIKit
import CoreLocation


class MKMessage: NSObject, MessageType {
    
    var messageId: String
    var kind: MessageKind
    var sentDate: Date
    var incoming: Bool
    var mkSender: MKSender
    var sender: SenderType {return mkSender}
    
    var photoItem: PhotoMessage?
    
    
    var senderInitials: String
    var status: String
    var readDate: Date
    
    
    // we get all the properties form LocalMessage file
    init(message: LocalMessage) {
        
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        
        switch message.type {
        case kTEXT:
            self.kind = MessageKind.text(message.message)
        case kPHOTO:
            let photoItem = PhotoMessage(path: message.pictureUrl)
            self.kind = MessageKind.photo(photoItem)
            self.photoItem = photoItem
        default: break
        }
        
        
        self.senderInitials = message.senderinitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = User.currentId != mkSender.senderId
        
        
        
        
    }
    
    
    
}
