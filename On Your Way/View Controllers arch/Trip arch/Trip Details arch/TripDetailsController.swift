//
//  TripDetailsController.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 10/4/20.
//

import UIKit
import SwiftEntryKit

private let reuseIdentifier = "TripDetailsCell"

protocol TripDetailsControllerDelegate: class {
    func handleShowRegistrationPageForNonusers(_ view: TripDetailsController)
}

class TripDetailsController: UIViewController {
    
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
    
    var trip: Trip?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureDelegates()
        fetchUser()
    }
    
    func fetchUser(){
        guard let trip = trip else { return  }
        
        UserServices.shared.fetchUser(userId: trip.userID) { user in
            self.user = user
            self.headerView.user = user
            self.tableView.reloadData()
        }
        
        if trip.userID == User.currentId {
            footerView.isHidden = true
            headerView.submitReviewButton.isHidden = true
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let peopleReviewsController = PeopleReviewsController()
        peopleReviewsController.popupItem.title = "People Reviews "
        peopleReviewsController.popupItem.subtitle = "Tab here to see who wrote a review about you"
        peopleReviewsController.popupItem.progress = 0.34
        tabBarController?.popupBar.titleTextAttributes = [ .foregroundColor: UIColor.white ]
        tabBarController?.popupBar.subtitleTextAttributes = [ .foregroundColor: UIColor.gray ]
        tabBarController?.presentPopupBar(withContentViewController: peopleReviewsController, animated: true, completion: nil)
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

extension TripDetailsController : TripDetailsHeaderViewDelegate {
    func handleReviewsTapped(_ view: TripDetailsHeaderView) {
        
    }
    
    func handleStartToChat(_ view: TripDetailsHeaderView) {
        
        // it is working , now you have to implement the functionality
        print("DEBUG: ctart chat in veiw controller ")
    }
    
    
}

extension TripDetailsController: TripDetailsFooterViewDelegate {
    
    func handleSendingPackage(_ footer: TripDetailsFooterView) {
        guard let user = user else { return }
        guard let trip = trip else { return }
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

extension TripDetailsController : SendPackageControllerDelegate {
    func handleDismissalView(_ view: SendPackageController) {
        view.dismiss(animated: true) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    
}

extension TripDetailsController {
    
    func showCustomAlertView() {
        
        reviewSheetPopOver.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        reviewSheetPopOver.layer.cornerRadius = 10
        reviewSheetPopOver.setDimensions(height: 300, width: view.frame.width - 50)
        attributes.screenBackground = .visualEffect(style: .dark)
        attributes.positionConstraints.safeArea = .overridden
        
        attributes.positionConstraints.verticalOffset = 250
        //        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        //        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        //        attributes.positionConstraints.keyboardRelation = keyboardRelation
        attributes.windowLevel = .normal
        attributes.position = .bottom
        attributes.precedence = .override(priority: .max, dropEnqueuedEntries: false)
        attributes.displayDuration = .infinity // do something when the user touch the card e.g .dismiss make the card dismisses on touch
        attributes.screenInteraction = .dismiss // do something when the user touch the screen e.g .dismiss make the card dismisses on touch
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.statusBar = .light
        //        attributes.entranceAnimation = .init(
        //                         translate: .init(duration: 0.7, anchorPosition: .top, spring: .init(damping: 1, initialVelocity: 0)),
        //                         scale: .init(from: 0.6, to: 1, duration: 0.7),
        //                         fade: .init(from: 0.8, to: 1, duration: 0.3))
//        attributes.lifecycleEvents.willAppear = { [self] in
//
//        }
        
//        attributes.lifecycleEvents.didAppear = { [self] in
//            // Executed after the entry animates inside
//
//            print("didAppear")
//        }
        
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

