//
//  ProfileCell.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/30/20.
//

import UIKit

protocol ProfileCellDelegate: class {
    func showGuidelines(_ cell: ProfileCell)
}

class ProfileCell: UITableViewCell {
    
    var viewModel: ProfileViewModel?{
        didSet{configureUI()}
    }
    
    weak var delegate: ProfileCellDelegate?
    
    private lazy var tellFriendLabel: UILabel = {
        let label = UILabel()
        label.text = "Tell a friend "
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "0500845000 "
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "tariq.almazyad@gmail.com "
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "********** "
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var appVersionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
        label.textColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var covid_19_GuidelinesLabel: UILabel = {
        let label = UILabel()
        label.text = "View covid-19 guidelines "
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0, green: 0.4509803922, blue: 0.9294117647, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var accessoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.setDimensions(height: 30, width: 30)
        button.tintColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
        button.backgroundColor = .clear
        return button
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        
    }
    
    func configureAccessory(){
        addSubview(accessoryButton)
        accessoryButton.centerY(inView: self)
        accessoryButton.anchor(right: rightAnchor, paddingRight: 10)
    }
    
    func configureUI(){
        guard let viewModel = viewModel else { return  }
        switch viewModel {
        case .section_1:
            addSubview(phoneNumberLabel)
            phoneNumberLabel.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            configureAccessory()
        case .section_2:
            addSubview(emailLabel)
            emailLabel.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            configureAccessory()
        case .section_3:
            addSubview(passwordLabel)
            passwordLabel.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            configureAccessory()
        case .section_4:
            addSubview(appVersionLabel)
            appVersionLabel.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        case .section_5:
            addSubview(covid_19_GuidelinesLabel)
            covid_19_GuidelinesLabel.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowGuidelines)))
            accessoryButton.addTarget(self, action: #selector(handleShowGuidelines), for: .touchUpInside)
            configureAccessory()
            
        }
    }
    
    @objc func handleShowGuidelines(){
        delegate?.showGuidelines(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



enum ProfileViewModel: Int, CaseIterable {
    case section_1
    case section_2
    case section_3
    case section_4
    case section_5
    
    var numberOfCells: Int {
        switch self {
        case .section_1: return 1
        case .section_2: return 1
        case .section_3: return 1
        case .section_4: return 1
        case .section_5: return 1
        }
    }
    
    var sectionTitle: String {
        switch self {
        case .section_1: return "Phone Number"
        case .section_2: return "Email"
        case .section_3: return "Password"
        case .section_4: return "App Version"
        case .section_5: return "COVID-19 Guidelines"
        }
    }
    var systemNameIcon: String {
        switch self {
        case .section_1: return "iphone"
        case .section_2: return "envelope"
        case .section_3: return "lock"
        case .section_4: return "apps.iphone"
        case .section_5: return "staroflife.fill"
            
        }
    }
    
    var iconDimension: (CGFloat, CGFloat) {
        switch self {
        case .section_1: return (24, 24)
        case .section_2: return (24, 24)
        case .section_3: return (24, 24)
        case .section_4: return (24, 24)
        case .section_5: return (26, 24)
        }
    }
}
