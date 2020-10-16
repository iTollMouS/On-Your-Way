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
    var senderInitials: String
    
    
    var status: String
    var readDate: Date
    
    
    init(message: String) {
        
        
        
    }
    
    
    
}
