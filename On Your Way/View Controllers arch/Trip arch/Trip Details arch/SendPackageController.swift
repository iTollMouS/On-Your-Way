//
//  SendPackageController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/13/20.
//

import UIKit
import Firebase
import SwiftEntryKit

private let reuseIdentifier = "SendPackageCell"


// MARK: - Protocol
protocol SendPackageControllerDelegate: class {
    func handleDismissalView(_ view: SendPackageController)
}

class SendPackageController: UIViewController {
    
    // MARK: - delegate
    weak var delegate: SendPackageControllerDelegate?
    
    
    // MARK: - Properties
    
    private let packageTitleLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "اكتب اي وصف اضافي للشحنه ، مثلا : الكرتون داخله بعض الاوراق او اجهزه كهرب\n",
                                                       attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        attributedText.append(NSMutableAttributedString(string: "لديك فقط 150 حرف لكتابة الوصف",
                                                        attributes: [NSAttributedString.Key.foregroundColor : UIColor.white]))
        label.attributedText = attributedText
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.setDimensions(height: 60, width: 200)
        return label
    }()
    
    
    private lazy var sendPackageButton: UIButton = {
        let button = UIButton(type: .system)
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        button.setTitle("ارسال الشحنة  ", for: .normal)
        button.setImage(UIImage(systemName: "shippingbox.fill"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSubmittingShipment), for: .touchUpInside)
        button.setDimensions(height: 50, width: 360)
        button.layer.cornerRadius = 50 / 2
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.5, radius: 16, offset: CGSize(width: 0.0, height: 8.0), color: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1))
        return button
    }()
    
    
    private lazy var packageInfoTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.textColor = .blueLightFont
        textView.setHeight(height: 100)
        textView.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        textView.layer.cornerRadius = 10
        textView.keyboardAppearance = .dark
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = self
        textView.clipsToBounds = true
        return textView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "اكتب وصف بسيط عن الشحنه المرسلة"
        label.textAlignment = .right
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    
    
    // MARK: - initializers
    private let user: User
    private let trip: Trip
    private var imageIndex = 0
    private let imagePicker = UIImagePickerController()
    private lazy var packagesImage = SendPackageImagesStackView()
    private var packageImageUrls = [String]()
    private var limitedLetter = 150
    
    init(user: User, trip: Trip) {
        self.user = user
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
    }
    
    var darkMode = false
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return darkMode ? .lightContent : .lightContent
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureNavBar()
    }
    
    
    // MARK: - configureNavBar()
    func configureNavBar(){
        
        configureNavigationBar(withTitle: user.username, largeTitleColor: .white, tintColor: .white,
                               navBarColor: #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1), smallTitleColorWhenScrolling: .light,
                               prefersLargeTitles: true)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "تراجع", style: .done, target: self, action: #selector(handleDismissal))
        self.navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    // MARK: - configureUI()
    func configureUI(){
        
        
        view.addSubview(packagesImage)
        packagesImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20 ,
                             paddingLeft: 20, paddingRight: 20)
        
        packagesImage.delegate = self
        title = user.username
        view.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        view.addSubview(packageTitleLabel)
        packageTitleLabel.centerX(inView: packagesImage, topAnchor: packagesImage.bottomAnchor, paddingTop: 20)
        packageTitleLabel.anchor(left: view.leftAnchor, right: view.rightAnchor)
        
        view.addSubview(packageInfoTextView)
        packageInfoTextView.anchor(top: packageTitleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20 ,
                                   paddingLeft: 30, paddingRight: 30)
        
        view.addSubview(sendPackageButton)
        sendPackageButton.centerX(inView: packageInfoTextView, topAnchor: packageInfoTextView.bottomAnchor, paddingTop: 30)
        
        packageInfoTextView.addSubview(placeholderLabel)
        placeholderLabel.anchor(top: packageInfoTextView.topAnchor, left: packageInfoTextView.leftAnchor,
                                paddingTop: 8, paddingLeft: 8)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChanger), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    
    
    // MARK: - Actions
    @objc func handleDismissal(){
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func handleTextInputChanger(){
        
        placeholderLabel.isHidden = !packageInfoTextView.text.isEmpty
        let attributedText = NSMutableAttributedString(string: "اكتب اي وصف اضافي للشحنه ، مثلا : الكرتون داخله بعض الاوراق او اجهزه كهرب\n",
                                                       attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        attributedText.append(NSMutableAttributedString(string: "لديك فقط \(limitedLetter - packageInfoTextView.text.count) حرف لكتابة الوصف",
                                                        attributes: [NSAttributedString.Key.foregroundColor : UIColor.white]))
        packageTitleLabel.attributedText = attributedText
    }
    
    // MARK: - Upload Package image
    fileprivate func uploadPackageImage(_ image: UIImage){
        let fileId = UUID().uuidString
        let fileDirectory = "Packages/" + "_\(fileId)/" + "\(User.currentId)" + ".jpg"
        FileStorage.uploadImage(image, directory: fileDirectory) { [weak self] imageUrl in
            guard let imageUrl = imageUrl else {return}
            self?.packageImageUrls.append(imageUrl)
        }
    }
    
    @objc fileprivate func handleSubmittingShipment(){
        
        if packageImageUrls.isEmpty {
            self.showAlertMessage("لاتوجد صورة", "الرجاء ارفاق صورة واحدة على الاقل")
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        UserServices.shared.fetchUser(userId: uid) { [weak self] user in
            PushNotificationService.shared.sendPushNotification(userIds: [self!.trip.userID],
                                                                body: "لديك طلب شحنه جديد من \(user.username) 🤩 📦",
                                                                title: "طلب ارسال شحنه")
        }
        
        view.isUserInteractionEnabled = false
        self.showBlurView()
        self.showLoader(true, message: "الرجاء الانتظار بينما نرسل طلبك ...")
        guard let packageType = packageInfoTextView.text else { return }
        let packageId = UUID().uuidString
        let package = Package(userID: User.currentId,
                              tripID: trip.tripID,
                              packageType: packageType,
                              timestamp: Date(),
                              packageImages: packageImageUrls.suffix(6),
                              packageID: packageId,
                              packageStatus: .packageIsPending,
                              packageStatusTimestamp: "")
        TripService.shared.sendPackageToTraveler(trip: trip, userId: User.currentId,
                                                 package: package) { [weak self] error in
            if let error = error {
                self?.removeBlurView()
                self?.showLoader(false)
                self?.showAlertMessage("Error", error.localizedDescription)
                return
            }
            
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] timer in
                self?.removeBlurView()
                self?.showLoader(false)
                self?.showBanner(message: "Success!", state: .success, location: .top,
                                 presentingDirection: .vertical, dismissingDirection: .vertical,
                                 sender: self!)
            }
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] timer in
                self?.delegate?.handleDismissalView(self!)
            }
        }
    }
    
    
}

