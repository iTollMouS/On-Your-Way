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
    
    // MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    let refreshController = UIRefreshControl()
    
    var trips: [Trip] = []
    var filteredTrips: [Trip] = []
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureRefreshController()
        fetchTrips()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureTapBarController()
        fetchTrips()
        configureNavBar()
        searchController.searchBar.becomeFirstResponder()
        
    }
    
    
    var darkMode = false
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return darkMode ? .lightContent : .lightContent
    }
    
    
    func shouldShowOnboarding(){
        
        //        if !isAppAlreadyLaunchedOnce() {/* show onboarding in first launch*/}
        
        let onboardingController = OnboardingController()
        onboardingController.modalPresentationStyle = .custom
        self.present(onboardingController, animated: true, completion: nil)
    }
    
    // MARK: - fetchTrips()
    func fetchTrips(){
        TripService.shared.fetchAllTrips { [weak self] trips in
            /*note that in the func we made some omitting duplicate methods
             best way to handle empty cases
             */
            self?.trips = trips
            DispatchQueue.main.async {
                self?.configureWhenTableIsEmpty()
                self?.configureTapBarController()
                self?.tableView.reloadData()
            }
            
            
        }
    }
    
    
    // MARK: - configureTapBarController()
    func configureTapBarController(){
        tabBarController?.tabBar.isHidden = false
        let newTripController = NewTripController()
        newTripController.delegate = self
        newTripController.popupItem.title = "Design your trip"
        newTripController.popupBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        newTripController.popupItem.subtitle = "show people what packages you can take"
        newTripController.popupItem.progress = 0.34
        tabBarController?.popupBar.titleTextAttributes = [ .foregroundColor: UIColor.white ]
        tabBarController?.popupBar.subtitleTextAttributes = [ .foregroundColor: UIColor.gray ]
        tabBarController?.presentPopupBar(withContentViewController: newTripController, animated: true, completion: nil)
    }
    
    
    // MARK: - configureRefreshController()
    func configureRefreshController(){
        refreshController.tintColor = .white
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:
                                                                [.foregroundColor: UIColor.white])
        tableView.refreshControl = refreshController
    }
    
    // MARK: - configureUI()
    func configureUI(){
        
        tableView.register(TripCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 250
        tableView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        tableView.tableHeaderView = UIView()
        
    }
    
    
    // MARK: - configureNavBar()
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
    
    
    // MARK: - presentLoggingController()
    func presentLoggingController(){
        DispatchQueue.main.async { [weak self]  in
            let loginController = LoginController()
            loginController.delegate = self
            let nav = UINavigationController(rootViewController: loginController)
            nav.modalPresentationStyle = .fullScreen
            self?.present(nav, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - fetch when scroll
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            configureTapBarController()
            fetchTrips()
            refreshController.endRefreshing()
        }
        
    }
    
}

// MARK: - Extensions





// MARK: - table extensions
extension TripsTimelineController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredTrips.count : trips.count
    }
    
    // MARK: - cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TripCell
        cell.trip = searchController.isActive ? filteredTrips[indexPath.row] : trips[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    
    
    // MARK: - didSelectRowAt
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let trip = searchController.isActive ? filteredTrips[indexPath.row] : trips[indexPath.row]
        UserServices.shared.fetchUser(userId: trip.userID) { [weak self] user in
            let tripDetailsController = TripDetailsController(user: user, trip: trip)
            tripDetailsController.delegate = self
            self?.navigationController?.pushViewController(tripDetailsController, animated: true)
        }
        
    }
    
    // MARK: - Delete row
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let trip = searchController.isActive ? filteredTrips[indexPath.row] : trips[indexPath.row]
            TripService.shared.deleteMyTrip(trip: trip) { [weak self] error in
                DispatchQueue.main.async {
                    self!.searchController.isActive ? self?.filteredTrips.remove(at: indexPath.row) : self?.trips.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self?.tableView.reloadData()
                }
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    // MARK: - allow current user edit trip
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return trips[indexPath.row].userID == User.currentId ? true : false
    }
    
}

