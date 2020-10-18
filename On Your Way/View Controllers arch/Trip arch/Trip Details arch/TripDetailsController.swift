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

private let reuseIdentifier = "TripDetailsCell"

protocol TripDetailsControllerDelegate: class {
    func handleShowRegistrationPageForNonusers(_ view: TripDetailsController)
}

class TripDetailsController: UIViewController {
    
    
    // MARK: - Properties
    private lazy var headerView = TripDetailsHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
    private lazy var footerView = TripDetailsFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
    
    private lazy var reviewSheetPopOver = UIView()
    var attributes = EKAttributes.bottomNote
    
    weak var delegate: TripDetailsControllerDelegate?
    
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
            self.headerView.user = user
            self.tableView.reloadData()
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
            showCustomAlertView()
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
    
    func showCustomAlertView() {
        
        reviewSheetPopOver.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        reviewSheetPopOver.layer.cornerRadius = 10
        reviewSheetPopOver.setDimensions(height: 300, width: view.frame.width - 50)
        attributes.screenBackground = .visualEffect(style: .dark)
        attributes.positionConstraints.safeArea = .overridden
        attributes.positionConstraints.verticalOffset = 250
        attributes.windowLevel = .normal
        attributes.position = .bottom
        attributes.precedence = .override(priority: .max, dropEnqueuedEntries: false)
        attributes.displayDuration = .infinity // do something when the user touch the card e.g .dismiss make the card dismisses on touch
        attributes.screenInteraction = .dismiss // do something when the user touch the screen e.g .dismiss make the card dismisses on touch
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.statusBar = .light
        
        attributes.lifecycleEvents.willDisappear = { [weak self] in
            self?.delegate?.handleShowRegistrationPageForNonusers(self!)
        }
        
        attributes.lifecycleEvents.didDisappear = {
            // Executed after the entry animates outside
            print("didDisappear")
        }
        attributes.entryBackground = .visualEffect(style: .dark)
        SwiftEntryKit.display(entry: reviewSheetPopOver, using: attributes)
    }
    
}
