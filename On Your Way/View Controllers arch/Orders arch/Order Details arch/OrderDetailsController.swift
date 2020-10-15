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
    
    
    private var package: Package
    
    
    //    failed
    
    private lazy var headerView = OrderDetailHeader(package: package)
    private lazy var footerView = OrderDetailsFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 250))
    
    private var viewModel: PackageStatus?
    private var images = [SKPhoto]()
    
    private lazy var customAlertView = UIView()
    private lazy var dismissalLabel: UILabel = {
        let label = UILabel()
        label.text = "Okay"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        label.clipsToBounds = true
        label.setDimensions(height: 50, width: 200)
        label.layer.cornerRadius = 50 / 2
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
    
    
    init(package: Package) {
        self.package = package
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
                
                footer.acceptButton.setTitle("You accepted the order in \(Date().convertDate(formattedString: .formattedType2))", for: .normal)
                footer.rejectButton.isEnabled = false
                self?.package.packageStatus = .packageIsAccepted
                TripService.shared.updatePackageStatus(userId: User.currentId, package: self!.package) { [weak self] error in
                    self?.showCustomAlertView()
                }
                
            }))
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        // chat
        case 2:
            print("")
            
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
        attributes.entryInteraction = .dismiss
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.statusBar = .light
        
        attributes.lifecycleEvents.willDisappear = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        SwiftEntryKit.display(entry: customAlertView, using: attributes)
    }
    
    
    func configureCustomAlertViewUI(){
        customAlertView.addSubview(animationView)
        customAlertView.bringSubviewToFront(animationView)
        animationView.centerX(inView: customAlertView, topAnchor: customAlertView.topAnchor, paddingTop: 0)
        animationView.play()
        animationView.loopMode = .loop
        customAlertView.addSubview(dismissalLabel)
        dismissalLabel.centerX(inView: animationView, topAnchor: animationView.bottomAnchor)
    }
}
//
//                #warning("Make sure to have an ability ti delete it after 24 hours.")
//
//
//                self?.package.packageStatusTimestamp = (Date() + 86400).convertDate(formattedString: .formattedType2)
//                footer.rejectButton.setTitle("Your order will be deleted in \(self?.package.packageStatusTimestamp ?? Date().convertDate(formattedString: .formattedType2))", for: .normal)
//                footer.rejectButton.isEnabled = false
//                self?.package.packageStatus = .packageIsRejected
//                TripService.shared.updatePackageStatus(userId: User.currentId, package: self!.package) { error in
//                    print("DEBUG:: success updating pachage ")
//                }
//                TripService.shared.updatePackageStatus(userId: User.currentId, package: self!.package) { error in
//                    print("DEBUG:: success updating pachage ")
//                }
