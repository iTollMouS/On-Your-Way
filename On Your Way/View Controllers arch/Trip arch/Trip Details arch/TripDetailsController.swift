//
//  TripDetailsController.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 10/4/20.
//

import UIKit
import SwiftEntryKit
import Firebase
import LNPopupController
import Lottie

private let reuseIdentifier = "TripDetailsCell"

protocol TripDetailsControllerDelegate: class {
    func handleShowRegistrationPageForNonusers(_ view: TripDetailsController)
}

class TripDetailsController: UIViewController {
    
    
    // MARK: - delegate
    weak var delegate: TripDetailsControllerDelegate?
    
    
    // MARK: - Properties
    private lazy var headerView = TripDetailsHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
    private lazy var footerView = TripDetailsFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
    
    private lazy var customAlertView = UIView()
    var attributes = EKAttributes.bottomNote
    
    private lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.2156862745, green: 0.2156862745, blue: 0.2156862745, alpha: 1)
        view.layer.cornerRadius = 30
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "Ops!\n",
                                                       attributes: [.foregroundColor : #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1),
                                                                    .font: UIFont.boldSystemFont(ofSize: 18)])
        attributedText.append(NSMutableAttributedString(string: "You can not ship packages without an account.\nPlease press Ok on the bottom to go back",
                                                        attributes: [.foregroundColor : UIColor.lightGray,
                                                                     .font: UIFont.systemFont(ofSize: 16)]))
        
        label.attributedText = attributedText
        label.setHeight(height: 80)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var dismissalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Okay", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1), for: .normal)
        button.setDimensions(height: 50, width: 300)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 50 / 2
        button.backgroundColor = #colorLiteral(red: 0.3450980392, green: 0.3450980392, blue: 0.3450980392, alpha: 1)
        button.addTarget(self, action: #selector(handleAnonymousMode), for: .touchUpInside)
        return button
    }()
    
    
    
    
    
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(TripDetailsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = 800
        return tableView
    }()

    
    
    private var trip: Trip
    private var user: User
    
    private lazy var animationView: AnimationView = {
        let animationView = AnimationView()
        animationView.setDimensions(height: 100, width: 100)
        animationView.clipsToBounds = true
        animationView.backgroundColor = .clear
        animationView.contentMode = .scaleAspectFill
        return animationView
    }()
    
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
        configureDelegates()
        fetchUser()
        print("DEBUG: the current user is \(User.currentId)")
    }
    
    var darkMode = false
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return darkMode ? .lightContent : .lightContent
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let peopleReviewsController = PeopleReviewsController(user: user)
        peopleReviewsController.popupItem.title = "People Reviews "
        peopleReviewsController.popupItem.subtitle = "Tab here to see who wrote a review about you"
        peopleReviewsController.popupItem.progress = 0.34
        tabBarController?.popupBar.titleTextAttributes = [ .foregroundColor: UIColor.white ]
        tabBarController?.popupBar.subtitleTextAttributes = [ .foregroundColor: UIColor.gray ]
        tabBarController?.presentPopupBar(withContentViewController: peopleReviewsController, animated: true, completion: nil)
    }
    
    
    // MARK: - fetchUser()
    func fetchUser(){
        UserServices.shared.fetchUser(userId: trip.userID) { user in
            self.user = user
            DispatchQueue.main.async { [weak self ] in
                self?.headerView.user = user
                self?.tableView.reloadData()
            }
        }
        
        if trip.userID == User.currentId {
            footerView.isHidden = true
            headerView.startChatButton.isHidden = true
        }
        
    }
    
    func configureDelegates(){
        headerView.delegate = self
        footerView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func configureUI(){
        view.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
    @objc fileprivate func handleAnonymousMode(){
        SwiftEntryKit.dismiss() { [weak self] in
            self?.view.isUserInteractionEnabled = true
            self?.delegate?.handleShowRegistrationPageForNonusers(self!)
        }
    }
    
}

// MARK: - Table Extensions
extension TripDetailsController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TripDetailsViewModel.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfCells = TripDetailsViewModel(rawValue: section) else { return 0 }
        return numberOfCells.numberOfCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TripDetailsCell
        guard let viewModel = TripDetailsViewModel(rawValue: indexPath.section) else { return cell }
        cell.viewModel = viewModel
        cell.trip = trip
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let titleInSection = TripDetailsViewModel(rawValue: section) else { return nil }
        let label = UILabel()
        label.text = titleInSection.titleInSection
        label.textAlignment = .left
        label.textColor = .lightGray
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionHeight = TripDetailsViewModel(rawValue: section) else { return 0 }
        return sectionHeight.heightInSection
    }
    
}


