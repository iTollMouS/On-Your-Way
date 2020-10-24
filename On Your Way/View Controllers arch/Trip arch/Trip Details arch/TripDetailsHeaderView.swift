//
//  TripDetailsHeaderView.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 10/4/20.
//

import UIKit
import Cosmos
import SDWebImage


// MARK: - protocol
protocol TripDetailsHeaderViewDelegate: class {
    func handleStartToChat(_ view: TripDetailsHeaderView)
    func handleReviewsTapped(_ view: TripDetailsHeaderView)
}

class TripDetailsHeaderView: UIView {
    
    
    // MARK: - delegate
    weak var delegate: TripDetailsHeaderViewDelegate?
    
    
    // MARK: - User
    var user: User?{
        didSet{configure()}
    }
    
    
    private lazy var checkMarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark.seal.fill"), for: .normal)
        button.tintColor = .systemGreen
        button.backgroundColor = .white
        button.imageView?.setDimensions(height: 20, width: 20)
        button.setDimensions(height: 20, width: 20)
        button.layer.cornerRadius = 20 / 2
        button.clipsToBounds = true
        return button
    }()
    
    
    // MARK: - Properties
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setDimensions(height: 100, width: 100)
        imageView.layer.cornerRadius = 100 / 2
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = false
        imageView.backgroundColor = .white
        imageView.layer.borderWidth = 0.8
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private lazy var fullnameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .lightGray
        label.setHeight(height: 30)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 22)
        return label
    }()
    
    private lazy var phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .lightGray
        label.setHeight(height: 30)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 22)
        return label
    }()
    
    private lazy var userInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [fullnameLabel,
                                                       phoneNumberLabel,
                                                       ratingView,
                                                       startChatButton])
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.distribution = .fill
        stackView.setWidth(width: 160)
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var ratingView: CosmosView = {
        let view = CosmosView()
        view.settings.fillMode = .precise
        view.settings.filledImage = #imageLiteral(resourceName: "RatingStarFilled").withRenderingMode(.alwaysOriginal)
        view.settings.emptyImage = #imageLiteral(resourceName: "RatingStarEmpty").withRenderingMode(.alwaysOriginal)
        view.settings.starSize = 24
        view.settings.totalStars = 5
        view.settings.starMargin = 3.0
        view.settings.updateOnTouch = false
        view.backgroundColor = .clear
        view.setHeight(height: 40)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleReviewTapped)))
        return view
    }()
    
     lazy var startChatButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.4745098039, blue: 0.4431372549, alpha: 1).withAlphaComponent(0.4)
        button.tintColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
        button.setTitle("Chat with ", for: .normal)
        button.setImage(UIImage(systemName: "bubble.left.and.bubble.right.fill"), for: .normal)
        button.setDimensions(height: 50, width: 160)
        button.layer.cornerRadius = 50 / 2
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.setTitleColor(#colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1), for: .normal)
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.1, radius: 10, offset: CGSize(width: 0.0, height: 3), color: .white)
        button.addTarget(self, action: #selector(handleStartToChat), for: .touchUpInside)
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 300).isActive = true
        backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        addSubview(profileImageView)
        profileImageView.centerX(inView: self, topAnchor: topAnchor, paddingTop: 20)
        
        addSubview(checkMarkButton)
        checkMarkButton.anchor(top: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: -26)
        
        
        addSubview(userInfoStackView)
        userInfoStackView.centerX(inView: self, topAnchor: profileImageView.bottomAnchor, paddingTop: 6)
        userInfoStackView.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 20, paddingRight: 20)
        
    }
    
    func configure(){
        guard let user = user else { return }
        guard let imageUrl = URL(string: user.avatarLink) else { return }
        checkMarkButton.isHidden = !user.isUserVerified
        ratingView.rating = Double(user.sumAllReviews / user.reviewsCount).isNaN ? 0.0 : Double(user.sumAllReviews / user.reviewsCount)
        ratingView.text = "5/\((user.sumAllReviews / user.reviewsCount).isNaN ?  "\(0.0)" : "\(Double(user.sumAllReviews / user.reviewsCount))" )"
        profileImageView.sd_setImage(with: imageUrl)
        profileImageView.clipsToBounds = true
        fullnameLabel.text = user.username
        phoneNumberLabel.text = user.phoneNumber
        
    }
    
    @objc fileprivate func handleReviewTapped(){
        delegate?.handleReviewsTapped(self)
    }
    
    @objc func handleStartToChat(){
        delegate?.handleStartToChat(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
