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
    
    static let bubbleColorOutgoing: UIColor = #colorLiteral(red: 0.1176470588, green: 0.2745098039, blue: 0.2509803922, alpha: 1)
    static let bubbleColorIncoming: UIColor = .blueLightIcon
}
