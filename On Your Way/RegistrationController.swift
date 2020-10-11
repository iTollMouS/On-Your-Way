//
//  RegistrationController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit
import CLTypingLabel
import ProgressHUD
import Loaf


// MARK: - RegistrationControllerDelegate
protocol  RegistrationControllerDelegate: class {
    func handleRegistrationDismissal(_ view: RegistrationController)
}




class RegistrationController: UIViewController {
    
    weak var delegate: RegistrationControllerDelegate?

    // MARK: - Properties
    private var profileImage: UIImage?
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "photo-1561494270-744b7f2ff037")
        return imageView
    }()
    
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
        button.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1).withAlphaComponent(0.8)
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
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 50 / 2
        button.isEnabled = false
        button.alpha = 0
        button.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        button.layer.masksToBounds = false
        button.clipsToBounds = true
        button.setupShadow(opacity: 0.2, radius: 10, offset: CGSize(width: 0.0, height: 2.0), color: .white)
        button.addTarget(self, action: #selector(handleRegistration), for: .touchUpInside)
        return button
    }()
    
    private lazy var selectProfileImage: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        button.setDimensions(height: 100, width: 100)
        button.layer.cornerRadius = 100 / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handlePhotoSelected), for: .touchUpInside)
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
    
    private lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.setDimensions(height: 500, width: view.frame.width)
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel,
                                                       selectProfileImage])
        stackView.axis = .horizontal
        stackView.setDimensions(height: 100, width: view.frame.width)
        return stackView
    }()
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        self.hideKeyboardWhenTouchOutsideTextField()
        textFieldObservance()
        
    }
    
    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        bottomContainerView.setGradientBackground(colorTop: #colorLiteral(red: 0.2235294118, green: 0.2470588235, blue: 0.2470588235, alpha: 1), colorBottom: #colorLiteral(red: 0.3450980392, green: 0.3450980392, blue: 0.3450980392, alpha: 1))
    }
    
    func configureUI(){
        // create blur view
        view.addSubview(blurView)
        blurView.frame = view.frame
        
        view.addSubview(dismissView)
        dismissView.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 14, paddingRight: 20)
        
        view.addSubview(bottomContainerView)
        bottomContainerView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        view.addSubview(topStackView)
        topStackView.centerX(inView: view)
        topStackView.anchor(left: view.leftAnchor, bottom: bottomContainerView.topAnchor, right: view.rightAnchor,
                            paddingLeft: 40, paddingBottom: 40 , paddingRight: 40)
        
        bottomContainerView.addSubview(stackView)
        stackView.centerX(inView: bottomContainerView, topAnchor: bottomContainerView.topAnchor, paddingTop: 30)
        stackView.anchor(left: bottomContainerView.leftAnchor, right: bottomContainerView.rightAnchor,
                         paddingLeft: 40, paddingRight: 40)
    }
    
    
    // MARK: - textFieldObservance
    func textFieldObservance(){
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullnameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func textDidChange(){
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        
        if !email.isEmpty && !password.isEmpty && !fullname.isEmpty {
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.registrationButton.alpha = 1
                self?.registrationButton.isEnabled = true
            }
        } else {
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.registrationButton.alpha = 0
                self?.registrationButton.isEnabled = false
            }
        }
        
    }
    
    
    // MARK: - handleRegistration
    @objc private func handleRegistration(){
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        guard let profileImageView = profileImage else { return }
        let imageID = UUID().uuidString
        let fileDirectory = "Avatars/" + "_\(imageID)" + ".jpg"
        
        FileStorage.saveFileLocally(fileData: profileImageView.jpegData(compressionQuality: 0.5)! as NSData,
                                    fileName: fileDirectory)
        
        FileStorage.uploadImage(profileImageView, directory: fileDirectory) { imageUrl in
            guard let imageUrl =  imageUrl else {return}
            let credential = userCredential(email: email, password: password, fullName: fullname, profileImageUrl: imageUrl)
            AuthServices.shared.registerUserWith(credential: credential) {  [weak self] error in
                if let error = error {
                    self?.showBlurView()
                    self?.showLoader(false)
                    self?.showAlertMessage("Error", error.localizedDescription)
                    return
                }
                
                self?.removeBlurView()
                self?.showLoader(false)
                self?.showBanner(message: "Successfully create an account", state: .success,
                                 location: .top, presentingDirection: .vertical, dismissingDirection: .vertical,
                                 sender: self!)
                
                Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] timer in
                    self?.showBlurView()
                    self?.showLoader(true, message: "Please wait while we \nprepare the environment...")
                }
                
                Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self]  (timer) in
                    self?.removeBlurView()
                    self?.showLoader(false)
                    self?.delegate?.handleRegistrationDismissal(self!)
                }
            }
        }
    }
    
    
    // MARK: - handleDismissal
    @objc private func handleDismissal(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handlePhotoSelected(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
}

// MARK: - extension




// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension RegistrationController : UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as? UIImage
        profileImage = image
        selectProfileImage.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        selectProfileImage.layer.cornerRadius = 50
        selectProfileImage.layer.borderColor = UIColor.white.cgColor
        selectProfileImage.layer.borderWidth = 1.0
        selectProfileImage.imageView?.contentMode = .scaleAspectFill
        picker.dismiss(animated: true, completion: nil)
    }
}

