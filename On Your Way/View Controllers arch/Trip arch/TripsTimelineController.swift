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
    lazy var searchController = UISearchController(searchResultsController: nil)
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
    
    // MARK: - fetchTrips()
    func fetchTrips(){
        if !isConnectedToNetwork(){
            CustomAlertMessage(condition: .warning, messageTitle: "انقطاع في الاتصال",
                               messageBody: "الرجاء التاكد من الاتصال للشبكة",
                               size: CGSize(width: view.frame.width - 50, height: 280)) {
            }
            return
        }
        DispatchQueue.main.async {
            TripService.shared.fetchAllTrips { [weak self] trips in
                /*note that in the func we made some omitting duplicate methods
                 best way to handle empty cases
                 */
                
                self?.trips = trips
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
        newTripController.popupItem.title = "مسافر؟"
        newTripController.popupBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        newTripController.popupItem.subtitle = "اضغط هنا لإعلام العملاء برحلتك لزيادة دخلك الشهري"
        //        newTripController.popupBar.barItemsSemanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight ? .forceRightToLeft : .forceRightToLeft
        //        newTripController.popupBar.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight ? .forceRightToLeft : .forceRightToLeft
        //        tabBarController?.popupBar.barItemsSemanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight ? .forceRightToLeft : .forceRightToLeft
        //        tabBarController?.popupBar.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight ? .forceRightToLeft : .forceRightToLeft
        tabBarController?.popupBar.titleTextAttributes = [ .foregroundColor: UIColor.white ]
        tabBarController?.popupBar.subtitleTextAttributes = [ .foregroundColor: UIColor.gray ]
        tabBarController?.presentPopupBar(withContentViewController: newTripController, animated: true, completion: nil)
        
    }
    
    
    // MARK: - configureRefreshController()
    func configureRefreshController(){
        refreshController.tintColor = .white
        refreshController.attributedTitle = NSAttributedString(string: "اسحب للأسفل للتحديث", attributes:
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
        self.title = "المسافرون"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "ابحث عن مسافر لمنطقة: القصيم ، الرياض.."
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
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] time in
            DispatchQueue.main.async { [weak self] in
                if self!.trips.isEmpty {
                    self?.tableView.setEmptyView(title: "لايوجد مسافرون",
                                                 titleColor: .white,
                                                 message: "اذا كنت مسافر ، اضغط في الاسفل لإعلام الناس بسفرك لزيادة دخلك الشهري")
                } else { tableView.restore() }
            }
        }
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
        let tripDetailsController = TripDetailsController(trip: trip)
        tripDetailsController.delegate = self
        navigationController?.pushViewController(tripDetailsController, animated: true)
        print("DEBUG: id trip is \(trips[indexPath.row].tripID)")
    }
    
    // MARK: - Delete row
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let trip = searchController.isActive ? filteredTrips[indexPath.row] : trips[indexPath.row]
            DispatchQueue.main.async {
                TripService.shared.deleteMyTrip(trip: trip) { [weak self] error in
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
        return trips[indexPath.row].userID == User.currentId
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
        DispatchQueue.main.async { [weak self] in
            view.dismiss(animated: true) { [weak self] in
                if !self!.isAppAlreadyLaunchedOnce(){
                    let onboardingController = OnboardingController()
                    onboardingController.modalPresentationStyle = .custom
                    self!.present(onboardingController, animated: true) { [weak self] in
                        self?.fetchTrips()
                    }
                }
            }
        }
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
