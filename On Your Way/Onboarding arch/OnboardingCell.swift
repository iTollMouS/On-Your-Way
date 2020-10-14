//
//  PageCell.swift
//  autolayout_lbta
//
//  Created by Brian Voong on 10/12/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit
import Lottie

class OnboardingCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    
    var viewModel: OnboardingViewModel? {
        didSet { configure() }
    }
    
    
    private lazy var animationView : AnimationView = {
        let animationView = AnimationView()
        animationView.clipsToBounds = true
        animationView.layer.cornerRadius = 60 / 2
        animationView.backgroundColor = .clear
        return animationView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    

    private lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
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

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
    }
    
    fileprivate func configure(){
        guard let viewModel = viewModel else { return  }
        addSubview(animationView)
        animationView.animation = Animation.named(viewModel.JSONStringName)
        animationView.centerX(inView: self, topAnchor: topAnchor, paddingTop: 50)
        animationView.play()
        animationView.loopMode = .loop
        
        // size manager
        switch viewModel {
        case .socialDistancing:
            animationView.setDimensions(height: viewModel.animationViewDimension.0, width: viewModel.animationViewDimension.1)
        case .washHands:
            animationView.setDimensions(height: viewModel.animationViewDimension.0, width: viewModel.animationViewDimension.1)
        case .handSanitizer:
            animationView.setDimensions(height: viewModel.animationViewDimension.0, width: viewModel.animationViewDimension.1)
        case .wearMask:
            animationView.setDimensions(height: viewModel.animationViewDimension.0, width: viewModel.animationViewDimension.1)
        case .cleanPhones:
            animationView.setDimensions(height: viewModel.animationViewDimension.0, width: viewModel.animationViewDimension.1)
        case .stayHome:
            animationView.setDimensions(height: viewModel.animationViewDimension.0, width: viewModel.animationViewDimension.1)
        case .packageDelivery:
            animationView.setDimensions(height: viewModel.animationViewDimension.0, width: viewModel.animationViewDimension.1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
