//
//  ProfileController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit
import Firebase
import Gallery
import ProgressHUD
import LNPopupController

private let reuseIdentifier = "ProfileCell"

class ProfileController: UIViewController {
    
    // MARK: - Properties
    private lazy var headerView = ProfileHeader(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
    private lazy var footerView = ProfileFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
    private let gallery = GalleryController ()
    let cellSelectionStyle = UIView()
    
    private var user: User?
    
    let refreshController = UIRefreshControl()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style:.insetGrouped)
        tableView.rowHeight = 50
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        tableView.tableHeaderView = headerView
        tableView.register(ProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = footerView
        tableView.refreshControl = refreshController
        return tableView
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUser()
        configureUI()
        configureRefreshController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        checkUser()
        tabBarController?.tabBar.isHidden = false
        let peopleReviewsController = PeopleReviewsController()
        peopleReviewsController.user = user
        peopleReviewsController.popupItem.title = "People Reviews "
        peopleReviewsController.popupItem.subtitle = "Tab here to see who wrote a review about you"
        peopleReviewsController.popupItem.progress = 0.34
        tabBarController?.modalPresentationStyle = .custom
        tabBarController?.popupBar.titleTextAttributes = [ .foregroundColor: UIColor.white ]
        tabBarController?.popupBar.subtitleTextAttributes = [ .foregroundColor: UIColor.gray ]
        tabBarController?.presentPopupBar(withContentViewController: peopleReviewsController, animated: true, completion: nil)
        headerView.profileImageView.clipsToBounds = true
        
    }
    
    func configureRefreshController(){
        refreshController.tintColor = .white
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:
                                                                [.foregroundColor: UIColor.white])
    }
    
    
    // MARK: - checkUser
    func checkUser(){
        if User.currentUser == nil {
            presentLoggingController()
        } else {
            UserServices.shared.fetchUser(userId: User.currentId) { user in
                self.user = user
                print("DEBUG: user is \(user)")
                self.title = user.username
                self.tableView.reloadData()
                self.headerView.user = user
                self.headerView.profileImageView.clipsToBounds = true
            }
        }
    }
    
    // MARK: - configureUI
    func configureUI(){
        view.addSubview(tableView)
        tableView.fillSuperview()
        gallery.delegate = self
        headerView.delegate = self
        footerView.delegate = self
        headerView.profileImageView.clipsToBounds = true
    }
    
    // MARK: - configureNavBar
    func configureNavBarButtons(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleUserUpdates))
        headerView.profileImageView.clipsToBounds = true
    }
    
    @objc func handleUserUpdates(){
        guard let user = user else { return }
        guard let phoneNumber = user.phoneNumber else { return }
        
        if !phoneNumber.isValidPhoneNumber {
            self.showAlertMessage("Error", "Please enter your phone number correctly")
            return
        }
    
        self.showBlurView()
        self.showLoader(true, message: "Please wait while we\nupdate your info...")
        UserServices.shared.saveUserToFirestore(user)
        saveUserLocally(user)
        self.removeBlurView()
        self.showLoader(false)
        self.showBanner(message: "You have successfully updated your info", state: .success,
                        location: .top, presentingDirection: .vertical, dismissingDirection: .vertical,
                        sender: self)
        self.navigationItem.rightBarButtonItem?.title = ""
        headerView.profileImageView.clipsToBounds = true
        
    }
    
    // MARK: -  Update ProfileImage to firebase and save it locally
    func updateUserImage(_ image: UIImage){
        // create a name directory for user image
        let fileDirectory = "Avatars/" + "_\(User.currentId)" + ".jpg"
        // we upload the image to firebase storage and download the associated link
        FileStorage.uploadImage(image, directory: fileDirectory) { [ weak self] imageUrl in
            guard let imageUrl = imageUrl else {return}
            if var user = User.currentUser {
                // we assign the profile url to user so that we save it to firebase
                user.avatarLink = imageUrl
                saveUserLocally(user)
                UserServices.shared.saveUserToFirestore(user)
                self?.user = user
            }
            self?.headerView.profileImageView.image = image
            self?.headerView.profileImageView.clipsToBounds = true
            guard let image = image.jpegData(compressionQuality: 0.5) else {return}
            FileStorage.saveFileLocally(fileData: image as NSData, fileName: User.currentId)
            self?.tableView.reloadData()
            self?.headerView.profileImageView.clipsToBounds = true
        }
        
    }
    
    // MARK: - logout
    func logout(){
        AuthServices.shared.logOutUser { [weak self] error in
            if let error = error {
                ProgressHUD.showError("\(error.localizedDescription)")
                return
            }
            self?.presentLoggingController()
        }
    }
    
    
    // MARK: - presentLoggingController
    func presentLoggingController(){
        tabBarController?.selectedIndex = 0
        DispatchQueue.main.async { [ weak self] in
            let loginController = LoginController()
            loginController.delegate = self
            let nav = UINavigationController(rootViewController: loginController)
            nav.modalPresentationStyle = .fullScreen
            self?.present(nav, animated: true, completion: nil)
        }
    }
    
}


