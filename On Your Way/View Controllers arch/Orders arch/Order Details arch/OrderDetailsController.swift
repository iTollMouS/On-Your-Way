//
//  OrderDetailsController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/13/20.
//

import UIKit
import SwiftEntryKit
import SKPhotoBrowser

private let reuseIdentifier = "OrderDetailsCell"

protocol OrderDetailsControllerDelegate: class {
    func handleDismissalAndRefreshing(_ view: OrderDetailsController)
    func handleRefreshTableAfterAction()
}


class OrderDetailsController: UIViewController {
    
    weak var delegate: OrderDetailsControllerDelegate?
    
    private lazy var headerView = OrderDetailHeader(package: package)
    private lazy var footerView = OrderDetailsFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 250))
    
    private var viewModel: PackageStatus?
    private var images = [SKPhoto]()
    
    private lazy var rejectButton = createButton(tagNumber: 0, title: "Reject Order\nThis order will be removed",
                                                 backgroundColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), colorAlpa: 0.6, systemName: "checkmark.circle.fill")
    
    private lazy var acceptButton = createButton(tagNumber: 1, title: "Accept", backgroundColor: #colorLiteral(red: 0.1803921569, green: 0.5215686275, blue: 0.431372549, alpha: 1), colorAlpa: 0.6, systemName: "checkmark.circle.fill")
    private lazy var startChatButton = createButton(tagNumber: 2, title: "Chat", backgroundColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1), colorAlpa: 0.4, systemName: "bubble.left.and.bubble.right.fill")
    
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(TripDetailsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = 60
        return tableView
    }()
    
    private var package: Package
    private var user: User
    private var packageOwner: User?
    
    
    init(package: Package, user: User) {
        self.package = package
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDelegates()
        fetchPackageOwnerInfo()
        
    }
    
    fileprivate func fetchPackageOwnerInfo(){
        UserServices.shared.fetchUser(userId: package.userID) { [weak self] user in
            self?.packageOwner = user
            DispatchQueue.main.async { [weak self] in
                self?.title = self!.packageOwner?.username
                self?.footerView.startChatButton.setTitle("Chat with \(user.username)  ", for: .normal)
            }
        }
    }
    
    fileprivate func configureDelegates(){
        tableView.delegate = self
        tableView.dataSource = self
        headerView.delegate = self
        footerView.delegate = self
        footerView.package = package
        
    }
    
    fileprivate func configureUI(){
        view.addSubview(tableView)
        tableView.fillSuperview()
        tableView.register(OrderDetailsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
    }
    
    @objc fileprivate func handleViewDismissal(_ sender: UIButton){
        view.isUserInteractionEnabled = true
        switch sender.tag {
        case 0:
            SwiftEntryKit.dismiss(.displayed) { [weak self] in self?.delegate?.handleDismissalAndRefreshing(self!) }
        case 1:
            SwiftEntryKit.dismiss(.displayed)
        default: break
        }
        
    }
}

extension OrderDetailsController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! OrderDetailsCell
        cell.package = package
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Package description"
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    
}

extension OrderDetailsController : OrderDetailHeaderDelegate {
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

extension OrderDetailsController: OrderDetailsFooterViewDelegate {
    func assignPackageStatus(_ sender: UIButton, _ footer: OrderDetailsFooterView) {
        
        switch sender.tag {
        // reject
        case 0:
            self.package.packageStatus = .packageIsRejected
            self.package.packageStatusTimestamp = Date().convertDate(formattedString: .formattedType2)
            let alert = UIAlertController(title: nil, message: "Are you sure you want delete this order \nYou can not undo this action if you reject it?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Reject order", style: .destructive, handler: { [weak self] (alertAction) in
                self?.view.isUserInteractionEnabled = false
                DispatchQueue.main.async { [weak self] in
                    CustomAlertMessage(condition: .warning,
                                       messageTitle: "الغاء الطلب",
                                       messageBody: "تم رفض الطلب \nسيتم ارسال تنبيه للعميل على رفض الطلب",
                                       size: CGSize(width: self!.view.frame.width - 50, height: 280)) { [weak self] in
                        self?.view.isUserInteractionEnabled = true
                        TripService.shared.updatePackageStatus(userId: User.currentId, package: self!.package) { [weak self] error in
                            PushNotificationService.shared.sendPushNotification(userIds: [self!.package.userID],
                                                                                body: "\(self!.user.username) رفض طلبك ",
                                                                                title: "طلب مرفوض")
                            self?.delegate?.handleDismissalAndRefreshing(self!)
                        }
                    }
                }
            }
            
            ))
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
        //accept
        case 1:
            self.package.packageStatus = .packageIsAccepted
            self.package.packageStatusTimestamp = Date().convertDate(formattedString: .formattedType2)
            let alert = UIAlertController(title: nil, message: "هل انت متاكد من قبول الطلب؟", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "قبول الطلب", style: .default, handler: { [weak self] (alertAction) in
                DispatchQueue.main.async { [weak self] in
                    CustomAlertMessage(condition: .success,
                                       messageTitle: "تم قبول الطلب",
                                       messageBody: " تم قبول الطلب بنجاح \nسيتم ارسال تنبيه للعميل على قبول الطلب",
                                       size: CGSize(width: self!.view.frame.width - 50, height: 280)) { [weak self] in
                        self?.view.isUserInteractionEnabled = true
                        TripService.shared.updatePackageStatus(userId: User.currentId, package: self!.package) { [weak self] error in
                            PushNotificationService.shared.sendPushNotification(userIds: [self!.package.userID],
                                                                                body: " طلبك مقبول 📦 🤩 الان تستطيع المحادثة مع \(self!.user.username) ",
                                                                                title: "طلب مقبول")
                            self?.delegate?.handleRefreshTableAfterAction()
                            
                        }
                    }
                }
                
            }))
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        // chat
        case 2:
            UserServices.shared.fetchUser(userId: package.userID) { [weak self] packageOwner in
                guard let currentUser = User.currentUser else {return}
                let chatId = startChat(currentUser: currentUser, selectedUser: packageOwner)
                let chatViewController = ChatViewController(chatRoomId: chatId,
                                                            recipientId: packageOwner.id,
                                                            recipientName: packageOwner.username)
                self?.navigationController?.pushViewController(chatViewController, animated: true)
            }
            
        default:
            break
        }
    }
    
}

extension OrderDetailsController{
    
    fileprivate  func createButton(tagNumber: Int, title: String, backgroundColor: UIColor, colorAlpa: CGFloat, systemName: String  ) -> UIButton {
        let button = UIButton(type: .system)
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.setTitle("\(title) order  ", for: .normal)
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.backgroundColor = backgroundColor.withAlphaComponent(colorAlpa)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleViewDismissal), for: .touchUpInside)
        button.setDimensions(height: 50, width: 200)
        button.titleLabel?.numberOfLines = 0
        button.layer.cornerRadius = 50 / 2
        button.tag = tagNumber
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.5, radius: 16, offset: CGSize(width: 0.0, height: 8.0), color: backgroundColor)
        return button
    }
}
