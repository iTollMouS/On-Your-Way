//
//  TableHeaderView.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/28/20.
//

import UIKit
import Lottie

class TableHeaderView: UIView {
    
    private lazy var animation = Animation.named("covid_19_protect")
    private lazy var animationView = AnimationView(animation: animation)

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Safety guidelines Covid-19 "
        label.font = .boldSystemFont(ofSize: 24)
        label.setHeight(height: 40)
        label.numberOfLines = 0
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    
    private lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "covid-19 guidelines for exchanging and handling packages by local healthcare "
        label.font = .systemFont(ofSize: 16)
        label.setHeight(height: 100)
        label.numberOfLines = 0
        label.textColor = UIColor.white.withAlphaComponent(0.4)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel,
                                                       detailsLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(animationView)
        animationView.centerX(inView: self, topAnchor: topAnchor, paddingTop: 16)
        addSubview(stackView)
        stackView.centerX(inView: animationView, topAnchor: animationView.bottomAnchor, paddingTop: 12)
        stackView.anchor(left: leftAnchor, bottom: bottomAnchor , right: rightAnchor, paddingLeft: 16, paddingRight: 16)
        backgroundColor = .clear
        configureAnimationView()
    }
    
    func configureAnimationView(){
        animationView.loopMode = .loop
        animationView.play()
        animationView.contentMode = .scaleAspectFill
        animationView.setDimensions(height: 130, width: 130)
        animationView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
