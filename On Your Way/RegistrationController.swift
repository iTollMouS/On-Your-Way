//
//  RegistrationController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit
import CLTypingLabel

class RegistrationController: UIViewController {
    
    private let blurView : UIVisualEffectView = {
        let blurView = UIBlurEffect(style: .systemChromeMaterialDark)
        let view = UIVisualEffectView(effect: blurView)
        return view
    }()
    
    private lazy var dismissView: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.down"), for: .normal)
        button.setDimensions(height: 50, width: 50)
        button.layer.cornerRadius = 50 / 2
        button.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = CLTypingLabel()
        label.text = "Create\nAccount"
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 32)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var emailTextField = CustomTextField(textColor: #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), placeholder: "example@example.com",
                                                      placeholderColor: #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), placeholderAlpa: 0.9, isSecure: false)
    
    private lazy var emailContainerView = CustomContainerView(image: UIImage(systemName: "envelope"), textField: emailTextField,
                                                              iconTintColor: #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), dividerViewColor: .clear, dividerAlpa: 0.0,
                                                              setViewHeight: 50, iconAlpa: 1.0, backgroundColor: UIColor.white.withAlphaComponent(0.6))
    
    private lazy var passwordTextField = CustomTextField(textColor: #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), placeholder: "**********",
                                                         placeholderColor: #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), placeholderAlpa: 0.9, isSecure: true)
    private lazy var passwordContainerView = CustomContainerView(image: UIImage(systemName: "lock"), textField: passwordTextField,
                                                                 iconTintColor: #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), dividerViewColor: .clear, dividerAlpa: 0.0,
                                                                 setViewHeight: 50, iconAlpa: 1.0, backgroundColor: UIColor.white.withAlphaComponent(0.6))
    
    private lazy var fullnameTextField = CustomTextField(textColor: #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), placeholder: "full name",
                                                         placeholderColor: #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), placeholderAlpa: 0.9, isSecure: true)
    private lazy var fullnameContainerView = CustomContainerView(image: UIImage(systemName: "person"), textField: fullnameTextField,
                                                                 iconTintColor: #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), dividerViewColor: .clear, dividerAlpa: 0.0,
                                                                 setViewHeight: 50, iconAlpa: 1.0, backgroundColor: UIColor.white.withAlphaComponent(0.6))
    
    
    private lazy var registrationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1), for: .normal)
        button.setHeight(height: 50)
        button.alpha = 0
        button.isEnabled = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 50 / 2
        button.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        button.addTarget(self, action: #selector(handleRegistration), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailContainerView,
                                                       passwordContainerView,
                                                       fullnameContainerView,
                                                       registrationButton])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        self.hideKeyboardWhenTouchOutsideTextField()
    }
    
    func configureUI(){
        // create blur view
        view.addSubview(blurView)
        blurView.frame = view.frame
        
        view.addSubview(dismissView)
        dismissView.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 14, paddingRight: 20)
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor,
                          paddingTop: 20, paddingLeft: 40)
        
        view.addSubview(stackView)
        stackView.centerX(inView: view, topAnchor: titleLabel.bottomAnchor, paddingTop: 50)
        stackView.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 50, paddingRight: 50)
    }
    
    @objc private func handleRegistration(){
        print("DEBUG: register pressed")
    }
    
    @objc private func handleDismissal(){
        dismiss(animated: true, completion: nil)
    }
    
    
}
