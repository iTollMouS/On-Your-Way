//
//  OrderCell.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 10/6/20.
//

import UIKit
import SDWebImage

class OrderCell: UITableViewCell {
    
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
        button.isHidden = true
        return button
    }()
    
    
    
    private lazy var packageDescription: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .white
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var timestamp: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var packageOwnerName: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var packageOwnerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.setDimensions(height: 50, width: 50)
        imageView.layer.cornerRadius = 50 / 2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 0.8
        imageView.layer.borderColor = UIColor.white.cgColor
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        
        addSubview(packageOwnerImageView)
        packageOwnerImageView.anchor(top: topAnchor, right: rightAnchor, paddingTop: 24, paddingRight: 8)
        
        
        addSubview(checkMarkButton)
        checkMarkButton.anchor(top: packageOwnerImageView.bottomAnchor, right: packageOwnerImageView.rightAnchor, paddingTop: -14)
        
        
        addSubview(packageOwnerName)
        packageOwnerName.centerY(inView: packageOwnerImageView)
        packageOwnerName.anchor(right: packageOwnerImageView.leftAnchor, paddingRight: 20)
        
        
        addSubview(timestamp)
        timestamp.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12)
        
        
        addSubview(packageImageView)
        packageImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 6 )
        
        
        addSubview(packageDescription)
        packageDescription.anchor(top: packageOwnerImageView.bottomAnchor, left: packageImageView.rightAnchor,
                           bottom: bottomAnchor, right: packageOwnerImageView.leftAnchor,
                           paddingTop: 10, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
        
    }
    
    fileprivate func configure(){
        guard let package = package else { return }
        let viewModel = PackageViewModel(package: package)
        
        UserServices.shared.fetchUser(userId: viewModel.packageOwnerId) { [weak self] user in
            guard let imageUrl = URL(string: user.avatarLink) else {return}
            self?.packageOwnerImageView.sd_setImage(with: imageUrl)
            self?.packageOwnerName.text = user.username
            self?.checkMarkButton.isHidden = !user.isUserVerified
        }
        
        timestamp.text = viewModel.timestamp
        packageImageView.sd_setImage(with: viewModel.packageImages.first)
        packageDescription.text = viewModel.packageType
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


struct PackageViewModel {
    
    let package: Package
    
    
    var packageStatus : PackageStatus {
        return package.packageStatus
    }
    var packageStatusTimestamp : String {
        return package.packageStatusTimestamp
    }
    
    var packageOwnerId: String {
        return package.userID
    }
    
    var tripId: String {
        return package.tripID
    }
    
    var timestamp: String {
        guard let timestamp = package.timestamp?.convertDate(formattedString: .formattedType10) else { return "" }
        return timestamp
    }
    
    var packageType: String {
        return package.packageType
    }
    
    var packageID: String {
        return package.packageID
    }
    
    var packageImages: [URL]{
        return package.packageImages.map( {URL(string: $0)!})
    }
    
    init(package: Package) {
        self.package = package
        
    }
    
}
