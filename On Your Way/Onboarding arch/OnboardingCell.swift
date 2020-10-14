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
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 26)
        label.numberOfLines = 0
        label.setHeight(height: 30)
        label.textColor = .white
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    

    private lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24)
        label.numberOfLines = 0
        label.textColor = .gray
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.contentMode = .top
        label.setHeight(height: 200)
        return label
    }()
        
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ animationView ,titleLabel,
                                                         detailsLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fill
        return stackView
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    fileprivate func configure(){
        guard let viewModel = viewModel else { return  }
        
        addSubview(stackView)
        stackView.centerX(inView: self, topAnchor: topAnchor, paddingTop: 60)
        stackView.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 30, paddingRight: 30)
//        stackView.fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets(top: 30, left: 30, bottom: 150, right: 30))
        animationView.animation = Animation.named(viewModel.JSONStringName)
        animationView.setDimensions(height: viewModel.animationViewDimension.0, width: viewModel.animationViewDimension.1)
        animationView.play()
        animationView.loopMode = .loop
//
//        addSubview(stackView)
//        stackView.centerX(inView: animationView, topAnchor: animationView.bottomAnchor, paddingTop: 10)
//        stackView.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 50, paddingRight: 50)
        titleLabel.text =  viewModel.titleLabel
        detailsLabel.text = viewModel.detailsLabel
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