// MARK: - extension



extension ProfileController: UpdateEmailControllerDelegate {
    func handleLoggingUserOut() {
        navigationController?.popViewController(animated: true)
        checkUser()
    }
    
    
}



// MARK: - LoginControllerDelegate
extension ProfileController: LoginControllerDelegate {
    func handleLoggingControllerDismissal(_ view: LoginController) {
        view.dismiss(animated: true) { [weak self] in self?.checkUser() }
    }
}



// MARK: - UITableViewDelegate, UITableViewDataSource
extension ProfileController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileViewModel.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileViewModel.allCases[section].numberOfCells
    }
    
    
    // MARK: - cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ProfileCell
        guard let viewModel = ProfileViewModel(rawValue: indexPath.section) else { return cell }
        guard let user = user else { return cell }
        cell.viewModel = viewModel
        cell.delegate = self
        cell.configure(user: user)
        cellSelectionStyle.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        cell.selectedBackgroundView = cellSelectionStyle
        return cell
    }
    
    
    // MARK: - Header cells
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let viewModel = ProfileViewModel(rawValue: section) else { return UIView() }
        
        let iconImage = UIImageView(image: UIImage(systemName: viewModel.systemNameIcon))
        iconImage.setDimensions(height: viewModel.iconDimension.0, width: viewModel.iconDimension.1)
        
        iconImage.tintColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
        let label = UILabel()
        label.text = viewModel.sectionTitle
        label.textColor = #colorLiteral(red: 0.6274509804, green: 0.6274509804, blue: 0.6274509804, alpha: 1)
        label.backgroundColor = .clear
        label.textAlignment = .left
        
        
        let containerView = UIView()
        containerView.addSubview(iconImage)
        iconImage.centerY(inView: containerView, leftAnchor: containerView.leftAnchor, paddingLeft: 12)
        containerView.addSubview(label)
        label.centerY(inView: iconImage, leftAnchor: iconImage.rightAnchor, paddingLeft: 8)
        return containerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = ProfileViewModel(rawValue: indexPath.section) else { return  }
        guard let user = user else { return  }
        if viewModel == .section_2 {
            let updateEmailController = UpdateEmailController(user: user)
            updateEmailController.delegate = self
            navigationController?.pushViewController(updateEmailController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            checkUser()
            self.refreshController.endRefreshing()
        }
    }
    
}


// MARK: - ProfileFooterDelegate
extension ProfileController: ProfileFooterDelegate {
    func handleLogout(view: ProfileFooterView) {
        
        if Auth.auth().currentUser?.uid == nil {
            logout()
        } else {
            
            let alert = UIAlertController(title: nil, message: "Are you sure you want to logout ?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "log out", style: .destructive, handler: { (alertAction) in
                self.dismiss(animated: true) { [weak self] in self?.logout()  }
            }))
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}


// MARK: - ProfileCellDelegate
extension ProfileController: ProfileCellDelegate {
    func updateUserInfo(_ cell: ProfileCell, value: String, viewModel: ProfileViewModel) {
        guard var user = user else { return  }
        switch viewModel {
        case .section_1:
            user.phoneNumber = value
        case .section_2:
           print("")
        case .section_3:
            print("")
        case .section_4:
            print("")
        case .section_5:
            print("")
        }
        self.user = user
        configureNavBarButtons()
    }
    

    
    
    
    func showGuidelines(_ cell: ProfileCell) {
        let safetyControllerGuidelines = SafetyControllerGuidelines()
        safetyControllerGuidelines.modalPresentationStyle = .custom
        present(safetyControllerGuidelines, animated: true, completion: nil)
    }
    
}


// MARK: - ProfileHeaderDelegate
extension ProfileController: ProfileHeaderDelegate {
    
    func usernameChanges(_ header: ProfileHeader) {
        guard let newName = header.fullNameTextField.text else { return }
        user?.username = newName
        configureNavBarButtons()
    }
    
    func handleUpdatePhoto(_ header: ProfileHeader) {
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.Grid.FrameView.borderColor = .black
        Config.Grid.FrameView.fillColor = .black
        gallery.modalPresentationStyle = .fullScreen
        self.present(gallery, animated: true, completion: nil)
    }
}


// MARK: - GalleryControllerDelegate
extension ProfileController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            guard let image = images.first else { return  }
            image.resolve { [weak self] image in
                guard let image = image?.circleMasked else {return}
                self?.updateUserImage(image)
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
