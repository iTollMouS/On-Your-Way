//
//  ProfileCell.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/30/20.
//

import UIKit

protocol ProfileCellDelegate: class {
    func showGuidelines(_ cell: ProfileCell)
    func updateUserInfo(_ cell: ProfileCell, value: String, viewModel: ProfileViewModel)
}

class ProfileCell: UITableViewCell {
    
    var viewModel: ProfileViewModel?{
        didSet{configureUI()}
    }
    
    
    weak var delegate: ProfileCellDelegate?
    
    lazy var phoneNumberTextField: UITextField = {
        let label = UITextField()
        label.textAlignment = .right
        label.textColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
        label.delegate = self
        label.attributedPlaceholder = NSAttributedString(string: "الرجاء تحديث رقم الجوال",
                                                         attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    lazy var emailTextField: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var appVersionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.text = Bundle.mainAppVersion
        label.textColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var covid_19_GuidelinesLabel: UILabel = {
        let label = UILabel()
        label.text = "ارشادات كورونا COVID-19 "
        label.textAlignment = .right
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
            phoneNumberTextField.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 50))
            phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            phoneNumberTextField.isHidden = false
            emailTextField.isHidden = true
            appVersionLabel.isHidden = true
            covid_19_GuidelinesLabel.isHidden = true
            configureAccessory()
            accessoryButton.isHidden = false
        case .section_2:
            addSubview(emailTextField)
            emailTextField.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 50))
            emailTextField.isHidden = false
            phoneNumberTextField.isHidden = true
            appVersionLabel.isHidden = true
            covid_19_GuidelinesLabel.isHidden = true
            accessoryButton.isHidden = false
            configureAccessory()
        case .section_3:
            addSubview(appVersionLabel)
            appVersionLabel.isHidden = false
            phoneNumberTextField.isHidden = true
            emailTextField.isHidden = true
            covid_19_GuidelinesLabel.isHidden = true
            appVersionLabel.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        case .section_4:
            addSubview(covid_19_GuidelinesLabel)
            covid_19_GuidelinesLabel.isHidden = false
            covid_19_GuidelinesLabel.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowGuidelines)))
            accessoryButton.isHidden = true
            phoneNumberTextField.isHidden = true
            emailTextField.isHidden = true
            appVersionLabel.isHidden = true
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
    case section_3
    case section_4
    
    var numberOfCells: Int {
        switch self {
        case .section_1: return 1
        case .section_2: return 1
        case .section_3: return 1
        case .section_4: return 1
        }
    }
    
    var sectionTitle: String {
        switch self {
        case .section_1: return "رقم الجوال"
        case .section_2: return "البريد الالكتروني"
        case .section_3: return "الاصدار"
        case .section_4: return "ارشادات كورونا"
        }
    }
    var systemNameIcon: String {
        switch self {
        case .section_1: return "iphone"
        case .section_2: return "envelope"
        case .section_3: return "apps.iphone"
        case .section_4: return "staroflife.fill"
        }
    }
    
    var iconDimension: (CGFloat, CGFloat) {
        switch self {
        case .section_1: return (24, 24)
        case .section_2: return (24, 24)
        case .section_3: return (28, 24)
        case .section_4: return (30, 24)
        }
    }
}
