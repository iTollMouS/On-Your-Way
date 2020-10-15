//
//  UpdateEmailController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/12/20.
//

import UIKit
import Lottie
import Firebase

protocol UpdateEmailControllerDelegate: class {
    func handleLoggingUserOut()
}

class UpdateEmailController: UIViewController {
    
    weak var delegate: UpdateEmailControllerDelegate?
    
    private lazy var animationView : AnimationView = {
        let animationView = AnimationView()
        animationView.setDimensions(height: 150, width: 150)
        animationView.clipsToBounds = true
        animationView.backgroundColor = .clear
        animationView.animation = Animation.named("emailConfirmation")
        return animationView
    }()
    
    
    
    private lazy var emailTextField = CustomTextField(textColor: .black, placeholder: "example@example.com",
                                                      placeholderColor: #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), placeholderAlpa: 0.9, isSecure: false)
    
    private lazy var emailContainerView = CustomContainerView(image: UIImage(systemName: "envelope"), textField: emailTextField,
                                                              iconTintColor: #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), dividerViewColor: .clear, dividerAlpa: 0.0,
                                                              setViewHeight: 50, iconAlpa: 1.0, backgroundColor: UIColor.white.withAlphaComponent(0.6))
    
    private lazy var passwordTextField = CustomTextField(textColor: .black, placeholder: "**********",
                                                         placeholderColor: #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), placeholderAlpa: 0.9, isSecure: true)
    private lazy var passwordContainerView = CustomContainerView(image: UIImage(systemName: "lock"), textField: passwordTextField,
                                                                 iconTintColor: #colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), dividerViewColor: .clear, dividerAlpa: 0.0,
                                                                 setViewHeight: 50, iconAlpa: 1.0, backgroundColor: UIColor.white.withAlphaComponent(0.6))
    
    private lazy var loggingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1), for: .normal)
        button.setHeight(height: 50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 50 / 2
        button.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        button.addTarget(self, action: #selector(handleUpdateInfo), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailContainerView,
                                                       passwordContainerView,
                                                       loggingButton])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    
    private var user: User
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG: user name is \(user)")
        configureUI()
    }
    
    
    var darkMode = false
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return darkMode ? .lightContent : .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = true
        tabBarController?.dismissPopupBar(animated: true, completion: nil)
    }
    
    func configureUI(){
        view.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        view.addSubview(animationView)
        animationView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        view.addSubview(stackView)
        stackView.centerX(inView: view, topAnchor: animationView.bottomAnchor, paddingTop: 20)
        stackView.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 40, paddingRight: 40)
        animationView.play()
        animationView.loopMode = .loop
    }
    
    @objc private func handleUpdateInfo(){
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        self.showBlurView()
        self.showLoader(true, message: "Please wait...")
        AuthServices.shared.updateEmailAndPassword(email: email, password: password) { [weak self] error in
            if let error = error {
                self?.removeBlurView()
                self?.showLoader(false)
                self?.showAlertMessage("Error", error.localizedDescription)
                return
            }
            
            self?.removeBlurView()
            self?.showLoader(false)
            self?.showBanner(message: "Successfully verified your info", state: .success,
                             location: .top, presentingDirection: .vertical, dismissingDirection: .vertical,
                             sender: self!)
            
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] timer in
                self?.showBlurView()
                self?.showLoader(true, message: "Please wait while we \nprepare the environment...")
            }
            
            Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self]  (timer) in
                self?.removeBlurView()
                self?.showLoader(false)
                self?.delegate?.handleLoggingUserOut()
            }
            
        }
        
        
    }
    
    
}
