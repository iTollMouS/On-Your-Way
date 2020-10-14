//
//  Page.swift
//  autolayout_lbta
//
//  Created by Brian Voong on 10/13/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit

enum OnboardingViewModel: Int, CaseIterable {
    
    case socialDistancing
    case washHands
    case handSanitizer
    case wearMask
    case cleanPhones
    case stayHome
    case packageDelivery
    
    var titleLabel: String {
        switch self {
        case .socialDistancing: return "Keep 2m"
        case .washHands: return "wash hands"
        case .handSanitizer: return "Use hands sanitizer"
        case .wearMask: return "wear mask"
        case .cleanPhones: return "Clean Phones"
        case .stayHome: return "Stay Home"
        case .packageDelivery: return "Wipe your packages"
        }
    }
    
    var detailsLabel: String {
        switch self {
        case .socialDistancing: return "Keep 2m away from your closes person"
        case .washHands: return "wash your hands regularly"
        case .handSanitizer: return "Use good hand sanitizer before handling your package"
        case .wearMask: return "Always wear a mask before going outside"
        case .cleanPhones: return "Please clean your phone when someone uses it"
        case .stayHome: return "Save yourself and other by spending your \ntime at home"
        case .packageDelivery: return "Please wipe packages before receiving and/or handling it"
        }
    }
    
    var JSONStringName: String {
        switch self {
        case .socialDistancing: return "cachAnimation"
        case .washHands: return "bell"
        case .handSanitizer: return "hand_sanitizer2"
        case .wearMask: return "wearMask"
        case .cleanPhones: return "cleanPhones"
        case .stayHome: return "stay_home"
        case .packageDelivery: return "packageDelivery"
        }
    }
    
    var animationViewDimension: (CGFloat, CGFloat) {
        switch self {
        case .socialDistancing: return (300, 300)
        case .washHands: return (250, 250)
        case .handSanitizer: return (300, 300)
        case .wearMask: return (300, 300)
        case .cleanPhones: return (300, 300)
        case .stayHome: return (300, 300)
        case .packageDelivery: return (300, 300)
        }
    }
    
}


