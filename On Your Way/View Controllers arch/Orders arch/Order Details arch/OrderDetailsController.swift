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

private let reuseIdentifier = "OrderDetail"

class OrderDetailsController: UIViewController {
    
    
    
    
    
    //    failed
    
    private lazy var headerView = OrderDetailHeader(package: package)
    private lazy var footerView = OrderDetailsFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 250))
    
    private var viewModel: PackageStatus?
    private var images = [SKPhoto]()
    
    private lazy var customAlertView = UIView()
    
    private lazy var rejectButton = createButton(tagNumber: 0, title: "Reject Order\nThis order will be removed",
                                                 backgroundColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), colorAlpa: 0.6, systemName: "checkmark.circle.fill")
    
    private lazy var acceptButton = createButton(tagNumber: 1, title: "Accept", backgroundColor: #colorLiteral(red: 0.1803921569, green: 0.5215686275, blue: 0.431372549, alpha: 1), colorAlpa: 0.6, systemName: "checkmark.circle.fill")
    private lazy var startChatButton = createButton(tagNumber: 2, title: "Chat", backgroundColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1), colorAlpa: 0.4, systemName: "bubble.left.and.bubble.right.fill")
    
    
    private lazy var dismissalLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        label.clipsToBounds = true
        label.setDimensions(height: 50, width: 200)
        label.layer.cornerRadius = 50 / 2
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(handleViewDismissal)))
        return label
    }()
    var attributes = EKAttributes.bottomNote
    
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
        animationView.setDimensions(height: 200, width: 200)
        animationView.clipsToBounds = true
        animationView.backgroundColor = .clear
        animationView.contentMode = .scaleAspectFill
        animationView.animation = Animation.named("success_animation")
        return animationView
    }()
    
    private var package: Package
    private var user: User
    
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
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
    }
    
    @objc fileprivate func handleViewDismissal(_ sender: UIButton){
        switch sender.tag {
        case 0:
            SwiftEntryKit.dismiss(.displayed) { [weak self] in self!.navigationController?.popViewController(animated: true) }
        case 1:
            SwiftEntryKit.dismiss(.displayed)
        default: break
        }
        
    }
}

extension OrderDetailsController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = .green
        return cell
    }
    
    
}

extension OrderDetailsController : OrderDetailHeaderDelegate {
    func handleShowImages(_ package: Package) {
        
        package.packageImages.forEach {
            FileStorage.downloadImage(imageUrl: $0) { [weak self] image in
                guard let image = image else {return}
                let photo = SKPhoto.photoWithImage(image)
                self?.images.append(photo)
                let browser = SKPhotoBrowser(photos: self!.images)
                browser.initializePageIndex(0)
                self?.present(browser, animated: true, completion: nil)
            }
        }
        images.removeAll()
    }
}

extension OrderDetailsController: OrderDetailsFooterViewDelegate {
    func assignPackageStatus(_ sender: UIButton, _ footer: OrderDetailsFooterView) {
        
        switch sender.tag {
        // reject
        case 0:
            let alert = UIAlertController(title: nil, message: "Are you sure you want delete this order ?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Reject order", style: .destructive, handler: { [weak self] (alertAction) in
                TripService.shared.updatePackageStatus(userId: User.currentId, package: self!.package) { [weak self] error in
                    self?.showCustomAlertView()
                    
                }
            }
            
            ))
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
        //accept
        case 1:
            let alert = UIAlertController(title: nil, message: "Are you sure you want accept this order ?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Accept order", style: .default, handler: { [weak self] (alertAction) in
                self?.showCustomAlertView()
            }))
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        // chat
        case 2:
            
            UserServices.shared.fetchUser(userId: package.userID) { [weak self] packageOwner in
                let chatId = startChat(currentUser: packageOwner, selectedUser: self!.user)
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
    
    func showCustomAlertView() {
        configureCustomAlertViewUI()
        view.isUserInteractionEnabled = false
        customAlertView.layer.cornerRadius = 50
        customAlertView.clipsToBounds = true
        customAlertView.backgroundColor = .clear
        customAlertView.setDimensions(height: 300, width: view.frame.width - 50)
        attributes.screenBackground = .visualEffect(style: .dark)
        attributes.positionConstraints.safeArea = .overridden
        attributes.positionConstraints.verticalOffset = 250
        attributes.windowLevel = .normal
        attributes.position = .bottom
        attributes.precedence = .override(priority: .max, dropEnqueuedEntries: false)
        attributes.displayDuration = .infinity
        //        attributes.entryInteraction = .dismiss
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
        attributes.statusBar = .light
        SwiftEntryKit.display(entry: customAlertView, using: attributes)
    }
    
    
    func configureCustomAlertViewUI(){
        customAlertView.addSubview(animationView)
        customAlertView.bringSubviewToFront(animationView)
        animationView.centerX(inView: customAlertView, topAnchor: customAlertView.topAnchor, paddingTop: 0)
        animationView.play()
        animationView.loopMode = .loop
        customAlertView.addSubview(rejectButton)
        rejectButton.centerX(inView: animationView, topAnchor: animationView.bottomAnchor)
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