// MARK: - TextView delegate
extension SendPackageController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 150
    }
}



// MARK: - Top stack images delegate
extension SendPackageController : SendPackageImagesStackViewDelegate {
    func imagesStackView(_ view: SendPackageImagesStackView, index: Int) {
        
        if !isConnectedToNetwork() {
            showBanner(message: "Please check your internet connection!", state: .error, location: .top,
                       presentingDirection: .vertical, dismissingDirection: .vertical, sender: self)
            return
        }
        
        self.imageIndex = index
        let alert = UIAlertController(title: nil, message: "Choose photo source", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alertAction) in
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraCaptureMode = .photo
            self.imagePicker.showsCameraControls = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Album", style: .default, handler: { (alertAction) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension SendPackageController : UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        uploadPackageImage(image)
        packagesImage.buttons[imageIndex].setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        packagesImage.buttons[imageIndex].imageView?.layer.cornerRadius = 50
        packagesImage.buttons[imageIndex].imageView?.setDimensions(height: 100, width: 100)
        packagesImage.buttons[imageIndex].imageView?.clipsToBounds = true
        packagesImage.buttons[imageIndex].imageView?.contentMode =  .scaleAspectFill
        packagesImage.buttons[imageIndex].imageView?.layer.borderWidth = 2
        picker.dismiss(animated: true, completion: nil)
    }
}
