//
//  PeopleReviewsCell.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 10/1/20.
//

import UIKit
import Cosmos

class PeopleReviewsCell: UITableViewCell {
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setDimensions(height: 50, width: 50)
        imageView.layer.cornerRadius = 50 / 2
        imageView.backgroundColor = .gray
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = false
        imageView.setupShadow(opacity: 0.3, radius: 10, offset: CGSize(width: 0, height: 0.8), color: .white)
        return imageView
    }()
    
    
    private lazy var fullname: UILabel = {
        let label = UILabel()
        label.text = "Tariq Almazyad"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var timestamp: UILabel = {
        let label = UILabel()
        label.text = "5 days ago"
        label.textAlignment = .right
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var ratingView: CosmosView = {
        let view = CosmosView()
        view.settings.fillMode = .half
        view.settings.filledImage = #imageLiteral(resourceName: "RatingStarFilled").withRenderingMode(.alwaysOriginal)
        view.settings.emptyImage = #imageLiteral(resourceName: "RatingStarEmpty").withRenderingMode(.alwaysOriginal)
        view.settings.starSize = 18
        view.settings.totalStars = 5
        view.settings.starMargin = 3.0
        view.text = "4.3"
        view.settings.textColor = .lightGray
        view.settings.textMargin = 10
        view.settings.textFont = UIFont.systemFont(ofSize: 14)
        view.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        view.setDimensions(height: 30, width: 130)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [fullname, ratingView])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    

     lazy var reviewLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.layer.cornerRadius = 10
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 16)
        
        addSubview(stackView)
        stackView.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
        
        addSubview(timestamp)
        timestamp.centerY(inView: stackView)
        timestamp.anchor(right: rightAnchor, paddingRight: 16)
        
        addSubview(reviewLabel)
        reviewLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor,
                              right: rightAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 12, paddingRight: 12)

    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
