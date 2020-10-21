//
//  NotificationCell.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/14/20.
//

import UIKit
import SDWebImage
class NotificationCell: UITableViewCell {
    
    
    // MARK: - Properties
    var package: Package?{
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
        return button
    }()
    
    private lazy var packageStatusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var timestamp: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var travelerName: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var travelerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.setDimensions(height: 50, width: 50)
        imageView.layer.cornerRadius = 50 / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var packageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.setDimensions(height: 60, width: 60)
        imageView.layer.cornerRadius = 60 / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        addSubview(travelerImageView)
        travelerImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12)
        
        addSubview(checkMarkButton)
        checkMarkButton.anchor(top: travelerImageView.bottomAnchor, right: travelerImageView.rightAnchor,
                               paddingTop: -14, paddingRight: -4)
        
        
        addSubview(timestamp)
        timestamp.anchor(top: topAnchor, right: rightAnchor, paddingTop: 12, paddingRight: 12)
        
        addSubview(packageImageView)
        packageImageView.centerX(inView: timestamp, topAnchor: timestamp.bottomAnchor, paddingTop: 12)
        packageImageView.anchor(right : rightAnchor, paddingRight: 40)
        
        
        addSubview(packageStatusLabel)
        packageStatusLabel.anchor(top: topAnchor, left: travelerImageView.rightAnchor, bottom: bottomAnchor, right: packageImageView.leftAnchor,
                                  paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
        
    }
    
    
    // MARK: - configure
    fileprivate func configure(){
        guard let package = package else { return }
        let viewModel = PackageViewModel(package: package)
        TripService.shared.fetchUserFromTrip(tripId: viewModel.tripId) { [weak self] user in
            DispatchQueue.main.async { [weak self] in
                guard let imageUrl = URL(string: user.avatarLink) else {return}
                self?.travelerImageView.sd_setImage(with: imageUrl)
                self?.travelerName.text = user.username
            }
        }
        packageImageView.sd_setImage(with: viewModel.packageImages.first)
        timestamp.text = viewModel.timestamp
        
        
        // MARK: - switch viewModel
        switch viewModel.packageStatus {
        case .packageIsPending:
            packageStatusLabel.attributedText = attributedText(title: "Your package status:",
                                                               details: viewModel.packageStatus.rawValue,
                                                               textColor: .systemYellow)
        case .packageIsRejected:
            packageStatusLabel.attributedText = attributedText(title: "Your package status:",
                                                               details: viewModel.packageStatus.rawValue,
                                                               textColor: .systemRed)
        case .packageIsAccepted:
            packageStatusLabel.attributedText = attributedText(title: "Your package status:",
                                                               details: viewModel.packageStatus.rawValue,
                                                               textColor: .systemGreen)
        case .packageIsDelivered:
            packageStatusLabel.attributedText = attributedText(title: "Your package status:",
                                                               details: viewModel.packageStatus.rawValue,
                                                               textColor: .systemBlue)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func attributedText(title: String, details: String, textColor: UIColor) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: title,
                                                       attributes: [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                                    NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSMutableAttributedString(string: "\n\(details)",
                                                        attributes: [NSAttributedString.Key.foregroundColor : textColor,
                                                                     NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]))
        return attributedText
    }
    
}
