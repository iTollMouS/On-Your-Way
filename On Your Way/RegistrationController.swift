//
//  RegistrationController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit

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
        button.backgroundColor = UIColor.systemRed.withAlphaComponent(0.4)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    private lazy var emailTextField = CustomTextField(textColor: .white, placeholder: "example@example.com",
                                                      placeholderColor: .white, placeholderAlpa: 0.9, isSecure: false)
    
    private lazy var emailContainerView = CustomContainerView(image: UIImage(systemName: "envelope"), textField: emailTextField,
                                                              iconTintColor: .white, dividerViewColor: .clear, dividerAlpa: 0.0,
                                                              setViewHeight: 50, iconAlpa: 1.0, backgroundColor: UIColor.white.withAlphaComponent(0.6))
    
    private lazy var passwordTextField = CustomTextField(textColor: .black, placeholder: "**********",
                                                         placeholderColor: #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), placeholderAlpa: 0.9, isSecure: true)
    private lazy var passwordContainerView = CustomContainerView(image: UIImage(systemName: "lock"), textField: passwordTextField,
                                                                 iconTintColor: #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), dividerViewColor: .clear, dividerAlpa: 0.0,
                                                                 setViewHeight: 50, iconAlpa: 1.0, backgroundColor: UIColor.white.withAlphaComponent(0.6))
    
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailContainerView,
                                                       passwordContainerView])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI(){
        // create blur view
        view.addSubview(blurView)
        blurView.frame = view.frame
        view.addSubview(dismissView)
        dismissView.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 14, paddingRight: 20)
    }
    
    @objc private func handleDismissal(){
        dismiss(animated: true, completion: nil)
    }
    
    
}
