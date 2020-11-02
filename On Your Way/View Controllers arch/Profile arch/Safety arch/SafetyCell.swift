//
//  SafetyCell.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/28/20.
//

import UIKit
import Lottie

class SafetyCell: UITableViewCell {
    
    // MARK: - Setup Model
    var viewModel: SafetyCellViewModel?{
        didSet{configure()}
    }
    
    // MARK: - Properties
    private lazy var animationView : AnimationView = {
        let animationView = AnimationView()
        animationView.setDimensions(height: 60, width: 60)
        animationView.clipsToBounds = true
        animationView.layer.cornerRadius = 60 / 2
        animationView.backgroundColor = .clear
        return animationView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    

    private lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .gray
        return label
    }()
        
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, detailsLabel])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillProportionally
        stackView.setWidth(width: 240)
        return stackView
    }()
    

    // MARK: -  LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(stackView)
        stackView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        stackView.anchor(top: topAnchor, bottom: bottomAnchor, paddingTop: 20, paddingBottom: 20)
        addSubview(animationView)
        animationView.centerY(inView: self, leftAnchor: stackView.rightAnchor, paddingLeft: 12)
        backgroundColor =  .clear
    }
    
    // MARK: - configure()
    func configure(){
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.titleLabel
        detailsLabel.text = viewModel.detailsLabel
        animationView.animation = Animation.named(viewModel.JSONStringName)
        animationView.play()
        animationView.loopMode = .loop
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - SafetyCellViewModel

enum SafetyCellViewModel: Int, CaseIterable {
    
    case socialDistancing
    case washHands
    case handSanitizer
    case wearMask
    case cleanPhones
    case stayHome
    case packageDelivery
    
    var cellHeight: CGFloat {
        switch self {
        case .socialDistancing: return 160
        case .washHands: return 140
        case .handSanitizer: return 120
        case .wearMask: return 120
        case .cleanPhones: return 120
        case .stayHome: return 140
        case .packageDelivery: return 160
        
        }
    }
    
    var titleLabel: String {
        switch self {
        case .socialDistancing: return "مسافر مترين"
        case .washHands: return "غسل اليدين بشكل مستمر"
        case .handSanitizer: return "Use hands sanitizer"
        case .wearMask: return "تأكد من أنها تغطي أنفك وفمك وذقنك"
        case .cleanPhones: return "Clean Phones"
        case .stayHome: return "Stay Home"
        case .packageDelivery: return "Wipe your packages"
        }
    }
    
    var detailsLabel: String {
        switch self {
        case .socialDistancing: return "ابتعد مسافة متر واحد على الأقل عن الآخرين للحد من مخاطر الإصابة بالعدوى عندما يسعلون أو يعطسون أو يتكلمون. ابتعد مسافة أكبر من ذلك عن الآخرين عندما تكون في أماكن مغلقة. كلما ابتعدت مسافة أكبر، كان ذلك أفضل."
        case .washHands: return "نظف يديك جيداً بانتظام باستخدام مطهر اليدين الكحولي أو اغسلهما بالماء والصابون. ويؤدي ذلك إلى إزالة الجراثيم بما في ذلك الفيروسات التي قد توجد على يديك."
        case .handSanitizer: return "استخدم معقم كحولي اذا لم يتوفر الماء استخدم معقم كحولي اذا لم يتوفر الماء استخدم معقم كحولي اذا لم يتوفر الماء"
            
        case .wearMask: return "تُعد الكمامات الطبية من معدات الحماية الشخصية الأساسية للعاملين. فمجرد ارتداؤها ، يتم تقليل نسبة الاصابة من الفايروس"
            
        case .cleanPhones: return "ظف الأسطح وطهّرها بشكل متكرر ولاسيما تلك التي تُلمس بانتظام، مثل مقابض الأبواب والحنفيات وشاشات الهاتف."
        case .stayHome: return "time at homeSave yourself and other by spending your \ntime at homeSave yourself and other by spending your"
        case .packageDelivery: return "Please wipe packages before receiving and/or handling it"
        }
    }
    
    var JSONStringName: String {
        switch self {
        case .socialDistancing: return "social_distancing"
        case .washHands: return "wash_your_hands_regularly"
        case .handSanitizer: return "hand_sanitizer2"
        case .wearMask: return "wearMask"
        case .cleanPhones: return "cleanPhones"
        case .stayHome: return "stay_home"
        case .packageDelivery: return "packageDelivery"
        }
    }
}
