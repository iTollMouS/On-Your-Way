//
//  NotificationsDetailsController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/20/20.
//

import UIKit
import SKPhotoBrowser

private let reuseIdentifier = "NotificationsDetailsCell"


protocol NotificationsDetailsControllerDelegate: class {
    func handleDismissalAndRefreshAfterDeleting()
}

class NotificationsDetailsController: UITableViewController {
    
    
    weak var delegate: NotificationsDetailsControllerDelegate?
    
    
    // MARK: - Propertes
    private var package: Package
    private lazy var headerView = OrderDetailHeader(package: package)
    private lazy var footerView = NotificationsFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 250))
    private var images = [SKPhoto]()
    private var traveler: User?
    private var user: User
    
    init(package: Package, user: User){
        self.package = package
        self.user = user
        super.init(style: .insetGrouped)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchTravelerInfo()
        configureDelegates()
        checkPackageStatus()
        fetchPackageImage()
    }
    
    fileprivate func fetchPackageImage(){
        DispatchQueue.main.async { [weak self] in
            FileStorage.downloadImage(imageUrl: self!.package.packageProofOfDeliveredImage) { image in
                guard let image = image else {return}
                self?.footerView.imagePlaceholder.image = image
                self?.footerView.imagePlaceholder.backgroundColor = .clear
                self?.footerView.imagePlaceholder.contentMode = .scaleAspectFill
                self?.footerView.imagePlaceholder.setDimensions(height: 60, width: 60)
                self?.footerView.imagePlaceholder.layer.cornerRadius = 60 / 2
                self?.footerView.imagePlaceholder.clipsToBounds = true
                self?.tableView.reloadData()
            }
        }
    }
    
    func checkPackageStatus(){
        switch package.packageStatus {
        case .packageIsPending:
            footerView.deleteOrderButton.isHidden = false
        case .packageIsRejected:
            footerView.deleteOrderButton.isHidden = false
        case .packageIsAccepted:
            footerView.deleteOrderButton.isHidden = false
        case .packageIsDelivered:
            footerView.deleteOrderButton.isHidden = true
        }
    }
    
    func configureDelegates(){
        footerView.delegate = self
        footerView.package = package
        headerView.delegate = self
    }
    
    fileprivate func fetchTravelerInfo(){
        TripService.shared.fetchUserFromTrip(tripId: package.tripID) { [weak self] user in
            self?.traveler = user
            self?.tableView.reloadData()
        }
    }
    
    var darkMode = false
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return darkMode ? .lightContent : .lightContent
    }
    
    
    // MARK: - configureTableView
    fileprivate func configureTableView(){
        tableView.register(NotificationsDetailsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = 140
        tableView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    // MARK: - cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationsDetailsCell
        cell.delegate = self
        switch indexPath.section {
        case 0:
            cell.package = package
        case 1:
            cell.traveler = traveler
            cell.packageStatus = package.packageStatus
        default: break
        }
        return cell
    }
    
    // MARK: - header View in section
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = section == 0 ?  "وصف الطلب" : "بدء المحادثة"
        label.textAlignment = .right
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    
}


// MARK: - OrderDetailHeaderDelegate
extension NotificationsDetailsController : OrderDetailHeaderDelegate {
    func handleShowImages(_ package: Package, indexPath: IndexPath) {
        
        FileStorage.downloadImage(imageUrl: package.packageImages[indexPath.row]) { [weak self] image in
            guard let image = image else {return}
            let photo = SKPhoto.photoWithImage(image)
            self?.images.append(photo)
            let browser = SKPhotoBrowser(photos: self!.images)
            browser.initializePageIndex(0)
            self?.present(browser, animated: true, completion: nil)
            self?.images.removeAll()
        }
        images.removeAll()
    }
}

extension NotificationsDetailsController: NotificationsDetailsCellDelegate {
    func handleStartChat(_ cell: NotificationsDetailsCell) {
        
        guard let selectedUser = traveler else { return  }
        let chatId = startChat(currentUser: user, selectedUser: selectedUser)
        let chatViewController = ChatViewController(chatRoomId: chatId,
                                                    recipientId: selectedUser.id,
                                                    recipientName: selectedUser.username)
        navigationController?.pushViewController(chatViewController, animated: true)
        
    }
}

extension NotificationsDetailsController : NotificationsFooterViewDelegate {
    func handleShowingProofOfDelivery(_ footerView: NotificationsFooterView) {
        guard let image = footerView.imagePlaceholder.image else {return}
        let photo = SKPhoto.photoWithImage(image)
        images.append(photo)
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(0)
        present(browser, animated: true, completion: nil)
        images.removeAll()
    }
    
    
    func handleCancellingMyOrder() {
        let alert = UIAlertController(title: nil, message: "هل انت متاكد من الغاء طلبك ؟", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "الغاء طلبي", style: .default, handler: { [weak self] (alertAction) in
            DispatchQueue.main.async { [weak self] in
                TripService.shared.fetchTrip(tripId: self!.package.tripID) { [weak self] trip in
                    TripService.shared.deleteMyOutgoingPackage(trip: trip, userId: self?.package.userID ?? "", package: self!.package) { [weak self] error in
                        if let error = error {
                            print("DEBIG error whule deleting the package \(error.localizedDescription)")
                            return
                        }
                        
                        CustomAlertMessage(condition: .success,
                                           messageTitle: "تم الغاء طلبك بنجاح",
                                           messageBody: "",
                                           size: CGSize(width: self!.view.frame.width - 50, height: 280)) { [weak self] in
                            self?.delegate?.handleDismissalAndRefreshAfterDeleting()
                            self?.view.isUserInteractionEnabled = true
                        }
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "الغاء", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}




