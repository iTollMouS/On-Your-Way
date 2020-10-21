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
    
    
    private lazy var checkMarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark.seal.fill"), for: .normal)
        button.tintColor = .systemGreen
        button.backgroundColor = .white
        button.imageView?.setDimensions(height: 18, width: 18)
        button.setDimensions(height: 18, width: 18)
        button.layer.cornerRadius = 18 / 2
        button.clipsToBounds = true
        button.isHidden = true
        return button
    }()
    
    
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setDimensions(height: 80, width: 80)
        imageView.layer.cornerRadius = 80 / 2
        imageView.backgroundColor = .gray
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = false
        imageView.setupShadow(opacity: 0.4, radius: 10, offset: CGSize(width: 0.0, height: 0.4), color: .white)
        imageView.layer.masksToBounds = false
        imageView.isUserInteractionEnabled = true
        imageView.layer.borderWidth = 0.8
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
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
        label.textAlignment = .left
        label.setHeight(height: 60)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var ratingView: CosmosView = {
        let view = CosmosView()
        view.settings.fillMode = .precise
        view.settings.filledImage = #imageLiteral(resourceName: "RatingStarFilled").withRenderingMode(.alwaysOriginal)
        view.settings.emptyImage = #imageLiteral(resourceName: "RatingStarEmpty").withRenderingMode(.alwaysOriginal)
        view.settings.starSize = 16
        view.settings.textColor = .white
        view.settings.textFont = UIFont.systemFont(ofSize: 14)
        view.settings.totalStars = 5
        view.settings.starMargin = 3.0
        view.rating = 0.0
        view.text = "No reviews"
        view.settings.updateOnTouch = false
        view.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        view.setDimensions(height: 50, width: 130)
        return view
    }()
    
    private lazy var reviewStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [reviewRate,
                                                       ratingView])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.setHeight(height: 60)
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [profileImageView,
                                                       reviewStackView])
        stackView.axis = .horizontal
        stackView.spacing = 18
        stackView.setDimensions(height: 80, width: 240)
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        return stackView
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 300).isActive = true
        backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        addSubview(titleLabel)
        titleLabel.centerX(inView: self, topAnchor: topAnchor, paddingTop: 90)
        addSubview(mainStackView)
        mainStackView.centerX(inView: self, topAnchor: titleLabel.bottomAnchor, paddingTop: 40)
    }
    
    fileprivate func configure(){
        guard let user = user else { return }
        checkMarkButton.isHidden = !user.isUserVerified
        guard let imageUrl = URL(string: user.avatarLink) else { return }
        profileImageView.sd_setImage(with: imageUrl)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.clipsToBounds = true
        
        
        addSubview(checkMarkButton)
        checkMarkButton.anchor(top: profileImageView.bottomAnchor, right: profileImageView.rightAnchor,
                               paddingTop: -24, paddingRight: -2)
        
        
        ratingView.rating = Double(user.sumAllReviews / user.reviewsCount).isNaN ? 0.0 : Double(user.sumAllReviews / user.reviewsCount)
        ratingView.text = "5/\((user.sumAllReviews / user.reviewsCount).isNaN ?  "\(0.0)" : "\(Double(user.sumAllReviews / user.reviewsCount))" )"
        
        let attributedText = NSMutableAttributedString(string: "\(user.username) has\n", attributes: [.foregroundColor : UIColor.lightGray,
                                                                                                      .font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSMutableAttributedString(string: "\(user.reviewsCount) reviews", attributes: [.foregroundColor : UIColor.gray,
                                                                                                             .font: UIFont.systemFont(ofSize: 14)]))
        reviewRate.attributedText = attributedText
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
