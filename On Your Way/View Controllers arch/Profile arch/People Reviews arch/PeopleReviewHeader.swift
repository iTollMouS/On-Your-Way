//
//  PeopleReviewHeader.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 10/1/20.
//

import UIKit
import Cosmos

class PeopleReviewHeader: UIView {
    
    
    var user: User?{
        didSet{configure()}
    }
    
    
    
    
    
     lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reviews"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.setHeight(height: 30)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 26)
        return label
    }()
    
     lazy var reviewRate: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
     lazy var ratingView: CosmosView = {
        let view = CosmosView()
        view.settings.fillMode = .half
        view.settings.filledImage = #imageLiteral(resourceName: "RatingStarFilled").withRenderingMode(.alwaysOriginal)
        view.settings.emptyImage = #imageLiteral(resourceName: "RatingStarEmpty").withRenderingMode(.alwaysOriginal)
        view.settings.starSize = 24
        view.settings.textColor = .white
        view.settings.textFont = UIFont.systemFont(ofSize: 16)
        view.settings.totalStars = 5
        view.settings.starMargin = 3.0
        view.rating = 0.0
        view.text = "No reviews"
        view.settings.updateOnTouch = false
        view.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        view.setDimensions(height: 50, width: 130)
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 300).isActive = true
        backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        addSubview(titleLabel)
        titleLabel.centerX(inView: self, topAnchor: topAnchor, paddingTop: 90)
        addSubview(reviewRate)
        reviewRate.centerX(inView: self, topAnchor: titleLabel.bottomAnchor, paddingTop: 12)
        reviewRate.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 20, paddingRight: 20)
        addSubview(ratingView)
        ratingView.centerX(inView: self, topAnchor: reviewRate.bottomAnchor, paddingTop: 20)
        
    }
    
    fileprivate func configure(){
       
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
