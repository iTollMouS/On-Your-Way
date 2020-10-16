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
    
    private lazy var recentMessageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var fullnameLabel: UILabel = {
        let label = UILabel()
        label.text = "Tariq Almazyad"
        label.textAlignment = .left
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
    
    private lazy var counterMessageLabel: UILabel = {
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
        accessoryType = .disclosureIndicator
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        addSubview(timestampLabel)
        timestampLabel.anchor(top: topAnchor, right: rightAnchor, paddingTop: 6, paddingRight: 12)
        
        
        addSubview(counterMessageLabel)
        counterMessageLabel.centerX(inView: timestampLabel)
        counterMessageLabel.centerY(inView: profileImageView)
        
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor,
                         right: counterMessageLabel.leftAnchor, paddingTop: 16, paddingLeft: 20, paddingBottom: 20, paddingRight: 30)
        
    }
    
    func configure(){
        guard let recent = recentChat else { return  }
        timestampLabel.text = recent.date?.convertToTimeAgo(style: .abbreviated)
        recentMessageLabel.text = recent.lastMessage
        if recent.unreadCounter != 0 {
            self.counterMessageLabel.text = "\(recent.unreadCounter)"
            self.counterMessageLabel.isHidden = false
        } else {
            self.counterMessageLabel.isHidden = true
        }
        
        FileStorage.downloadImage(imageUrl: recent.profileImageView) { image in
            guard let image = image else {
                self.profileImageView.image = #imageLiteral(resourceName: "btn_google_light_pressed_ios") // if image is empty
                return
            }
            self.profileImageView.image = image.circleMasked
        }
        
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
