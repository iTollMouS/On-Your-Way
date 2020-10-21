//
//  NotificationsDetailsController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/20/20.
//

import UIKit
import SKPhotoBrowser

private let reuseIdentifier = "NotificationsDetailsCell"

class NotificationsDetailsController: UITableViewController {
    
    
    // MARK: - Propertes
    private var package: Package
    private lazy var headerView = OrderDetailHeader(package: package)
    private lazy var footerView = NotificationsFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 120))
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
        tableView.rowHeight = 150
        tableView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        tableView.tableHeaderView = headerView
        headerView.delegate = self
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
        label.text = section == 0 ?  "Package description" : "Star Chat"
        label.textAlignment = .left
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

