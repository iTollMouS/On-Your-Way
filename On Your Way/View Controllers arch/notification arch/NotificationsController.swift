//
//  NotificationsController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/14/20.
//

import UIKit
import Firebase

private let reuseIdentifier = "NotificationCell"

class NotificationsController: UITableViewController {
    
    
    // MARK: - Properties
    let refreshController = UIRefreshControl()
    var packages = [Package]()
    private var user: User?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        fetchMyRequest()
        fetchUser()
        configureRefreshController()
    }
    
    var darkMode = false
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return darkMode ? .lightContent : .lightContent
    }
    
    // MARK: - configureRefreshController
    func configureRefreshController(){
        refreshController.tintColor = .white
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:
                                                                [.foregroundColor: UIColor.white])
        tableView.refreshControl = refreshController
    }
    
    
    func fetchUser(){
        UserServices.shared.fetchUser(userId: User.currentId) { [weak self] user in
            self?.user = user
        }
    }
    
    
    // MARK: - fetchMyRequest
    func fetchMyRequest(){
        guard let uid = Auth.auth().currentUser?.uid else { return  }
        TripService.shared.fetchMyRequest(userId: uid ) { [weak self] packages in
            self?.packages = packages
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    
    
    // MARK: - configureTableView
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPackage = packages[indexPath.row]
        guard let user = user else { return  }
        let notificationsDetailsController = NotificationsDetailsController(package: selectedPackage, user: user)
        navigationController?.pushViewController(notificationsDetailsController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let selectedPackage = packages[indexPath.row]
            TripService.shared.fetchTrip(tripId: selectedPackage.tripID) { [weak self] trip in
                self?.packages.remove(at: indexPath.row)
                TripService.shared.deleteMyOutgoingPackage(trip: trip, userId: selectedPackage.userID, package: selectedPackage) { [weak self] error in
                    self?.fetchMyRequest()
                }
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.beginUpdates()
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self?.tableView.endUpdates()
                }
            }
            tableView.reloadData()
        }
        
    }
    
    
    // MARK: - scrollViewDidEndDecelerating
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            fetchMyRequest()
            self.refreshController.endRefreshing()
        }
    }
}
