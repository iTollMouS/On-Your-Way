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
    
    init(package: Package){
        self.package = package
        super.init(style: .insetGrouped)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    
    
    var darkMode = false
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return darkMode ? .lightContent : .lightContent
    }
    
    
    // MARK: - configureTableView
    fileprivate func configureTableView(){
        tableView.register(NotificationsDetailsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = 60
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
    
    
    // MARK: - cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationsDetailsCell
        cell.package = package
        return cell
    }
    
    // MARK: - header View in section
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Package description"
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
