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
    var filteredPackages = [Package]()
    private var user: User?
    
    lazy var searchController = UISearchController(searchResultsController: nil)
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        fetchMyRequest()
        fetchUser()
        configureRefreshController()
        configureNavBar()
    }
    
    fileprivate func configureNavBar(){
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for package"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserServices.shared.fetchUser(userId: uid) { [weak self] user in
            self?.user = user
            self?.tableView.reloadData()
        }
    }
    
    
    // MARK: - fetchMyRequest
    func fetchMyRequest(){
        guard let uid = Auth.auth().currentUser?.uid else { return  }
        TripService.shared.fetchMyRequest(userId: uid ) { [weak self] packages in
            DispatchQueue.main.async { [weak self] in
                self?.packages = packages
                self?.tableView.reloadData()
            }
        }
    }
    
    
    
    // MARK: - configureTableView
    fileprivate func configureTableView(){
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 150
        tableView.tableFooterView = UIView()
        title = "التنبيهات"
        tableView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] time in
            DispatchQueue.main.async { [weak self] in
                if self!.packages.isEmpty {
                    self?.tableView.setEmptyView(title: "لاتوجد تنبيهات",
                                                 titleColor: .white,
                                                 message: "سيتم تنبيهك في حال المسافر قبل الطلب او رفض")
                } else {
                    tableView.restore()
                }
            }
            
        }
        
        return searchController.isActive ? filteredPackages.count : packages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.package = searchController.isActive ? filteredPackages[indexPath.row] : packages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPackage = searchController.isActive ? filteredPackages[indexPath.row] : packages[indexPath.row]
        guard let user = user else { return  }
        let notificationsDetailsController = NotificationsDetailsController(package: selectedPackage, user: user)
        notificationsDetailsController.delegate = self
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

// MARK: - UISearchResultsUpdating
extension NotificationsController :  UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchedText = searchController.searchBar.text else { return }
        filteredPackages = packages.filter({ package -> Bool in
            return package.packageType.lowercased().contains(searchedText.lowercased())
        })
        tableView.reloadData()
    }
}

extension NotificationsController : NotificationsDetailsControllerDelegate {
    func handleDismissalAndRefreshAfterDeleting() {
        DispatchQueue.main.async { [weak self] in
            self?.fetchMyRequest()
            self?.tableView.reloadData()
        }
    }
}
