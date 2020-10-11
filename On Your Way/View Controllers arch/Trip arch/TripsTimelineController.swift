//
//  TripsTimelineController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit
import Firebase

private let reuseIdentifier = "TripCell"

class TripsTimelineController: UITableViewController {
    
    
    let searchController = UISearchController(searchResultsController: nil)
    let refreshController = UIRefreshControl()
    
    
    var user: User?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureRefreshController()
        checkIfUserLoggedIn()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureTapBarController()
        configureNavBar()
        
    }
    
    
    func configureTapBarController(){
        let newTripController = NewTripController()
        newTripController.delegate = self
        newTripController.user = user
        newTripController.popupItem.title = "Design your trip"
        newTripController.popupBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        newTripController.popupItem.subtitle = "show people what packages you can take"
        newTripController.popupItem.progress = 0.34
        tabBarController?.popupBar.titleTextAttributes = [ .foregroundColor: UIColor.white ]
        tabBarController?.popupBar.subtitleTextAttributes = [ .foregroundColor: UIColor.gray ]
        tabBarController?.presentPopupBar(withContentViewController: newTripController, animated: true, completion: nil)
    }
    
    
    func configureRefreshController(){
        refreshController.tintColor = .white
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:
                                                                [.foregroundColor: UIColor.white])
        tableView.refreshControl = refreshController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    func configureUI(){
        
        tableView.register(TripCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 150
        tableView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        
    }
    
    func configureNavBar(){
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Trips"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for trip"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    
    func checkIfUserLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            presentLoggingController()
        }  else {
            self.user = User.currentUser
            self.tableView.reloadData()
        }
    }
    
    func presentLoggingController(){
        DispatchQueue.main.async { [self] in
            let loginController = LoginController()
            loginController.delegate = self
            let nav = UINavigationController(rootViewController: loginController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        refreshController.isRefreshing ? refreshController.endRefreshing() : refreshController.beginRefreshing()
    
    }
    
}

// MARK: - Extensions


// MARK: - UITableViewDataSource, UITableViewDelegate
extension TripsTimelineController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TripCell
         
        return cell
    }
    
}
// MARK: -  NewTripControllerDelegate
extension TripsTimelineController: NewTripControllerDelegate {
    func dismissNewTripView(_ view: NewTripController) {
        tabBarController?.closePopup(animated: true, completion: { [self] in
            let safetyControllerGuidelines = SafetyControllerGuidelines()
            safetyControllerGuidelines.modalPresentationStyle = .custom
            present(safetyControllerGuidelines, animated: true, completion: nil)
        })
    }
}

// MARK: - LoginControllerDelegate
extension TripsTimelineController: LoginControllerDelegate {
    func handleLoggingControllerDismissal(_ view: LoginController) {
        view.dismiss(animated: true, completion: nil)
    }
}

extension TripsTimelineController :  UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("DEBUG: \(searchController.searchBar.text ?? "" )")
    }
}

