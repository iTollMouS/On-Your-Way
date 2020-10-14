//
//  OrderDetailsController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/13/20.
//

import UIKit
import SwiftEntryKit
import Lottie

private let reuseIdentifier = "OrderDetail"

class OrderDetailsController: UIViewController {
    
    
    private var package: Package
    
    
//    failed
    
    private lazy var headerView = OrderDetailHeader(package: package)
    private lazy var footerView = OrderDetailsFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 250))
    
    private lazy var customAlertView = UIView()
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
    
    private lazy var animationView : AnimationView = {
        let animationView = AnimationView()
        animationView.setDimensions(height: 100, width: 100)
        animationView.clipsToBounds = true
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
        footerView.delegate = self
        
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

extension OrderDetailsController: OrderDetailsFooterViewDelegate {
    func assignPackageStatus(_ sender: UIButton) {
        
        switch sender.tag {
        // reject
        case 0:
            showCustomAlertView()
        //            let alert = UIAlertController(title: nil, message: "Are you sure you want delete this order ?", preferredStyle: .actionSheet)
        //            alert.addAction(UIAlertAction(title: "Reject order", style: .destructive, handler: { [weak self] (alertAction) in
        //                TripService.shared.rejectPackageOrderWith(userId: User.currentId, packageId: self!.package.packageID) { [weak self] error in
        //                    self?.showCustomAlertView()
        //                }
        //            }))
        //            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        //            present(alert, animated: true, completion: nil)
        
        //accept
        case 1:
            print("")
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
        customAlertView.setDimensions(height: 300, width: view.frame.width - 50)
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
        attributes.entryInteraction = .dismiss // do something when the user touch the screen e.g .dismiss make the card dismisses on touch
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.statusBar = .light
        
        attributes.lifecycleEvents.willDisappear = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        attributes.entryBackground = .visualEffect(style: .dark)
        SwiftEntryKit.display(entry: customAlertView, using: attributes)
    }
    
    func configureCustomAlertViewUI(){
        customAlertView.addSubview(animationView)
        animationView.centerX(inView: customAlertView, topAnchor: customAlertView.topAnchor)
    }
}
