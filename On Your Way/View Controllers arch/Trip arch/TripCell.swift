//
//  TripCell.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/11/20.
//

import UIKit
import Cosmos
import SDWebImage

// MARK: - Protocol
protocol TripCellDelegate: class {
    func handleDisplayReviews(_ cell: UITableViewCell, selectedTrip: Trip)
}

class TripCell: UITableViewCell {
    
    
    // MARK: - delegate
    weak var delegate: TripCellDelegate?
    

    // MARK: - var trip
    var trip: Trip? {
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
    
    
    // MARK: - Properties
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.setDimensions(height: 50, width: 50)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50 / 2
        imageView.layer.borderWidth = 0.8
        imageView.layer.borderColor = UIColor.white.cgColor
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
    
    
    // MARK: - citiesStackView
    private lazy var citiesStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentLocation, destinationLocation])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.setWidth(width: 120)
        return stackView
    }()
    
    private lazy var priceBaseLabel: UILabel = {
        let label =  createLabel(titleText: "", titleTextSize: 14, titleColor: #colorLiteral(red: 0.5254901961, green: 0.5254901961, blue: 0.5254901961, alpha: 1),
                                 detailsText: "", detailsTextSize: 18,
                                 detailsColor: #colorLiteral(red: 0.7137254902, green: 0.7137254902, blue: 0.7137254902, alpha: 1), textAlignment: .left, setHeight: 20)
        label.setHeight(height: 20)
        return label
    }()
    
    
    private lazy var packagesTypes: UILabel = {
        let label = createLabel(titleText: "", titleTextSize: 14, titleColor: #colorLiteral(red: 0.5254901961, green: 0.5254901961, blue: 0.5254901961, alpha: 1),
                                detailsText: "", detailsTextSize: 18,
                                detailsColor: #colorLiteral(red: 0.7137254902, green: 0.7137254902, blue: 0.7137254902, alpha: 1), textAlignment: .left, setHeight: 50)
        label.setHeight(height: 140)
        return label
    }()
    
    
    
    // MARK: - ratingView
    private lazy var ratingView: CosmosView = {
        let view = CosmosView()
        view.settings.fillMode = .precise
        view.settings.filledImage = #imageLiteral(resourceName: "RatingStarFilled").withRenderingMode(.alwaysOriginal)
        view.settings.emptyImage = #imageLiteral(resourceName: "RatingStarEmpty").withRenderingMode(.alwaysOriginal)
        view.settings.starSize = 18
        view.settings.totalStars = 5
        view.settings.starMargin = 3.0
        view.settings.textColor = .white
        view.rating = 0
        view.settings.updateOnTouch = false
        view.isUserInteractionEnabled = true
        view.settings.textColor = .systemBlue
        view.settings.textMargin = 10
        view.text = "No reviews"
        view.settings.textFont = UIFont.systemFont(ofSize: 14)
        view.backgroundColor = .clear
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleReviewTapped)))
        return view
    }()
    
    
    
    // MARK: - containerInfoStackView
    private lazy var containerInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [priceBaseLabel,
                                                       packagesTypes,
                                                       ratingView])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = -30
        return stackView
    }()
    
    
    
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 32, paddingLeft: 8)
        
        addSubview(checkMarkButton)
        checkMarkButton.anchor(top: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: -14)
        
        
        addSubview(fullnameLable)
        fullnameLable.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
        addSubview(timestampLabel)
        timestampLabel.anchor(top: topAnchor, right: rightAnchor, paddingTop: 36, paddingRight: 8)
        
        // construct the dots and the line in between
        addSubview(fromCityDot)
        fromCityDot.centerX(inView: profileImageView, topAnchor: profileImageView.bottomAnchor, paddingTop: 18)
        
        
        
        addSubview(destinationCityDot)
        destinationCityDot.centerX(inView: fromCityDot, topAnchor: fromCityDot.bottomAnchor, paddingTop: 100)
        addSubview(lineBetweenCities)
        lineBetweenCities.centerX(inView: fromCityDot)
        lineBetweenCities.anchor(top: fromCityDot.bottomAnchor,
                                 bottom: destinationCityDot.topAnchor,
                                 paddingTop: 8,
                                 paddingBottom: 8)
        
        
        
        addSubview(citiesStackView)
        citiesStackView.centerY(inView: lineBetweenCities, leftAnchor: lineBetweenCities.rightAnchor, paddingLeft: 12)
        citiesStackView.anchor(top: fromCityDot.topAnchor, bottom: destinationCityDot.bottomAnchor, paddingTop: -15, paddingBottom: -15)
        addSubview(containerInfoStackView)
        containerInfoStackView.anchor(top: fullnameLable.bottomAnchor, left: citiesStackView.rightAnchor,
                                      right: rightAnchor, paddingRight: 12)
        
    }
    
    // MARK: - configure()
    private func configure(){
        guard let trip = trip else { return }
        let viewModel = TripViewModel(trip: trip)
        
        UserServices.shared.fetchUser(userId: trip.userID) { [weak self] user in
            guard let imageUrl = URL(string: user.avatarLink) else { return }
            self?.profileImageView.sd_setImage(with: imageUrl)
            self?.fullnameLable.text = user.username
            self?.ratingView.rating = Double(user.sumAllReviews / user.reviewsCount).isNaN ? 0.0 : Double(user.sumAllReviews / user.reviewsCount)
            self?.ratingView.text = "5/\((user.sumAllReviews / user.reviewsCount).isNaN ?  "\(0.0)" : "\(Double(user.sumAllReviews / user.reviewsCount))" )"
            self?.checkMarkButton.isHidden = !user.isUserVerified
        }
        
        timestampLabel.text = viewModel.timestamp
        priceBaseLabel.attributedText = viewModel.basePriceAttributedText
        destinationLocation.text = viewModel.destinationLocation
        departureTime.text = viewModel.tripDepartureTime
        packagesTypes.attributedText = viewModel.packageTypeAttributedText
        currentLocation.attributedText = viewModel.currentLocationInfoAttributedText
        destinationLocation.attributedText = viewModel.destinationLocationInfoAttributedText
        
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
        label.textAlignment = textAlignment
        label.numberOfLines = 4
        return label
    }
    
    
    // MARK: - Actions
    @objc private func handleReviewTapped(){
        guard let trip = trip else { return }
        delegate?.handleDisplayReviews(self, selectedTrip: trip)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
