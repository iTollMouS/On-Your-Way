//
//  NotificationsDetailsCell.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/20/20.
//

import UIKit

protocol NotificationsDetailsCellDelegate: class {
    func handleStartChat(_ cell: NotificationsDetailsCell)
}

class NotificationsDetailsCell: UITableViewCell {

    
    weak var delegate: NotificationsDetailsCellDelegate?
    
    var package: Package?{
        didSet{configure()}
    }
    
    var traveler: User?{
        didSet{configureTraveler()}
    }
    
    lazy var startChatButton = createButton(title: "Chat with \(traveler?.username ?? "" )", backgroundColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1), colorAlpa: 0.4, systemName: "bubble.left.and.bubble.right.fill")
    
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
    
    private lazy var packageTypeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(packageTypeLabel)
        packageTypeLabel.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    
    
    fileprivate func configure(){
        guard let package = package else { return }
        packageTypeLabel.text = package.packageType
        backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1)
    }
    
    fileprivate func configureTraveler(){
        backgroundColor = .clear
        selectionStyle = .none
        guard let traveler = traveler else { return  }
        addSubview(travelerImageView)
        travelerImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
        addSubview(travelerName)
        travelerName.centerY(inView: travelerImageView, leftAnchor: travelerImageView.rightAnchor, paddingLeft: 12)
        addSubview(startChatButton)
        startChatButton.centerX(inView: self, topAnchor: travelerName.bottomAnchor, paddingTop: 30)
        FileStorage.downloadImage(imageUrl: traveler.avatarLink) { [weak self] image in
            self?.travelerImageView.image = image
            self?.travelerName.text = traveler.username
        }
        
        
    }
    
    @objc fileprivate func handleActions(){
        delegate?.handleStartChat(self)
    }
    
    fileprivate func createButton(title: String?, backgroundColor: UIColor, colorAlpa: CGFloat, systemName: String  ) -> UIButton {
        let button = UIButton(type: .system)
        guard let title = title else { return UIButton() }
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.titleLabel?.numberOfLines = 0
        button.setTitle("\(title) order ", for: .normal)
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.backgroundColor = backgroundColor.withAlphaComponent(alpha)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleActions), for: .touchUpInside)
        button.setDimensions(height: 50, width: 280)
        button.layer.cornerRadius = 50 / 2
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.5, radius: 16, offset: CGSize(width: 0.0, height: 8.0), color: backgroundColor)
        return button
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
