//
//  Page.swift
//  autolayout_lbta
//
//  Created by Brian Voong on 10/13/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit

enum OnboardingViewModel: Int, CaseIterable {
    
    case cashOnDelivery
    case notifications
    case covidProtections
    case chatFeature
    case discountPolicy
    case stayHome
    case packageDelivery
    case location
    
    
    var titleLabel: String {
        switch self {
        case .cashOnDelivery: return "Keep 2m"
        case .notifications: return "wash hands"
        case .covidProtections: return "Use hands sanitizer"
        case .chatFeature: return "wear mask"
        case .discountPolicy: return "Clean Phones"
        case .stayHome: return "Stay Home"
        case .packageDelivery: return "Wipe your packages"
        case .location: return "Share your location"
        }
    }
    
    var detailsLabel: String {
        switch self {
        case .cashOnDelivery: return "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown"
        case .notifications: return "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the u"
        case .covidProtections: return "Use good hand sanitizer before handling your package"
        case .chatFeature: return "Always wear a mask before going outside"
        case .discountPolicy: return "Please clean your phone when someone uses it"
        case .stayHome: return "it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through t"
        case .packageDelivery: return "Please wipe packages before receiving and/or handling it"
        case .location : return "Sharing your location to your customer around you"
        }
    }
    
//    bell_animation
    
    var JSONStringName: String {
        switch self {
        case .cashOnDelivery: return "cachAnimation"
        case .notifications: return "bell"
        case .covidProtections: return "covid_19_protect"
        case .chatFeature: return "chat_messenger"
        case .discountPolicy: return "discount_icon"
        case .stayHome: return "stay_home"
        case .packageDelivery: return "packageDelivery"
        case .location: return "locationAnimation"
        }
    }
    
    var animationViewDimension: (CGFloat, CGFloat) {
        switch self {
        case .cashOnDelivery: return (200, 300)
        case .notifications: return (200, 200)
        case .covidProtections: return (200, 300)
        case .chatFeature: return (200, 200)
        case .discountPolicy: return (200, 300)
        case .stayHome: return (200, 300)
        case .packageDelivery: return (200, 300)
        case .location: return (200, 300)
        }
    }
    
}


