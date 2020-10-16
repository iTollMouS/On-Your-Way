//
//  MKSender.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/16/20.
//

import UIKit
import MessageKit

struct MKSender: SenderType, Equatable {
    var senderId: String
    
    var displayName: String
    
    
}

enum MessageDefaults {
    
    static let bubbleColorOutgoing: UIColor = #colorLiteral(red: 0.3921568627, green: 0.3921568627, blue: 0.3921568627, alpha: 1)
    static let bubbleColorIncoming: UIColor = #colorLiteral(red: 0.5882352941, green: 0.5882352941, blue: 0.5882352941, alpha: 1)
}
