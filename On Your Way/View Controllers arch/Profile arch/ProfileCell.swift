//
//  ProfileCell.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/30/20.
//

import UIKit

protocol ProfileCellDelegate: class {
    func showGuidelines(_ cell: ProfileCell)
    func showAdminControl(_ cell: ProfileCell)
    func updateUserInfo(_ cell: ProfileCell, value: String, viewModel: ProfileViewModel)
}

class ProfileCell: UITableViewCell {
    
    var viewModel: ProfileViewModel?{
        didSet{configureUI()}
    }
    
    
    weak var delegate: ProfileCellDelegate?
    
    lazy var phoneNumberTextField: UITextField = {
        let label = UITextField()
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
        label.delegate = self
        label.placeholder = "Update your phone number here"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    lazy var emailTextField: UILabel = {
        let label = UILabel()
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
    
    private lazy var adminControl: UILabel = {
        let label = UILabel()
        label.text = "Access to admin "
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var accessoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil.and.outline"), for: .normal)
        button.setDimensions(height: 30, width: 30)
        button.tintColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1).withAlphaComponent(0.7)
        button.backgroundColor = .clear
        return button
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        
    }
    
    func configure(user: User){
        phoneNumberTextField.text = user.phoneNumber
        emailTextField.text = user.email
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
            addSubview(phoneNumberTextField)
            phoneNumberTextField.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 30))
            phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            configureAccessory()
        case .section_2:
            addSubview(emailTextField)
            emailTextField.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            configureAccessory()
        case .section_4:
            addSubview(appVersionLabel)
            appVersionLabel.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        case .section_5:
            addSubview(covid_19_GuidelinesLabel)
            covid_19_GuidelinesLabel.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowGuidelines)))
            accessoryButton.addTarget(self, action: #selector(handleShowGuidelines), for: .touchUpInside)
        case .section_6:
            addSubview(adminControl)
            adminControl.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowAdminControl)))
            accessoryButton.addTarget(self, action: #selector(handleShowGuidelines), for: .touchUpInside)
        }
    }
    
    
    @objc private func textFieldDidChange(_ textField: UITextField){
        guard let viewModel = viewModel else {return}
        guard let value = textField.text else { return }
        delegate?.updateUserInfo(self, value: value, viewModel: viewModel)
    }
    
    @objc func handleShowGuidelines(){
        delegate?.showGuidelines(self)
    }
    
    @objc func handleShowAdminControl(){
        delegate?.showAdminControl(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ProfileCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case phoneNumberTextField:
            let newLength: Int = textField.text!.count + string.count - range.length
            let numberOnly = NSCharacterSet.init(charactersIn: "0123456789").inverted
            let strValid = string.rangeOfCharacter(from: numberOnly) == nil
            return (strValid && (newLength <= 16))
        default:
            break
        }
        return false
    }
}


enum ProfileViewModel: Int, CaseIterable {
    case section_1
    case section_2
    case section_4
    case section_5
    case section_6
    
    var numberOfCells: Int {
        switch self {
        case .section_1: return 1
        case .section_2: return 1
        case .section_4: return 1
        case .section_5: return 1
        case .section_6: return 1
        }
    }
    
    var sectionTitle: String {
        switch self {
        case .section_1: return "Phone Number"
        case .section_2: return "Email"
        case .section_4: return "App Version"
        case .section_5: return "COVID-19 Guidelines"
        case .section_6: return "Admin Control"
        }
    }
    var systemNameIcon: String {
        switch self {
        case .section_1: return "iphone"
        case .section_2: return "envelope"
        case .section_4: return "apps.iphone"
        case .section_5: return "staroflife.fill"
        case .section_6: return "lock.shield.fill"
        }
    }
    
    var iconDimension: (CGFloat, CGFloat) {
        switch self {
        case .section_1: return (24, 24)
        case .section_2: return (24, 24)
        case .section_4: return (28, 24)
        case .section_5: return (30, 24)
        case .section_6: return (24, 24)
        }
    }
}
