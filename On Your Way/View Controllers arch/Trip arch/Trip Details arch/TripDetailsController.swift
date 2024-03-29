//
//  TripDetailsController.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 10/4/20.
//

import UIKit
import Firebase
import LNPopupController

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
    private var traveler: User?
    
    
    init(trip: Trip) {
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
        
    }
    
    
    override func viewDidLayoutSubviews() {
        tableView.layoutIfNeeded()
    }
    
    var darkMode = false
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return darkMode ? .lightContent : .lightContent
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let traveler = traveler else { return  }
        let peopleReviewsController = PeopleReviewsController(user: traveler)
        peopleReviewsController.popupItem.title = "تقييم العملاء "
        peopleReviewsController.popupItem.subtitle = "شاهد تقييم العملاء عن اداء \(traveler.username)"
        peopleReviewsController.popupItem.progress = 0.34
        tabBarController?.popupBar.titleTextAttributes = [ .foregroundColor: UIColor.white ]
        tabBarController?.popupBar.subtitleTextAttributes = [ .foregroundColor: UIColor.gray ]
        tabBarController?.presentPopupBar(withContentViewController: peopleReviewsController, animated: true, completion: nil)
    }
    
    
    // MARK: - fetchUser()
    func fetchUser(){
        UserServices.shared.fetchUser(userId: trip.userID) { traveler in
            self.traveler = traveler
            DispatchQueue.main.async { [weak self ] in
                self?.headerView.traveler = traveler
                self?.footerView.traveler = traveler
                self?.tableView.reloadData()
            }
        }
        
        if trip.userID == User.currentId {
            footerView.isHidden = true
            headerView.startChatButton.isHidden = true
        }
        
    }
    
    // MARK: - configureDelegates
    func configureDelegates(){
        footerView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        headerView.delegate = self
    }
    
    
    // MARK: - configureUI
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
        label.textAlignment = .right
        label.textColor = .lightGray
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionHeight = TripDetailsViewModel(rawValue: section) else { return 0 }
        return sectionHeight.heightInSection
    }
    
}



// MARK: - Footer Delegate
extension TripDetailsController: TripDetailsFooterViewDelegate {
    
    func handleSendingPackage(_ footer: TripDetailsFooterView) {
        guard let traveler = traveler else { return  }
        if User.currentUser?.id == nil {
            self.view.isUserInteractionEnabled = false
            CustomAlertMessage(condition: .error,
                               messageTitle: "تصفح بدون حساب",
                               messageBody: "لاتستطيع ارسال شحنه ، او المحادثه بدون حساب \n الرجاء الرجوع للصفحة الرئيسية لانشاء حساب ",
                               size: CGSize(width: view.frame.width - 50, height: 280)) { [weak self] in
                self?.view.isUserInteractionEnabled = true
                self?.delegate?.handleShowRegistrationPageForNonusers(self!)
            }
            return
        }
        
        let sendPackageController = SendPackageController(user: traveler, trip: trip)
        sendPackageController.delegate = self
        let navBar = UINavigationController(rootViewController: sendPackageController)
        navBar.isModalInPresentation = true
        present(navBar, animated: true, completion: nil)
    }
    
}


// MARK: - PeopleReviewsControllerDelegate
extension TripDetailsController: PeopleReviewsControllerDelegate {
    func handleLoggingOutAnonymousUser(_ view: PeopleReviewsController) {
        view.dismiss(animated: true) { [weak self] in
            self?.delegate?.handleShowRegistrationPageForNonusers(self!)
        }
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


// MARK:- Header Delegate + start chat
extension TripDetailsController : TripDetailsHeaderViewDelegate {
    func handleStartToChat(_ view: TripDetailsHeaderView) {
        
    }
    
    func handleReviewsTapped(_ view: TripDetailsHeaderView) {
        guard let traveler = traveler else { return  }
        let peopleReviewsController = PeopleReviewsController(user: traveler)
        peopleReviewsController.delegate = self
        let navBarPeopleReviewsController = UINavigationController(rootViewController: peopleReviewsController)
        navBarPeopleReviewsController.navigationBar.barStyle = .black
        navBarPeopleReviewsController.navigationBar.isTranslucent = true
        present(navBarPeopleReviewsController, animated: true, completion: nil)
    }
}

//    func handleStartToChat(_ view: TripDetailsHeaderView) {
//        guard let traveler = traveler else { return  }
//        if User.currentUser?.id == nil {
//            CustomAlertMessage(condition: .error, messageTitle: "تصفح بدون حساب",
//                               messageBody: "لاتستطيع ارسال شحنه ، او المحادثه بدون حساب \n الرجاء الرجوع للصفحة الرئيسية لانشاء حساب ",
//                               setWidth: 399, setHeight: 300) { [weak self] in
//                self?.delegate?.handleShowRegistrationPageForNonusers(self!)
//            }
//            return
//        }
//
//        UserServices.shared.fetchUser(userId: User.currentId) { [weak self] user in
//            print("DEBUG: user name is \(user.username)")
//
//            let chatId = startChat(currentUser: user, selectedUser: traveler)
//            let chatViewController = ChatViewController(chatRoomId: chatId,
//                                                        recipientId: self!.trip.userID,
//                                                        recipientName: traveler.username)
//
//            self?.navigationController?.pushViewController(chatViewController, animated: true)
//        }
//    }
//}
//
