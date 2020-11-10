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
    case packageDelivery
    case location
    
    
    var titleLabel: String {
        switch self {
        case .cashOnDelivery: return "مسافر؟"
        case .notifications: return "التنبيهات"
        case .covidProtections: return "ارشادات وزارة الصحة من الوقاية من كورونا \nCOVID-19"
        case .chatFeature: return "المحادثات الخاصة"
        case .discountPolicy: return "عروض و تخفيضات"
        case .packageDelivery: return "تعقيم الشحنات"
        case .location: return "مشاركة الموقع"
        }
    }
    
    var detailsLabel: String {
        switch self {
        case .cashOnDelivery: return "تستطيع زيادة دخلك الشهري من خلال سفرك بين المدن بواسطة شحن البضائع للعملاء على طريقك"
        case .notifications: return "عندما تسافر من مكان لاخر ، سيصلك تنبيهات من العملاء عند رغبتهم في شحن البضائع على طريقك و عند قبولك او رفض الطلب ، سيتم اشعار العملاء بذلك"
        case .covidProtections: return "نوصي جميع المسافرين و العملاء باتخاذ كافه الاجراءات و التوصيات من وزارة الصحة للوقاية من فايروس كورونا"
        case .chatFeature: return "عندما يتم ارسال شحنة مع مسافر ، سيتم اتاحة خاصية الدردشة مع المسافر للتفاوض على اسعار الخدمة\nتستطيع مشاركة الصور ، الفيديو ، الموقع و ارسال ملاحظة صوتية"
        case .discountPolicy: return "هدفنا هو خدمه العملاء و حفظ حق المسافرين و ايصال اعلى معايير الجودة\nسيتم اعلان عن عروض لخدمات ارسال الشحنات بشكل اسبوعي"
        case .packageDelivery: return "سياستنا هي الزام جميع العملاء و المسافرين بتعقيم الشحنات قبل التسليم و الاستلام لتفادي نقل الامراض المعدية"
        case .location : return "تستطيع ان تشارك موقعك مع العملاء لتحديث مكان الشحنه على طريقك"
        }
    }
    
    var JSONStringName: String {
        switch self {
        case .cashOnDelivery: return "cachAnimation"
        case .notifications: return "bell_animation"
        case .covidProtections: return "covid_19_protect"
        case .chatFeature: return "chat_messenger"
        case .discountPolicy: return "discount_icon"
        case .packageDelivery: return "packageDelivery"
        case .location: return "locationAnimation"
        }
    }
    
    var animationViewDimension: (CGFloat, CGFloat) {
        switch self {
        case .cashOnDelivery: return (200, 200)
        case .notifications: return (200, 200)
        case .covidProtections: return (200, 200)
        case .chatFeature: return (200, 200)
        case .discountPolicy: return (200, 200)
        case .packageDelivery: return (200, 200)
        case .location: return (200, 200)
        }
    }
    
}


