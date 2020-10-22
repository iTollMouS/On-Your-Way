//
//  AdminController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/22/20.
//

import UIKit
import SwiftEntryKit
import Firebase
import SDWebImage

private let reuseIdentifier = "AdminCell"

class AdminController: UIViewController {
    
    
    private lazy var headerView = AdminHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 150))
    
    lazy var saveChangesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Save changes", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleUpdateUserData), for: .touchUpInside)
        button.setDimensions(height: 48, width: 300)
        button.layer.cornerRadius = 48 / 2
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.alpha = 0
        button.setupShadow(opacity: 0.5, radius: 16, offset: CGSize(width: 0.0, height: 8.0), color: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1))
        return button
    }()
    
    
    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1).withAlphaComponent(0.6)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleCustomAlertDismissal), for: .touchUpInside)
        button.setDimensions(height: 48, width: 300)
        button.layer.cornerRadius = 48 / 2
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.5, radius: 16, offset: CGSize(width: 0.0, height: 8.0), color: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1))
        return button
    }()
    
    
    lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["remove verification", "Verify user ✅"])
        let normalTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControl.setTitleTextAttributes(normalTitleTextAttributes, for: .normal)
        let selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)]
        segmentedControl.setDimensions(height: 30, width: 360)
        segmentedControl.backgroundColor = .darkGray
        segmentedControl.setTitleTextAttributes(selectedTitleTextAttributes, for: .selected)
        segmentedControl.addTarget(self, action: #selector(handleVerificationChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    
    private lazy var checkMarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark.seal.fill"), for: .normal)
        button.tintColor = .systemGreen
        button.backgroundColor = .white
        button.imageView?.setDimensions(height: 14, width: 14)
        button.setDimensions(height: 14, width: 14)
        button.layer.cornerRadius = 14 / 2
        button.clipsToBounds = true
        button.isHidden = true
        return button
    }()
    
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.text = "tariq almazyad"
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.text = "0500845000"
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.setDimensions(height: 50, width: 50)
        imageView.layer.cornerRadius = 50 / 2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 0.8
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userNameLabel,
                                                       phoneNumberLabel])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    
    private let blurView : UIVisualEffectView = {
        let blurView = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurView)
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style:.insetGrouped)
        tableView.backgroundColor = .clear
        tableView.rowHeight = 80
        tableView.tableHeaderView = headerView
        tableView.register(AdminCell.self, forCellReuseIdentifier: reuseIdentifier)
        return tableView
    }()
    
    
    private lazy var customAlertView = UIView()
    private lazy var topDividerCustomAlertView = UIView()
    var attributes = EKAttributes.bottomNote
    
    let cellSelectionStyle = UIView()
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private var users = [User]()
    private var filteredUsers = [User]()
    private var usersDictionary = [String: User]()
    private var selectedUser: User?
    private var isVerified: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavBar()
        fetchUsers()
        configureDelegates()
    }
    
    
    fileprivate func configureDelegates(){
        tableView.delegate = self
        tableView.dataSource = self
        headerView.delegate = self
    }
    
    fileprivate func fetchUsers(){
        DispatchQueue.main.async { [weak self] in
            UserServices.shared.downloadAllUsers { [weak self] users in
                for user in users {
                    self?.usersDictionary[user.id] = user
                }
                self?.users = Array(self!.usersDictionary.values)
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - configureNavBar
    func configureNavBar(){
        self.title = "Admin"
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(handleDismissal))
        self.navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for trip"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    
    // MARK: - Actions
    @objc func handleDismissal(){
        dismiss(animated: true, completion: nil)
    }
    
    
    func configureUI(){
        view.backgroundColor = .clear
        view.addSubview(blurView)
        blurView.frame = view.frame
        view.addSubview(tableView)
        tableView.fillSuperviewSafeAreaLayoutGuide()
        
    }
    
    @objc fileprivate func handleVerificationChanged(){
        UIView.animate(withDuration: 0.5) { [weak self] in self?.saveChangesButton.alpha = 1 }
        
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            isVerified = false
        case 1:
            isVerified = true
        default: break
        }
        
    }
    
    @objc fileprivate func handleUpdateUserData(){
        guard var user = selectedUser else { return }
        user.isUserVerified = isVerified
        UserServices.shared.saveUserToFirestore(user)
        SwiftEntryKit.dismiss()
        tableView.reloadData()
    }
    
    @objc fileprivate func handleCustomAlertDismissal(){
        SwiftEntryKit.dismiss()
        tableView.reloadData()
    }
    
}

extension AdminController: UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! AdminCell
        cell.user = searchController.isActive ? filteredUsers[indexPath.row] : users[indexPath.row]
        cellSelectionStyle.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        cell.selectedBackgroundView = cellSelectionStyle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = searchController.isActive ? filteredUsers[indexPath.row] : users[indexPath.row]
        checkMarkButton.isHidden = !selectedUser!.isUserVerified
        showUserProfile()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension AdminController: AdminHeaderViewDelegate{
    func handleActionTapped(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            print("DEBUG: 0 is tapped")
        case 2:
            print("DEBUG: 0 is tapped")
        default: break
        }
    }
}

