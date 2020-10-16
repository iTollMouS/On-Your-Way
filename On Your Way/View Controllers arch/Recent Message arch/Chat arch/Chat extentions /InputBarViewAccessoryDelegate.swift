//
//  InputBarViewAccessory.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/16/20.
//

import Foundation
import InputBarAccessoryView

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text != "" {
            print("DEBUG: typing ...")
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        // this to check the input bar component which one has a text filed . naively the inputTextView has one .
        
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                print("DEBUG: \(text)")
            }
        }
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
    
}
