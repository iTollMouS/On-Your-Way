//
//  SendPackageController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/13/20.
//

import UIKit


private let reuseIdentifier = "SendPackageCell"

class SendPackageController: UIViewController {
    
    private let user: User
    private let trip: Trip
    private var imageIndex = 0
    private let imagePicker = UIImagePickerController()
    private lazy var packagesImage = SendPackageImagesStackView()
    private var packageImageUrls = [String]()
    
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        button.setTitle("Send package with  ", for: .normal)
        button.setImage(UIImage(systemName: "shippingbox.fill"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSubmittingShipment), for: .touchUpInside)
        button.setDimensions(height: 50, width: 200)
        button.layer.cornerRadius = 50 / 2
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.5, radius: 16, offset: CGSize(width: 0.0, height: 8.0), color: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1))
        return button
    }()
    
    
    
    init(user: User, trip: Trip) {
        self.user = user
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI(){
        view.addSubview(packagesImage)
        packagesImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20 ,
                             paddingLeft: 20, paddingRight: 20)
        view.addSubview(logoutButton)
        logoutButton.centerX(inView: packagesImage, topAnchor: packagesImage.bottomAnchor, paddingTop: 30)
        packagesImage.delegate = self
        title = user.username
        view.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    fileprivate func uploadPackageImage(_ image: UIImage){
        let fileDirectory = "Packages/" + "_\(User.currentId)" + ".jpg"
        FileStorage.uploadImage(image, directory: fileDirectory) { [weak self] imageUrl in
            print("DEBUG: image url is \(imageUrl)")
            guard let imageUrl = imageUrl else {return}
            self?.packageImageUrls.append(imageUrl)
        }
    }
    
    @objc fileprivate func handleSubmittingShipment(){
        print("DEBUG: current user is \(User.currentId)")
        print("DEBUG: current traveler is \(trip.userID)")
        let packageId = UUID().uuidString
        let package = Package(userID: User.currentId,
                              tripID: trip.tripID,
                              packageType: "", timestamp: Date(),
                              packageImages: packageImageUrls.suffix(6),
                              packageID: packageId)
        TripService.shared.sendPackageToTraveler(trip: trip, userId: User.currentId,
                                                 package: package) { error in
            if let error = error {
                print("DEBUG: error in send package ")
                return
            }
            self.showAlertMessage("SUCCRSS!!", "Great!")
        }
    }
    
    
}




extension SendPackageController : SendPackageImagesStackViewDelegate {
    
    
    func imagesStackView(_ view: SendPackageImagesStackView, index: Int) {

        if !isConnectedToNetwork() {
            showBanner(message: "Please check your internet connection!", state: .error, location: .top,
                       presentingDirection: .vertical, dismissingDirection: .vertical, sender: self)
            return
        }
        
        self.imageIndex = index
        let alert = UIAlertController(title: nil, message: "اختر مصدر الصور", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "الكامرا", style: .default, handler: { (alertAction) in
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraCaptureMode = .photo
            self.imagePicker.showsCameraControls = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "البوم الصور", style: .default, handler: { (alertAction) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "الغاء", style: .cancel, handler: nil))
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