extension AdminController :  UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchedText = searchController.searchBar.text else { return }
        filteredUsers = users.filter({ (user) -> Bool in
            guard let email = user.email else {return false}
            return user.username.lowercased().contains(searchedText.lowercased())
                || email.lowercased().contains(searchedText.lowercased())
        })
        
        tableView.reloadData()
    }
}



extension AdminController {
    
    fileprivate func showUserProfile(){
        guard let user = selectedUser else { return }
        guard let imageUrl = URL(string: user.avatarLink) else { return }
        profileImageView.sd_setImage(with: imageUrl)
        userNameLabel.text = user.username
        phoneNumberLabel.text = user.phoneNumber
        
        view.isUserInteractionEnabled = false
        
        customAlertView.addSubview(topDividerCustomAlertView)
        topDividerCustomAlertView.centerX(inView: customAlertView, topAnchor: customAlertView.topAnchor, paddingTop: 10)
        topDividerCustomAlertView.setDimensions(height: 4, width: 100)
        topDividerCustomAlertView.backgroundColor = .white
        topDividerCustomAlertView.layer.cornerRadius = 4 / 2
        
        
        customAlertView.addSubview(profileImageView)
        profileImageView.anchor(top: customAlertView.topAnchor, left: customAlertView.leftAnchor, paddingTop: 30, paddingLeft: 20)
        
        
        customAlertView.addSubview(checkMarkButton)
        checkMarkButton.anchor(top: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: -14)
        
        customAlertView.addSubview(stackView)
        stackView.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
        customAlertView.addSubview(segmentedControl)
        segmentedControl.centerX(inView: customAlertView, topAnchor: stackView.bottomAnchor, paddingTop: 32)
        
        customAlertView.addSubview(dismissButton)
        dismissButton.centerX(inView: customAlertView, topAnchor: segmentedControl.bottomAnchor, paddingTop: 43)
        customAlertView.addSubview(saveChangesButton)
        saveChangesButton.centerX(inView: customAlertView, topAnchor: dismissButton.bottomAnchor, paddingTop: 12)
        
        customAlertView.clipsToBounds = true
        customAlertView.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        customAlertView.layer.cornerRadius = 10
        customAlertView.setDimensions(height: 550, width: view.frame.width)
        
        
        attributes.screenBackground = .visualEffect(style: .dark)
        attributes.positionConstraints.safeArea = .overridden
        attributes.positionConstraints.verticalOffset = -150
        attributes.windowLevel = .alerts
        attributes.position = .bottom
        attributes.precedence = .override(priority: .max, dropEnqueuedEntries: false)
        attributes.displayDuration = .infinity
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
        attributes.statusBar = .light
        attributes.lifecycleEvents.willDisappear = { [weak self] in
            self?.view.isUserInteractionEnabled = true
        }
        attributes.entryBackground = .clear
        SwiftEntryKit.display(entry: customAlertView, using: attributes)
    }
}

