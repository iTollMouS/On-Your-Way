//
//  NotificationCell.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/14/20.
//

import UIKit
import SDWebImage
class NotificationCell: UITableViewCell {

    var package: Package?{
        didSet{configure()}
    }
    
    private lazy var packageType: UILabel = {
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        addSubview(travelerImageView)
        travelerImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12)
        addSubview(timestamp)
        timestamp.anchor(top: topAnchor, right: rightAnchor, paddingTop: 12, paddingRight: 12)
        addSubview(packageImageView)
        packageImageView.centerX(inView: timestamp, topAnchor: timestamp.bottomAnchor, paddingTop: 12)
        packageImageView.anchor(right : rightAnchor, paddingRight: 40)
        addSubview(packageType)
        packageType.anchor(top: topAnchor, left: travelerImageView.rightAnchor, bottom: bottomAnchor, right: packageImageView.leftAnchor,
                           paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
        
    }
    
    fileprivate func configure(){
        guard let package = package else { return }
        let viewModel = PackageViewModel(package: package)
        print("DEBUG: package is \(viewModel.tripId)")
        TripService.shared.fetchTrip(tripId: viewModel.tripId) { user in
            print("DEBUG: traveler is  \(user.username)")
            guard let imageUrl = URL(string: user.avatarLink) else {return}
            self.travelerImageView.sd_setImage(with: imageUrl)
//            self.travelerName.text = user.username
        }
    
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
