//
//  MessagesCell.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 10/2/20.
//

import UIKit

class RecentCell: UITableViewCell {
    
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
        label.text = "Hello there , could you please take it wit you ?"
        label.textAlignment = .left
        label.numberOfLines = 3
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var fullnameLabel: UILabel = {
        let label = UILabel()
        label.text = "Tariq Almazyad"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var timestampLabel: UILabel = {
        let label = UILabel()
        label.text = "5 hours ago"
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
        label.text = "1000"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.backgroundColor = .blueLightIcon
        label.setDimensions(height: 40, width: 40)
        label.layer.cornerRadius = 40 / 2
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [fullnameLabel, recentMessageLabel])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        addSubview(timestampLabel)
        timestampLabel.anchor(top: topAnchor, right: rightAnchor, paddingTop: 6, paddingRight: 12)
        addSubview(counterMessageLabel)
        counterMessageLabel.centerX(inView: timestampLabel)
        counterMessageLabel.centerY(inView: profileImageView)
        accessoryType = .disclosureIndicator
        //        timestampLabel.text = recentChat?.date?.convertToTimeAgo(style: .abbreviated)
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
