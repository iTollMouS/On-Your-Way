//
//  MessagesCell.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 10/2/20.
//

import UIKit

class RecentCell: UITableViewCell {
    
    
    
    
    var recentChat: RecentChat?{
        didSet{ configure() }
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
    
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setDimensions(height: 50, width: 50)
        imageView.layer.cornerRadius = 50 / 2
        imageView.backgroundColor = .gray
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = false
        imageView.layer.borderWidth = 0.8
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    
    private lazy var accessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setDimensions(height: 18, width: 12)
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.backgroundColor = .clear
        imageView.tintColor = .gray
        return imageView
    }()
    
    lazy var recentMessageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var fullnameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return label
    }()
    
    private lazy var timestampLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.setWidth(width: 100)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .lightGray
        return label
    }()
    
    lazy var counterMessageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.backgroundColor = .green
        label.backgroundColor = .blueLightIcon
        label.setDimensions(height: 40, width: 40)
        label.layer.cornerRadius = 40 / 2
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [fullnameLabel, recentMessageLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        
        addSubview(accessoryImageView)
        accessoryImageView.centerY(inView: self)
        accessoryImageView.anchor(right: rightAnchor, paddingRight: 16)
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self)
        profileImageView.anchor(right: accessoryImageView.leftAnchor, paddingRight: 12)
        
        addSubview(checkMarkButton)
        checkMarkButton.anchor(top: profileImageView.bottomAnchor, right: profileImageView.rightAnchor,
                               paddingTop: -16, paddingRight: -4)
        
        
        addSubview(timestampLabel)
        timestampLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 6, paddingLeft: 8)
        
        
        addSubview(counterMessageLabel)
        counterMessageLabel.centerX(inView: timestampLabel)
        counterMessageLabel.centerY(inView: self)
        
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: counterMessageLabel.rightAnchor, bottom: bottomAnchor,
                         right: profileImageView.leftAnchor, paddingTop: 16, paddingLeft: 20, paddingBottom: 20, paddingRight: 30)
        
    }
    
    func configure(){
        guard let recent = recentChat else { return  }
        timestampLabel.text = recent.date?.convertToTimeAgo(style: .abbreviated)
        recentMessageLabel.text = recent.lastMessage
        fullnameLabel.text = recent.receiverName
        
        if recent.unreadCounter != 0 {
            self.counterMessageLabel.text = recent.unreadCounter.toString()
            self.counterMessageLabel.isHidden = false
        } else {
            self.counterMessageLabel.isHidden = true
        }
        
        FileStorage.downloadImage(imageUrl: recent.profileImageView) { image in
            guard let image = image else {
                self.profileImageView.image = #imageLiteral(resourceName: "btn_google_light_pressed_ios") // if image is empty
                self.profileImageView.clipsToBounds = true
                self.profileImageView.layer.cornerRadius = 50 / 2
                return
            }
            self.profileImageView.image = image.circleMasked
        }
        UserServices.shared.fetchUser(userId: recent.receiverId) { [weak self] user in
            self?.checkMarkButton.isHidden = !user.isUserVerified
        }
        
        
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
