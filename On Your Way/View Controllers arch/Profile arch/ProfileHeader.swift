//
//  ProfileHeader.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/30/20.
//

import UIKit
import Cosmos

protocol ProfileHeaderDelegate: class {
    
    func handleUpdatePhoto(_ header: ProfileHeader)
    func usernameChanges(_ header: ProfileHeader)
}

class ProfileHeader: UIView {

    
    var user: User?{
        didSet{ configureUI()}
    }
    
    weak var delegate: ProfileHeaderDelegate?
    
    private lazy var checkMarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark.seal.fill"), for: .normal)
        button.tintColor = .systemGreen
        button.backgroundColor = .white
        button.imageView?.setDimensions(height: 20, width: 20)
        button.setDimensions(height: 20, width: 20)
        button.layer.cornerRadius = 20 / 2
        button.clipsToBounds = true
        button.isHidden = true
        return button
    }()
    
     lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setDimensions(height: 100, width: 100)
        imageView.layer.cornerRadius = 100 / 2
        imageView.backgroundColor = .gray
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = false
        imageView.setupShadow(opacity: 0.4, radius: 10, offset: CGSize(width: 0.0, height: 0.4), color: .white)
        imageView.layer.masksToBounds = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var editImageLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit image"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 10)
        label.setHeight(height: 20)
        return label
    }()
    
     lazy var fullNameTextField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.textColor = .lightGray
        textField.font = UIFont.systemFont(ofSize: 30)
        textField.setHeight(height: 50)
        textField.adjustsFontSizeToFitWidth = true
        return textField
    }()
    
    
     lazy var userStatusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        label.setHeight(height: 50)
        return label
    }()
    
    private lazy var userInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [fullNameTextField, userStatusLabel])
        stackView.axis = .vertical
        stackView.spacing = -20
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var ratingView: CosmosView = {
        let view = CosmosView()
        view.settings.fillMode = .precise
        view.settings.filledImage = #imageLiteral(resourceName: "RatingStarFilled").withRenderingMode(.alwaysOriginal)
        view.settings.emptyImage = #imageLiteral(resourceName: "RatingStarEmpty").withRenderingMode(.alwaysOriginal)
        view.settings.starSize = 24
        view.settings.totalStars = 5
        view.settings.starMargin = 3.0
        view.text = "No reviews"
        view.rating = 0
        view.settings.textColor = .lightGray
        view.settings.disablePanGestures = true
        view.settings.updateOnTouch = false
        view.settings.textMargin = 10
        view.settings.textFont = UIFont.systemFont(ofSize: 14)
        view.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        view.setDimensions(height: 50, width: 250)
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        heightAnchor.constraint(equalToConstant: 300).isActive = true
        addSubview(profileImageView)
        profileImageView.centerX(inView: self, topAnchor: topAnchor, paddingTop: 20)
        addSubview(checkMarkButton)
        checkMarkButton.anchor(top: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: -26)
        
        
        addSubview(userInfoStackView)
        userInfoStackView.centerX(inView: self, topAnchor: profileImageView.bottomAnchor, paddingTop: 20)
        userInfoStackView.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 20, paddingRight: 20)
        addSubview(ratingView)
        ratingView.centerX(inView: userInfoStackView, topAnchor: userInfoStackView.bottomAnchor, paddingTop: 12)
        addSubview(editImageLabel)
        editImageLabel.centerX(inView: profileImageView, topAnchor: profileImageView.bottomAnchor, paddingTop: 2)
        fullNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        
    }
    
    func configureUI(){
        guard let user = user else { return }
        checkMarkButton.isHidden = !user.isUserVerified
        fullNameTextField.text = user.username
        guard let imageUrl = URL(string: user.avatarLink) else { return  }
        profileImageView.sd_setImage(with: imageUrl)
        if user.avatarLink == "" {
            profileImageView.image = #imageLiteral(resourceName: "plus_photo")
            profileImageView.setDimensions(height: 100, width: 100)
            profileImageView.layer.cornerRadius = 100 / 2
            profileImageView.backgroundColor = .clear
        }
        ratingView.rating = Double(user.sumAllReviews / user.reviewsCount).isNaN ? 0.0 : Double(user.sumAllReviews / user.reviewsCount)
        ratingView.text = "5/\((user.sumAllReviews / user.reviewsCount).isNaN ?  "\(0.0)" : "\(Double(user.sumAllReviews / user.reviewsCount))" )"
        
    }
    
    
    @objc private func textFieldDidChange(){
        delegate?.usernameChanges(self)
    }
    
    @objc func handleSelectPhoto(){
        delegate?.handleUpdatePhoto(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
