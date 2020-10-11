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
    
    private lazy var headerView = ProfileHeader(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
    private lazy var footerView = ProfileFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
    
    private let gallery = GalleryController ()
    let cellSelectionStyle = UIView()
    
    var user: User?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style:.insetGrouped)
        tableView.register(ProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 50
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configureUI()
        configureNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        checkUser()
        let demoVC = PeopleReviewsController()
        demoVC.popupItem.title = "People Reviews "
        demoVC.popupItem.subtitle = "Tab here to see who wrote a review about you"
        demoVC.popupItem.progress = 0.34
        tabBarController?.modalPresentationStyle = .custom
        tabBarController?.popupBar.titleTextAttributes = [ .foregroundColor: UIColor.white ]
        tabBarController?.popupBar.subtitleTextAttributes = [ .foregroundColor: UIColor.gray ]
        tabBarController?.presentPopupBar(withContentViewController: demoVC, animated: true, completion: nil)
    }
    
    func checkUser(){
        if Auth.auth().currentUser?.uid == nil {
            footerView.logoutButton.setTitle("Create Account", for: .normal)
        } else {
            footerView.logoutButton.setTitle("Log out", for: .normal)
        }
    }
    
    
    func configureUI(){
        view.addSubview(tableView)
        tableView.fillSuperview()
        gallery.delegate = self
        headerView.delegate = self
        footerView.delegate = self
    }
    
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    func configureNavBar(){
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Profile"
    }
    
    
    func logout(){
        AuthServices.shared.logOutUser { [weak self] error in
            if let error = error {
                ProgressHUD.showError("\(error.localizedDescription)")
                return
            }
            
            print("DEBUG: user is logged out")
            self?.presentLoggingController()
            self?.tabBarController?.selectedIndex = 0
        }
    }
    
    func presentLoggingController(){
        DispatchQueue.main.async { [ weak self] in
            let loginController = LoginController()
            loginController.delegate = self
            let nav = UINavigationController(rootViewController: loginController)
            nav.modalPresentationStyle = .fullScreen
            self?.present(nav, animated: true, completion: nil)
        }
    }
    
}

extension ProfileController: LoginControllerDelegate {
    func handleLoggingControllerDismissal(_ view: LoginController) {
        view.dismiss(animated: true, completion: nil)
    }
}

extension ProfileController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileViewModel.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileViewModel.allCases[section].numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ProfileCell
        guard let viewModel = ProfileViewModel(rawValue: indexPath.section) else { return cell }
        cell.viewModel = viewModel
        cell.delegate = self
        cellSelectionStyle.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        cell.selectedBackgroundView = cellSelectionStyle
        return cell
    }
    
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

extension ProfileController: ProfileFooterDelegate {
    func handleLogout(view: ProfileFooterView) {
        
        if Auth.auth().currentUser?.uid == nil {
            logout()
        } else {
            
            let alert = UIAlertController(title: nil, message: "Are you sure you want to logout ?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "log out", style: .destructive, handler: { (alertAction) in
                self.dismiss(animated: true) { [self] in logout()  }
            }))
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}

extension ProfileController: ProfileCellDelegate {
    func showGuidelines(_ cell: ProfileCell) {
        let safetyControllerGuidelines = SafetyControllerGuidelines()
        safetyControllerGuidelines.modalPresentationStyle = .custom
        present(safetyControllerGuidelines, animated: true, completion: nil)
    }
    
}

extension ProfileController: ProfileHeaderDelegate {
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

extension ProfileController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
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
