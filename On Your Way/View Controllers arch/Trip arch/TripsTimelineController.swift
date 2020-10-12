//
//  TripsTimelineController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit
import Firebase
import LNPopupController

private let reuseIdentifier = "TripCell"

class TripsTimelineController: UITableViewController {
    
    
    let searchController = UISearchController(searchResultsController: nil)
    let refreshController = UIRefreshControl()
    
    
    
    var user: User?
    var trips: [Trip] = []
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureRefreshController()
        checkIfUserLoggedIn()
        fetchTrips()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureTapBarController()
        configureNavBar()
        searchController.searchBar.becomeFirstResponder()
    }
    
    func fetchTrips(){
        TripService.shared.fetchAllTrips { [weak self] in
            self?.trips = $0
            self?.tableView.reloadData()
            
        }
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
        tableView.rowHeight = 220
        tableView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        tableView.tableHeaderView = UIView()
        
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
        DispatchQueue.main.async { [weak self]  in
            let loginController = LoginController()
            loginController.delegate = self
            let nav = UINavigationController(rootViewController: loginController)
            nav.modalPresentationStyle = .fullScreen
            self?.present(nav, animated: true, completion: nil)
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            fetchTrips()
            refreshController.endRefreshing()
        }
        
    }
    
}

// MARK: - Extensions


// MARK: - UITableViewDataSource, UITableViewDelegate
extension TripsTimelineController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TripCell
        cell.trip = trips[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteMyTrip(trip: trips[indexPath.row])
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = editMyTrip(at: indexPath)
        return UISwipeActionsConfiguration(actions: [edit])
    }
    
    func deleteMyTrip(trip: Trip) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
            TripService.shared.deleteMyTrip(trip: trip) { error in
                if let error = error {
                    self.showAlertMessage("Error", "error with \(error.localizedDescription)")
                }
                return
            }
            self.fetchTrips()
            self.tableView.reloadData()
        }
        action.image = UIImage(systemName: "trash.circle.fill")
        action.backgroundColor = .systemRed
        return action
    }
    
    
    func editMyTrip(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            //            self.myTrips.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
        }
        action.image = #imageLiteral(resourceName: "RatingStarEmpty")
        action.backgroundColor = .blueLightFont
        return action
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 50, 0)
        cell.layer.transform = rotationTransform
        cell.alpha = 0
        UIView.animate(withDuration: 0.70) {
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1
        }
    }
    
}
// MARK: -  NewTripControllerDelegate
extension TripsTimelineController: NewTripControllerDelegate {
    func dismissNewTripView(_ view: NewTripController) {
        fetchTrips()
        tabBarController?.closePopup(animated: true, completion: { [weak self] in
            let safetyControllerGuidelines = SafetyControllerGuidelines()
            safetyControllerGuidelines.modalPresentationStyle = .custom
            self?.present(safetyControllerGuidelines, animated: true, completion: nil)
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

