//
//  TripCell.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/11/20.
//

import UIKit
import Cosmos

class TripCell: UITableViewCell {
    
    
    var trip: Trip? {
        didSet{configure()}
    }
    
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.setDimensions(height: 50, width: 50)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50 / 2
        return imageView
    }()
    
    private lazy var timestampLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    
    private lazy var departureTime: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var currentLocation: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    
    private lazy var destinationLocation: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var fullnameLable: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.7058823529, green: 0.7058823529, blue: 0.7058823529, alpha: 1)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var fromCityDot: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.setDimensions(height: 5, width: 5)
        view.layer.cornerRadius = 5 / 2
        return view
    }()
    
    private lazy var lineBetweenCities: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.setWidth(width: 3)
        view.layer.cornerRadius = 2
        return view
    }()
    
    private lazy var destinationCityDot: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setDimensions(height: 5, width: 5)
        view.layer.cornerRadius = 5 / 2
        return view
    }()
    
    private lazy var citiesStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentLocation, destinationLocation])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.setWidth(width: 120)
        return stackView
    }()
    
    private lazy var priceBaseLabel = createLabel(titleText: "", titleTextSize: 14, titleColor: #colorLiteral(red: 0.5254901961, green: 0.5254901961, blue: 0.5254901961, alpha: 1),
                                                  detailsText: "", detailsTextSize: 18,
                                                  detailsColor: #colorLiteral(red: 0.7137254902, green: 0.7137254902, blue: 0.7137254902, alpha: 1), textAlignment: .left, setHeight: 20)
    
    
    private lazy var packagesTypes = createLabel(titleText: "", titleTextSize: 14, titleColor: #colorLiteral(red: 0.5254901961, green: 0.5254901961, blue: 0.5254901961, alpha: 1),
                                                 detailsText: "", detailsTextSize: 18,
                                                 detailsColor: #colorLiteral(red: 0.7137254902, green: 0.7137254902, blue: 0.7137254902, alpha: 1), textAlignment: .left, setHeight: 50)
    
    private lazy var ratingView: CosmosView = {
        let view = CosmosView()
        view.settings.fillMode = .half
        view.settings.filledImage = #imageLiteral(resourceName: "RatingStarFilled").withRenderingMode(.alwaysOriginal)
        view.settings.emptyImage = #imageLiteral(resourceName: "RatingStarEmpty").withRenderingMode(.alwaysOriginal)
        view.settings.starSize = 18
        view.settings.totalStars = 5
        view.settings.starMargin = 3.0
        view.settings.textColor = .white
        view.settings.textMargin = 10
        view.settings.textFont = UIFont.systemFont(ofSize: 14)
        view.backgroundColor = .clear
        view.setHeight(height: 70)
        return view
    }()
    
    
    
    private lazy var containerInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [priceBaseLabel,
                                                       packagesTypes,
                                                       ratingView])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 12
        stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleOptionsTapped)))
        return stackView
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 32, paddingLeft: 8)
        addSubview(fullnameLable)
        fullnameLable.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 4)
        addSubview(timestampLabel)
        timestampLabel.anchor(top: topAnchor, right: rightAnchor, paddingTop: 36, paddingRight: 8)
        
        // construct the dots and the line in between
        addSubview(fromCityDot)
        fromCityDot.centerX(inView: profileImageView, topAnchor: profileImageView.bottomAnchor, paddingTop: 18)
        addSubview(destinationCityDot)
        destinationCityDot.centerX(inView: fromCityDot, topAnchor: fromCityDot.bottomAnchor, paddingTop: 100)
        addSubview(lineBetweenCities)
        lineBetweenCities.centerX(inView: fromCityDot)
        lineBetweenCities.anchor(top: fromCityDot.bottomAnchor, bottom: destinationCityDot.topAnchor, paddingTop: 8, paddingBottom: 8)
        addSubview(citiesStackView)
        citiesStackView.centerY(inView: lineBetweenCities, leftAnchor: lineBetweenCities.rightAnchor, paddingLeft: 12)
        citiesStackView.anchor(top: fromCityDot.topAnchor, bottom: destinationCityDot.bottomAnchor, paddingTop: -15, paddingBottom: -15)
        addSubview(containerInfoStackView)
        containerInfoStackView.anchor(top: fullnameLable.bottomAnchor, left: citiesStackView.rightAnchor, bottom: bottomAnchor,
                             right: rightAnchor, paddingRight: 12)
        
    }
    
    private func configure(){
        guard let trip = trip else { return }
         let viewModel = TripViewModel(trip: trip)
        UserServices.shared.fetchUser(userId: trip.userID) { user in
            FileStorage.downloadImage(imageUrl: user.avatarLink) { imageView in
                self.profileImageView.image = imageView
            }
            self.fullnameLable.text = user.username
        }
        timestampLabel.text = viewModel.timestamp
        priceBaseLabel.text = "\(viewModel.basePrice) SR"
        destinationLocation.text = viewModel.destinationLocation
        departureTime.text = viewModel.tripDepartureTime
        packagesTypes.text = viewModel.packageType
        currentLocation.attributedText = viewModel.currentLocationInfoAttributedText
        destinationLocation.attributedText = viewModel.destinationLocationInfoAttributedText
        
    }
    
    
    @objc func handleOptionsTapped(){
        print("DEBUG: option is tapped")
    }
    
    fileprivate func tripInfoText(location: String, tripDepartureDate: String, tripDepartureTime: String ) -> NSMutableAttributedString{
        let attributedText = NSMutableAttributedString(string: location,
                                                       attributes: [.foregroundColor : #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1),
                                                                    .font: UIFont.systemFont(ofSize: 14)])
        attributedText.append(NSMutableAttributedString(string: "\n\(tripDepartureDate)\n\(tripDepartureTime)",
                                                        attributes: [.foregroundColor : UIColor.lightGray,
                                                                     .font: UIFont.systemFont(ofSize: 12)]))
        return attributedText
    }
    
    fileprivate func createLabel(titleText: String, titleTextSize: CGFloat , titleColor: UIColor,
                                 detailsText: String, detailsTextSize: CGFloat, detailsColor: UIColor,
                                 textAlignment: NSTextAlignment, setHeight: CGFloat  ) -> UILabel {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: titleText,
                                                       attributes: [.foregroundColor : titleColor,
                                                                    .font: UIFont.boldSystemFont(ofSize: titleTextSize)])
        attributedText.append(NSMutableAttributedString(string: detailsText,
                                                        attributes: [.foregroundColor : detailsColor,
                                                                     .font: UIFont.systemFont(ofSize: detailsTextSize)]))
        label.attributedText = attributedText
        label.setHeight(height: setHeight)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = textAlignment
        label.numberOfLines = 0
        return label
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