// MARK: -  TripCellDelegate
extension TripsTimelineController: TripCellDelegate {
    func handleDisplayReviews(_ cell: UITableViewCell, selectedTrip: Trip) {
        
        UserServices.shared.fetchUser(userId: selectedTrip.userID) { [weak self] user in
            let peopleReviewsController = PeopleReviewsController(user: user)
            self?.navigationController?.pushViewController(peopleReviewsController, animated: true)
        }
        
    }
    
}

// MARK: -  NewTripControllerDelegate
extension TripsTimelineController: NewTripControllerDelegate {
    func dismissLoggingAnonymousOut(_ view: NewTripController) {
        DispatchQueue.main.async { [weak self] in
            self?.tabBarController?.closePopup(animated: true, completion: { [weak self] in
                self?.presentLoggingController()
            })
        }
    }
    
    func dismissNewTripView(_ view: NewTripController) {
        DispatchQueue.main.async { [weak self] in
            self?.fetchTrips()
            self?.tabBarController?.closePopup(animated: true, completion: { [weak self] in
                let safetyControllerGuidelines = SafetyControllerGuidelines()
                safetyControllerGuidelines.modalPresentationStyle = .custom
                self?.present(safetyControllerGuidelines, animated: true, completion: nil)
            })
        }
    }
}

// MARK: - LoginControllerDelegate
extension TripsTimelineController: LoginControllerDelegate {
    func handleLoggingControllerDismissal(_ view: LoginController) {
        view.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UISearchResultsUpdating
extension TripsTimelineController :  UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchedText = searchController.searchBar.text else { return }
        
        filteredTrips = trips.filter({ (trip) -> Bool in
            return trip.destinationLocation.lowercased().contains(searchedText.lowercased())
                || trip.currentLocation.lowercased().contains(searchedText.lowercased())
                || trip.basePrice.lowercased().contains(searchedText.lowercased())
        })
        
        tableView.reloadData()
        
    }
}




// MARK: - TripDetailsControllerDelegate
extension TripsTimelineController : TripDetailsControllerDelegate {
    func handleShowRegistrationPageForNonusers(_ view: TripDetailsController) {
        navigationController?.popViewController(animated: true)
        presentLoggingController()
    }
}



extension TripsTimelineController {
    fileprivate func configureWhenTableIsEmpty(){
        if trips.isEmpty {
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] timer in
                
                self?.tableView.setEmptyView(title: "No travelers",
                                             titleColor: .white,
                                             message: "No on has announce that they will travel from to city. Once people announce their travel info, you can ship your package with them\nYou can announce your travel details in\n'Design Your Trip' down below ",
                                             paddingTop: 100)
            }
        } else {tableView.restore()}
        
    }
}



/*
 override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
 let delete = deleteMyTrip(at: indexPath)
 return UISwipeActionsConfiguration(actions: [delete])
 }
 
 override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
 let edit = editMyTrip(at: indexPath)
 return UISwipeActionsConfiguration(actions: [edit])
 }
 
 
 // MARK: - deleteMyTrip
 func deleteMyTrip(at indexPath: IndexPath) -> UIContextualAction {
 let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
 TripService.shared.deleteMyTrip(trip: trip) { error in
 if let error = error {
 self.showAlertMessage("Error", "error with \(error.localizedDescription)")
 return
 }
 self.fetchTrips()
 self.tableView.reloadData()
 }
 }
 
 action.image = UIImage(systemName: "trash.circle.fill")
 action.backgroundColor = .systemRed
 return action
 }
 
 // MARK: - editMyTrip
 func editMyTrip(at indexPath: IndexPath) -> UIContextualAction {
 let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
 //            self.myTrips.remove(at: indexPath.row)
 self.tableView.deleteRows(at: [indexPath], with: .automatic)
 self.tableView.reloadData()
 }
 action.image = #imageLiteral(resourceName: "RatingStarEmpty")
 action.backgroundColor = .blueLightFont
 return action
 }*/
