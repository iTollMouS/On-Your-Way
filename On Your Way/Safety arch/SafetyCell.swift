//
//  SafetyCell.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/28/20.
//

import UIKit
import Lottie

class SafetyCell: UITableViewCell {
    
    var viewModel: SafetyCellViewModel?{
        didSet{configure()}
    }
    
    
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
        label.textAlignment = .left
        label.text = "Test 1 2 3 "
        label.font = .boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    

    private lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Test 1 2 3 "
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .gray
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
        
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, detailsLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fillProportionally
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(animationView)
        animationView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        addSubview(stackView)
        stackView.centerY(inView: animationView, leftAnchor: animationView.rightAnchor, paddingLeft: 12)
        stackView.anchor(right: rightAnchor, paddingRight: 18)
        backgroundColor =  .clear
    }
    
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

enum SafetyCellViewModel: Int, CaseIterable {
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
