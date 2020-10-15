//
//  TripDetailsCell.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 10/4/20.
//

import UIKit

class TripDetailsCell: UITableViewCell {
    
    var viewModel: TripDetailsViewModel?{
        didSet{configureUI()}
    }
    
    var trip: Trip?{
        didSet{configure()}
    }
    
    private lazy var fromCityDot: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.setDimensions(height: 5, width: 5)
        view.layer.cornerRadius = 5 / 2
        return view
    }()
    
    private lazy var destinationCityDot: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setDimensions(height: 5, width: 5)
        view.layer.cornerRadius = 5 / 2
        return view
    }()
    
    private lazy var lineBetweenDots: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.setDimensions(height: 5, width: 5)
        view.layer.cornerRadius = 5 / 2
        return view
    }()
    
    private lazy var departureTime: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var currentLocation: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    
    
    private lazy var timestampLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
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
    
    private lazy var packagePickupLocationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var packagePickupTime: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var meetingsInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [packagePickupLocationLabel, packagePickupTime])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    
    
    private lazy var citiesStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentLocation, destinationLocation])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.setDimensions(height: 200, width: 400)
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        return stackView
    }()
    
    
    private lazy var priceBaseLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    
    private lazy var packagesTypes: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func configure(){
        guard let trip = trip else { return }
        let viewModel = TripViewModel(trip: trip)
        
        currentLocation.attributedText = viewModel.currentLocationInfoAttributedText
        destinationLocation.attributedText = viewModel.destinationLocationInfoAttributedText
        
        print("DEBUG: \(viewModel.packagePickupTime)")
        print("DEBUG: \(viewModel.packagePickupLocation)")
        print("DEBUG: \(viewModel.packagePickupTime)")
        packagePickupLocationLabel.text = viewModel.packagePickupLocation
        packagePickupTime.text = viewModel.packagePickupTime
        
        
        packagesTypes.text = viewModel.packageType
        priceBaseLabel.text = viewModel.basePrice
    }
    
    func configureUI(){
        guard let cellViewModel = viewModel else { return  }
        switch cellViewModel {
        case .fromCityToCity: configureSection_0()
        case .whereToMeet: configureSection_1()
        case .packageAllowance: configureSection_2()
        case .basePrice: configureSection_3()
        }
    }
    
    func configureSection_0(){
        addSubview(fromCityDot)
        heightAnchor.constraint(equalToConstant: 150).isActive = true
        fromCityDot.anchor(top: topAnchor, left: leftAnchor, paddingTop: 20, paddingLeft: 50)
        
        addSubview(destinationCityDot)
        destinationCityDot.centerX(inView: fromCityDot, topAnchor: fromCityDot.bottomAnchor, paddingTop: 120)
        
        addSubview(lineBetweenDots)
        lineBetweenDots.centerX(inView: fromCityDot)
        lineBetweenDots.anchor(top: fromCityDot.bottomAnchor, bottom: destinationCityDot.topAnchor, paddingTop: 10, paddingBottom: 10)
        
        addSubview(citiesStackView)
        citiesStackView.centerY(inView: lineBetweenDots, leftAnchor: lineBetweenDots.rightAnchor, paddingLeft: 12)
        citiesStackView.anchor(top: fromCityDot.topAnchor, bottom: destinationCityDot.bottomAnchor)
        backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
    }
    
    func configureSection_1(){
        addSubview(meetingsInfoStackView)
        meetingsInfoStackView.fillSuperview(padding: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1)
    }
    
    func configureSection_2(){
        addSubview(packagesTypes)
        packagesTypes.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1)
    }
    
    func configureSection_3(){
        addSubview(priceBaseLabel)
        priceBaseLabel.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
}

enum TripDetailsViewModel: Int, CaseIterable {
    case fromCityToCity
    case whereToMeet
    case packageAllowance
    case basePrice
    
    var numberOfCell: Int {
        switch self {
        case .fromCityToCity: return 1
        case .whereToMeet: return 1
        case .packageAllowance: return 1
        case .basePrice: return 1
        }
    }
    
    var titleInSection: String {
        switch self {
        case .fromCityToCity: return "Trip Destination"
        case .whereToMeet: return "Place and time to meet for picking a package"
        case .packageAllowance: return "What I can take with me"
        case .basePrice: return "the base price"
        }
    }
    
    var heightInSection: CGFloat {
        switch self {
        case .fromCityToCity: return 40
        case .whereToMeet: return 60
        case .packageAllowance: return 60
        case .basePrice: return 60
        }
    }
    
    
}
