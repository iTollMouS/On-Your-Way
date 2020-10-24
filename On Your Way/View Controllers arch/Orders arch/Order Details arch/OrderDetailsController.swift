//
//  OrderDetailsController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/13/20.
//

import UIKit
import SwiftEntryKit
import Lottie
import SKPhotoBrowser

private let reuseIdentifier = "OrderDetailsCell"

protocol OrderDetailsControllerDelegate: class {
    func handleDismissalAndRefreshing(_ view: OrderDetailsController)
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
        button.addTarget(self, action: #selector(handleViewDismissal), for: .touchUpInside)
        button.layer.cornerRadius = 50 / 2
        button.backgroundColor = #colorLiteral(red: 0.3450980392, green: 0.3450980392, blue: 0.3450980392, alpha: 1)
        return button
    }()
    
    
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
    
    private lazy var animationView: AnimationView = {
        let animationView = AnimationView()
        animationView.setDimensions(height: 100, width: 100)
        animationView.clipsToBounds = true
        animationView.backgroundColor = .clear
        animationView.contentMode = .scaleAspectFill
        animationView.animation = Animation.named("success_animation")
        return animationView
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
                TripService.shared.updatePackageStatus(userId: User.currentId, package: self!.package) { [weak self] error in
                    PushNotificationService.shared.sendPushNotification(userIds: [self!.package.userID],
                                                                        body: "\(self!.user.username) has rejected your order ",
                                                                        title: "Reject order")
                    self?.showCustomAlertView(condition: .warning)
                }
            }
            
            ))
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
        //accept
        case 1:
            self.package.packageStatus = .packageIsAccepted
            self.package.packageStatusTimestamp = Date().convertDate(formattedString: .formattedType2)
            let alert = UIAlertController(title: nil, message: "Are you sure you want accept this order ?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Accept order", style: .default, handler: { [weak self] (alertAction) in
                TripService.shared.updatePackageStatus(userId: User.currentId, package: self!.package) { [weak self] error in
                    PushNotificationService.shared.sendPushNotification(userIds: [self!.package.userID],
                                                                        body: "\(self!.user.username) just accepted your order 📦 🤩 you can now chat with her",
                                                                        title: "Accepted order")
                    self?.showCustomAlertView(condition: .success)
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

extension OrderDetailsController {
    
    func showCustomAlertView(condition: Conditions) {
        configureCustomAlertUI()
        
        switch condition {
        case .success:
            dismissalButton.tag = 1
            animationView.animation = Animation.named(condition.JSONStringName)
            animationView.play()
            animationView.loopMode = .repeat(5)
            let attributedText = NSMutableAttributedString(string: "Success!\n",
                                                           attributes: [.foregroundColor : #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1),
                                                                        .font: UIFont.boldSystemFont(ofSize: 18)])
            attributedText.append(NSMutableAttributedString(string: "You can now chat with your customer and arrange place and time for \npicking up package",
                                                            attributes: [.foregroundColor : UIColor.lightGray,
                                                                         .font: UIFont.systemFont(ofSize: 16)]))
            messageLabel.attributedText = attributedText
        case .warning:
            dismissalButton.tag = 0
            animationView.animation = Animation.named(condition.JSONStringName)
            animationView.play()
            animationView.loopMode = .repeat(5)
            
            let attributedText = NSMutableAttributedString(string: "Warning!\n",
                                                           attributes: [.foregroundColor : #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1),
                                                                        .font: UIFont.boldSystemFont(ofSize: 18)])
            attributedText.append(NSMutableAttributedString(string: "Please note that you can not undo this action\nif you have chatted before , you can still ask them to resubmit order ",
                                                            attributes: [.foregroundColor : UIColor.lightGray,
                                                                         .font: UIFont.systemFont(ofSize: 16)]))
            
            messageLabel.attributedText = attributedText
        case .error:
            animationView.animation = Animation.named(condition.JSONStringName)
            animationView.play()
            animationView.loopMode = .repeat(5)
        }
        
        
    }
    
    func configureCustomAlertUI(){
        customAlertView.clipsToBounds = true
        customAlertView.addSubview(bottomContainerView)
        customAlertView.addSubview(animationView)
        
        animationView.centerX(inView: customAlertView, topAnchor: customAlertView.topAnchor, paddingTop: 0)
        bottomContainerView.anchor(top: animationView.bottomAnchor, left: customAlertView.leftAnchor, bottom: customAlertView.bottomAnchor, right: customAlertView.rightAnchor, paddingTop: -50)
        
        bottomContainerView.addSubview(messageLabel)
        messageLabel.anchor(top: bottomContainerView.topAnchor, left: bottomContainerView.leftAnchor,
                            right: bottomContainerView.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingRight: 20)
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
