//
//  LoginController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import Firebase


class LoginController: UIViewController {
    
    
    // MARK: - Properties
    
    private var currentNonce: String?
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "photo-1561494270-744b7f2ff037")
        return imageView
    }()
    
    private lazy var loggingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1), for: .normal)
        button.setHeight(height: 50)
        button.alpha = 0
        button.isEnabled = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 50 / 2
        button.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var orLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.text = "OR\nlog in with other services "
        label.numberOfLines = 0
        return label
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
    
    
    // MARK: - Logging Buttons
    private let googleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "btn_google_light_pressed_ios").withRenderingMode(.alwaysOriginal) , for: .normal)
        button.imageView?.clipsToBounds = true
        button.setTitle("  Sign With Google Account", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.3137254902, blue: 0.3529411765, alpha: 1), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setHeight(height: 50)
        button.layer.cornerRadius = 50 / 2
        button.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var signWithAppleID: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .default, style: .black)
        button.addTarget(self, action: #selector(handleSignInWithAppleID), for: .touchUpInside)
        button.setHeight(height: 50)
        button.layer.cornerRadius = 50 / 2
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var phoneNumberLogging: UIButton = {
        let button = UIButton (type: .system)
        button.setImage(UIImage(systemName: "phone"), for: .normal)
        button.tintColor = .white
        button.setTitle("  Sign in with your phone number  ", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setHeight(height: 50)
        button.layer.cornerRadius = 50 / 2
        button.backgroundColor = #colorLiteral(red: 0.7176470588, green: 0.4862745098, blue: 0.2941176471, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLoggingWithPhoneNumber), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailContainerView,
                                                       passwordContainerView,
                                                       loggingButton,
                                                       orLabel,
                                                       signWithAppleID,
                                                       googleLoginButton,
                                                       phoneNumberLogging])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton (type: .system)
        let attributedText = NSMutableAttributedString(string: "Don't have an account? ",
                                                       attributes: [.foregroundColor : UIColor.white,
                                                                    .font : UIFont.systemFont(ofSize: 18)])
        attributedText.append(NSMutableAttributedString(string: "Create new",
                                                        attributes: [.foregroundColor : UIColor.white,
                                                                     .font : UIFont.boldSystemFont(ofSize: 20)]))
        button.setAttributedTitle(attributedText, for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureGoogleSignIn()
        textFieldObservance()
        self.hideKeyboardWhenTouchOutsideTextField()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
    }
    
    
    // MARK: - configureUI
    func configureUI(){
        view.addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        view.addSubview(stackView)
        stackView.centerInSuperview()
        stackView.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 20, paddingRight: 20)
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,
                                     paddingBottom: 10)
        configureNavigationBar(withTitle: "", largeTitleColor: .white, tintColor: .white,
                               navBarColor: .white, smallTitleColorWhenScrolling: .dark, prefersLargeTitles: false)
    }
    
    
    // MARK: - Text Validation
    func textFieldObservance(){
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func textDidChange(_ textField: UITextField){
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        if !email.isEmpty && !password.isEmpty {
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.loggingButton.alpha = 1
                self?.loggingButton.isEnabled = true
            }
        } else {
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.loggingButton.alpha = 0
                self?.loggingButton.isEnabled = false
            }
        }
        
    }
    
    
    // MARK: - Actions
    @objc func handleLogin(){
        print("DEBUG: button is pressed")
    }
    
    @objc func handleLoggingWithPhoneNumber(){
        let phoneLoginController = PhoneLoginController()
        phoneLoginController.modalPresentationStyle = .custom
        phoneLoginController.delegate = self
        present(phoneLoginController, animated: true, completion: nil)
    }
    
    
}

extension LoginController: PhoneLoginControllerDelegate {
    func handlePhoneControllerDismissal(_ view: PhoneLoginController) {
        view.dismiss(animated: true) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    
}

// MARK: - Google Extenion
extension LoginController: GIDSignInDelegate {
    
    private func configureGoogleSignIn(){
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    @objc func handleGoogleSignIn() {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let user = user else { return }
        self.showBlurView()
        self.showLoader(true, message: "Please wait while we create account for you...")
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
            self.removeBlurView()
            self.showLoader(false)
            self.showBanner(message: "Successfully created account with Google account", state: .success,
                            location: .top, presentingDirection: .vertical, dismissingDirection: .vertical,
                            sender: self)
        }

        AuthServices.shared.registerUserWithGoogle(didSignInfo: user) { error in
            if let error = error {
                self.showAlertMessage( nil ,error.localizedDescription)
                return
            }
            print("DEBUG: user id \(user.userID)")
            
            self.removeBlurView()
            self.showLoader(false)
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
}

extension LoginController {
    
    @objc func handleSignInWithAppleID(){
        performSignIn()
    }
    
    func performSignIn(){
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        return request
    }
    
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}


extension LoginController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {return}
        guard let nonce = currentNonce else {
            fatalError("Invalid state: a login callback was received, but no login request was sent!")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable tp fetch identity token ")
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        
        guard let fullname = appleIDCredential.fullName?.familyName else { return }
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        self.showAlertMessage("Error with Apple ID", error.localizedDescription)
    }
    
}

extension LoginController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = UIApplication.shared.windows.first else { return UIWindow()}
        return window
    }
}
