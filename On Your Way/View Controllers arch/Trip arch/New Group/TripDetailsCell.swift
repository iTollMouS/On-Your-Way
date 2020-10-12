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
    
    private lazy var fromCityLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "Arrass\n", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray,
                                                                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        attributedText.append(NSMutableAttributedString(string: "09:12 PM, 12/22/2020", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray,
                                                                                                     NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.setHeight(height: 50)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private lazy var destinationLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "Arrass\n", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray,
                                                                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        attributedText.append(NSMutableAttributedString(string: "09:12 PM, 12/22/2020", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray,
                                                                                                     NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.setHeight(height: 50)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var wheretToMeetLabel: UILabel = {
        let label = UILabel()
        label.text = "in the south side of Michigan "
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private lazy var citiesStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [fromCityLabel, destinationLabel])
        stackView.axis = .vertical
        stackView.spacing = 50
        stackView.setDimensions(height: 200, width: 400)
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func configureUI(){
        guard let viewModel = viewModel else { return  }
        switch viewModel {
        case .fromCityToCity: configureSection_0()
        case .whereToMeet: configureSection_1()
        case .whatCanITake:
            print("")
        case .WhenToMeet:
            print("")
        case .packageAllowance:
            print("")
        }
    }
    
    func configureSection_0(){
        addSubview(fromCityDot)
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
        addSubview(wheretToMeetLabel)
        wheretToMeetLabel.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

enum TripDetailsViewModel: Int, CaseIterable {
    case fromCityToCity
    case whereToMeet
    case whatCanITake
    case WhenToMeet
    case packageAllowance
    
    var cellHeight: CGFloat {
        switch self {
        case .fromCityToCity: return 160
        case .whereToMeet: return 50
        case .whatCanITake: return 50
        case .WhenToMeet: return 50
        case .packageAllowance: return 50
        }
    }
    
    var numberOfCell: Int {
        switch self {
        case .fromCityToCity: return 1
        case .whereToMeet: return 1
        case .whatCanITake: return 1
        case .WhenToMeet: return 1
        case .packageAllowance: return 1
        }
    }
    
    var titleInSection: String {
        switch self {
        
        case .fromCityToCity: return "Trip Destination"
        case .whereToMeet: return "Place to meet"
        case .whatCanITake: return "What I can take with me"
        case .WhenToMeet: return "Where the place to meet to take packages"
        case .packageAllowance: return "Non of the times"
        }
    }
    
    var heightInSection: CGFloat {
        switch self {
        case .fromCityToCity: return 40
        case .whereToMeet: return 60
        case .whatCanITake: return 60
        case .WhenToMeet: return 60
        case .packageAllowance: return 60
        }
    }
    
    
}