// MARK:- Header Delegate + start chat
extension TripDetailsController : TripDetailsHeaderViewDelegate {
    func handleReviewsTapped(_ view: TripDetailsHeaderView) {
        
        let peopleReviewsController = PeopleReviewsController(user: user)
        present(peopleReviewsController, animated: true, completion: nil)
    }
    
    func handleStartToChat(_ view: TripDetailsHeaderView) {
        
        // step 0  :
        UserServices.shared.fetchUser(userId: User.currentId) { [weak self] user in
            print("DEBUG: user name is \(user.username)")
            
            let chatId = startChat(currentUser: user, selectedUser: self!.user)
            let chatViewController = ChatViewController(chatRoomId: chatId,
                                                        recipientId: self!.trip.userID,
                                                        recipientName: self!.user.username)
            
            self?.navigationController?.pushViewController(chatViewController, animated: true)
        }
    }
    
}



// MARK: - Footer Delegate
extension TripDetailsController: TripDetailsFooterViewDelegate {
    
    func handleSendingPackage(_ footer: TripDetailsFooterView) {
        
        
        if User.currentUser?.id == nil {
            showCustomAlertView(condition: .warning)
            return
        }
        let sendPackageController = SendPackageController(user: user, trip: trip)
        sendPackageController.delegate = self
        let navBar = UINavigationController(rootViewController: sendPackageController)
        navBar.isModalInPresentation = true
        present(navBar, animated: true, completion: nil)
    }
    
}


// MARK: - SendPackageControllerDelegate
extension TripDetailsController : SendPackageControllerDelegate {
    func handleDismissalView(_ view: SendPackageController) {
        view.dismiss(animated: true) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    
}


// MARK: - showCustomAlertView()
extension TripDetailsController {
    
    func showCustomAlertView(condition: Conditions) {
        configureCustomAlertUI()
        
        switch condition {
        case .success:
            animationView.animation = Animation.named(condition.JSONStringName)
            animationView.play()
            animationView.loopMode = .repeat(5)
        case .warning:
            animationView.animation = Animation.named(condition.JSONStringName)
            animationView.play()
            animationView.loopMode = .repeat(5)
        case .error:
            animationView.animation = Animation.named(condition.JSONStringName)
            animationView.play()
            animationView.loopMode = .repeat(5)
        }
    }
    
    func configureCustomAlertUI(){
        view.isUserInteractionEnabled = false
        customAlertView.clipsToBounds = true
        customAlertView.addSubview(bottomContainerView)
        customAlertView.addSubview(animationView)
        
        animationView.centerX(inView: customAlertView, topAnchor: customAlertView.topAnchor, paddingTop: 0)
        bottomContainerView.anchor(top: animationView.bottomAnchor, left: customAlertView.leftAnchor, bottom: customAlertView.bottomAnchor, right: customAlertView.rightAnchor, paddingTop: -50)
        
        bottomContainerView.addSubview(messageLabel)
        messageLabel.anchor(top: bottomContainerView.topAnchor, left: bottomContainerView.leftAnchor, right: bottomContainerView.rightAnchor, paddingTop: 50)
        bottomContainerView.addSubview(dismissalButton)
        dismissalButton.anchor(left: bottomContainerView.leftAnchor, bottom: bottomContainerView.bottomAnchor, right: bottomContainerView.rightAnchor,
                               paddingLeft: 30, paddingBottom: 30, paddingRight: 30)
        
        customAlertView.backgroundColor = .clear
        customAlertView.layer.cornerRadius = 10
        customAlertView.setDimensions(height: 300, width: view.frame.width - 50)
        attributes.screenBackground = .visualEffect(style: .dark)
        attributes.positionConstraints.safeArea = .overridden
        attributes.positionConstraints.verticalOffset = 250
        attributes.windowLevel = .normal
        attributes.position = .bottom
        attributes.precedence = .override(priority: .max, dropEnqueuedEntries: false)
        attributes.displayDuration = .infinity
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.statusBar = .light
        attributes.entryBackground = .clear
        SwiftEntryKit.display(entry: customAlertView, using: attributes)
    }
    
}
