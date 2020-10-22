//
//  AdminCell.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/22/20.
//

import UIKit
import SDWebImage

class AdminCell: UITableViewCell {
    
    
    
    var user: User?{
        didSet{configure()}
    }
    
    private lazy var checkMarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark.seal.fill"), for: .normal)
        button.tintColor = .systemGreen
        button.backgroundColor = .white
        button.imageView?.setDimensions(height: 14, width: 14)
        button.setDimensions(height: 14, width: 14)
        button.layer.cornerRadius = 14 / 2
        button.clipsToBounds = true
        button.isHidden = true
        
        return button
    }()
    
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.text = "tariq almazyad"
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.text = "0500845000"
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.setDimensions(height: 50, width: 50)
        imageView.layer.cornerRadius = 50 / 2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 0.8
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userNameLabel,
                                                       phoneNumberLabel])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        
        addSubview(checkMarkButton)
        checkMarkButton.anchor(top: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: -14)
        
        addSubview(stackView)
        stackView.centerY(inView: self, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
    }
    
    fileprivate func configure(){
        guard let user = user else { return  }
        DispatchQueue.main.async { [weak self] in
            UserServices.shared.fetchUser(userId: user.id) { [weak self] user in
                guard let imageUrl = URL(string: user.avatarLink) else {return}
                self?.userNameLabel.text = user.username
                self?.profileImageView.sd_setImage(with: imageUrl)
                self?.phoneNumberLabel.text = user.phoneNumber
                self?.checkMarkButton.isHidden = !user.isUserVerified
            }
        }
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
