//
//  NotificationsController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/14/20.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationsController: UITableViewController {
    
    let refreshController = UIRefreshControl()
    var packagesDictionary = [String : Package]()
    var packages = [Package]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        fetchMyRequest()
        configureRefreshController()
    }
    
    func configureRefreshController(){
        refreshController.tintColor = .white
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:
                                                                [.foregroundColor: UIColor.white])
        tableView.refreshControl = refreshController
    }
    
    fileprivate func fetchMyRequest(){
        TripService.shared.fetchMyRequest(userId: User.currentId) { packages in
            
            packages.forEach { package in
                let tempPackage = package
                self.packagesDictionary[tempPackage.packageID] = package
            }

            self.packages = Array(self.packagesDictionary.values)
            self.tableView.reloadData()
        }
    }
    
    fileprivate func configureTableView(){
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 150
        title = "Notifications"
        tableView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.package = packages[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            fetchMyRequest()
            self.refreshController.endRefreshing()
        }
    }
}
