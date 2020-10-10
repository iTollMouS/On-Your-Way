//
//  PhoneLoginController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit
import Firebase

protocol PhoneLoginControllerDelegate: class {
    func handlePhoneControllerDismissal(_ view: PhoneLoginController)
}

class PhoneLoginController: UIViewController {
    
    
    weak var delegate: PhoneLoginControllerDelegate?
    
    // MARK: - Propertes
    private let blurView : UIVisualEffectView = {
        let blurView = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurView)
        return view
    }()
    
    private lazy var dismissView: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.down"), for: .normal)
        button.setDimensions(height: 50, width: 50)
        button.layer.cornerRadius = 50 / 2
        button.backgroundColor = UIColor.systemRed.withAlphaComponent(0.6)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "Enter your phone number",
                                                       attributes: [.foregroundColor : UIColor.white, .font: UIFont.boldSystemFont(ofSize: 26)])
        attributedText.append(NSMutableAttributedString(string: "\nWe will send you a code to verify your phone number",
                                                        attributes: [.foregroundColor : UIColor.white, .font: UIFont.systemFont(ofSize: 16)]))
        label.attributedText = attributedText
        label.setDimensions(height: 130, width: 300)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    
    private lazy var requestOPTButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Request OPT", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1), for: .normal)
        button.setHeight(height: 50)
        button.alpha = 0
        button.isEnabled = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 50 / 2
        button.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.4, radius: 10, offset: CGSize(width: 0, height: 2), color: .white)
        button.addTarget(self, action: #selector(handleRequestOPT), for: .touchUpInside)
        return button
    }()
    
    private lazy var verifyOPTButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Verify OPT", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1), for: .normal)
        button.setHeight(height: 50)
        button.alpha = 0
        button.isEnabled = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 50 / 2
        button.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.4, radius: 10, offset: CGSize(width: 0, height: 2), color: .white)
        button.addTarget(self, action: #selector(handleRequestOPT), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var phoneNumberTextField = CustomTextField(textColor: .white, placeholder: "05XXXXXXXX",
                                                            placeholderColor: .white, placeholderAlpa: 0.9, isSecure: false)
    
    private lazy var phoneNumberContainerView = CustomContainerView(image: UIImage(systemName: "phone"), textField: phoneNumberTextField,
                                                                    iconTintColor: .white, dividerViewColor: .clear, dividerAlpa: 0.0,
                                                                    setViewHeight: 50, iconAlpa: 1.0, backgroundColor: UIColor.white.withAlphaComponent(0.3))
    
    
    
    private lazy var oneTimeCodeTextField = PhoneOPTTextField()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureTextField()
        setDelegates()
        textFieldObservance()
        self.hideKeyboardWhenTouchOutsideTextField()
    }
    
    func setDelegates(){
        phoneNumberTextField.delegate = self
    }
    
    
    func configureTextField(){
        oneTimeCodeTextField.configure()
    }
    
    func configureUI(){
        // create blur view
        view.addSubview(blurView)
        blurView.frame = view.frame
        // create dismiss view on the top right
        view.addSubview(dismissView)
        dismissView.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 14, paddingRight: 20)
        // create info label on the top
        view.addSubview(infoLabel)
        infoLabel.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 30)
        infoLabel.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 20, paddingRight: 20)
        // create phone container view
        view.addSubview(phoneNumberContainerView)
        phoneNumberContainerView.centerX(inView: infoLabel, topAnchor: infoLabel.bottomAnchor, paddingTop: 0)
        phoneNumberContainerView.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 40 , paddingRight: 40)
        // create OPT verification
        view.addSubview(oneTimeCodeTextField)
        oneTimeCodeTextField.centerX(inView: phoneNumberContainerView, topAnchor: phoneNumberContainerView.bottomAnchor, paddingTop: 20)
        oneTimeCodeTextField.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 20, paddingRight: 20)
        // create request OPT Button
        view.addSubview(requestOPTButton)
        requestOPTButton.centerX(inView: oneTimeCodeTextField, topAnchor: oneTimeCodeTextField.bottomAnchor, paddingTop: 10)
        requestOPTButton.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 30, paddingRight: 30)
        
        view.addSubview(verifyOPTButton)
        verifyOPTButton.centerX(inView: oneTimeCodeTextField, topAnchor: oneTimeCodeTextField.bottomAnchor, paddingTop: 10)
        verifyOPTButton.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 30, paddingRight: 30)
        
    }
    
    // MARK: - Text Validation
    func textFieldObservance(){
        phoneNumberTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        phoneNumberTextField.keyboardType = .numberPad
        
    }
    
    @objc func textDidChange(_ textField: UITextField){
        
        guard let phoneText = phoneNumberTextField.text else { return }
        
        if phoneText.count == 10 {
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.requestOPTButton.alpha = 1
                self?.requestOPTButton.isEnabled = true
                
            }
        } else {
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.requestOPTButton.alpha = 0
                self?.requestOPTButton.isEnabled = false
                
            }
        }
        
    }
    
    // MARK: - Actions
    
    @objc private func handleDismissal(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleRequestOPT(){
        guard let phoneText = phoneNumberTextField.text else { return }
        self.requestOPTButton.alpha = 0
        self.requestOPTButton.isEnabled = false
        PhoneAuthProvider.provider().verifyPhoneNumber("+966\(phoneText)", uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                self.showAlertMessage("Error", error.localizedDescription)
                return
            }
            guard let verificationID = verificationID else {return}
            userDefaults.setValue(verificationID, forKey: "verificationID")
            userDefaults.synchronize()
        }
        
        oneTimeCodeTextField.didEnterLastDigit = { [weak self] verificationCode in
            self?.showBlurView()
            self?.showLoader(true, message: "Please whit while we verify ..")
            guard let verificationID = userDefaults.string(forKey: "verificationID") else { return }
            let credentials = PhoneAuthProvider.provider().credential(withVerificationID: verificationID,
                                                                      verificationCode: verificationCode)
            AuthServices.shared.registerUserWithPhoneNumber(withCredentials: credentials) { error in
                if let error = error {
                    self?.showBlurView()
                    self?.showLoader(false)
                    self?.showAlertMessage("Error", error.localizedDescription)
                    return
                }
                
                self?.removeBlurView()
                self?.showLoader(false)
                self?.showBanner(message: "Successfully verified your phone number", state: .success,
                                 location: .top, presentingDirection: .vertical, dismissingDirection: .vertical,
                                 sender: self!)
                
                Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] timer in
                    self?.showBlurView()
                    self?.showLoader(true, message: "Please wait while we \nprepare the environment...")
                }
                
                Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self]  (timer) in
                    self?.removeBlurView()
                    self?.showLoader(false)
                    self?.delegate?.handlePhoneControllerDismissal(self!)
                }
                
            }
        }
        
        
    }
    
}

extension PhoneLoginController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength: Int = textField.text!.count + string.count - range.length
        let numberOnly = NSCharacterSet.init(charactersIn: "0123456789").inverted
        let strValid = string.rangeOfCharacter(from: numberOnly) == nil
        return (strValid && (newLength <= 10))
    }
}
