//
//  OrdersController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//


import UIKit
import Firebase

private let reuseIdentifier = "OrderCell"

class OrdersController: UIViewController {
    
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["New Orders", "In progress" , "Done"])
        segmentedControl.selectedSegmentIndex = 0
        let normalTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControl.setTitleTextAttributes(normalTitleTextAttributes, for: .normal)
        let selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)]
        segmentedControl.backgroundColor = .darkGray
        segmentedControl.setTitleTextAttributes(selectedTitleTextAttributes, for: .selected)
        segmentedControl.addTarget(self, action: #selector(handleOrderSectionChanges), for: .valueChanged)
        return segmentedControl
    }()
    
    let refreshController = UIRefreshControl()
    let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        tableView.register(OrderCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.refreshControl = refreshController
        tableView.rowHeight = 150
        return tableView
    }()
    
    private lazy var paddingStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [segmentedControl])
        stackView.layoutMargins = .init(top: 6, left: 12, bottom: 6, right: 12)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [paddingStack, tableView])
        stackView.axis = .vertical
        return stackView
    }()
    
    var newPackageOrder = [Package]()
    var inProcessPackageOrder = [Package]()
    var completedPackageOrder = [Package]()
    lazy var rowsToDisplay = newPackageOrder
    
    var packageDictionary = [String: Package]()
    
    private var viewModel: PackageStatus?
    
    
    
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTrips()
        configureNavBar()
        configureUI()
        configureRefreshController()
        fetchUser()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.dismissPopupBar(animated: true, completion: nil)
        print("DEBUG: user info is \(User.currentUser?.id)")
        print("DEBUG: user info is \(User.currentUser?.username)")
    }
    
    
    @objc func handleOrderSectionChanges(){
        
        switch segmentedControl.selectedSegmentIndex {
        case 0 :
            rowsToDisplay = newPackageOrder
        case 1 :
            rowsToDisplay = inProcessPackageOrder
        default:
            rowsToDisplay = completedPackageOrder
        }
        
        fetchTrips()
        tableView.reloadData()
    }
    
    func fetchUser(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserServices.shared.fetchUser(userId: uid) { [weak self] user in
            self?.user = user
            self?.tableView.reloadData()
        }
    }
    
    func fetchTrips() {
        if User.currentUser?.id == nil { return }
        else {
            DispatchQueue.main.async { [weak self] in
                TripService.shared.fetchMyTrips(userId: User.currentId, packageStatus: pendingPackage) { [weak self]  packages in
                    self?.newPackageOrder = packages
                    self?.newPackageOrder.sort(by: {$0.timestamp! > $1.timestamp!})
                }
                
                TripService.shared.fetchMyTrips(userId: User.currentId, packageStatus: acceptedPackage) { [weak self]  packages in
                    self?.inProcessPackageOrder = packages
                    self?.inProcessPackageOrder.sort(by: {$0.timestamp! > $1.timestamp!})
                }
                
                TripService.shared.fetchMyTrips(userId: User.currentId, packageStatus: completedPackage) { [weak self]  packages in
                    self?.completedPackageOrder = packages
                }
                
            }
            
            tableView.reloadData()
        }
    }
    
    func configureRefreshController(){
        refreshController.tintColor = .white
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:
                                                                [.foregroundColor: UIColor.white])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func configureUI(){
        view.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        view.addSubview(stackView)
        stackView.fillSuperview()
    }
    
    
    func configureNavBar(){
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Orders"
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for order"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            fetchTrips()
            self.refreshController.endRefreshing()
        }
    }
    
}

extension OrdersController: UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! OrderCell
        cell.package = rowsToDisplay[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let package = rowsToDisplay[indexPath.row]
        guard let user = user else { return  }
        let orderDetailsController = OrderDetailsController(package: package, user: user)
        orderDetailsController.delegate = self
        navigationController?.pushViewController(orderDetailsController, animated: true)
    }
}

extension OrdersController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("DEBUG: \(searchController.searchBar.text ?? "" )")
    }
}


extension OrdersController : OrderDetailsControllerDelegate {
    
    func handleDismissalAndRefreshing(_ view: OrderDetailsController) {
        navigationController?.popViewController(animated: true)
        DispatchQueue.main.async { [weak self] in
            self?.tableView.beginUpdates()
            self?.fetchTrips()
            self?.tableView.reloadData()
            self?.tableView.endUpdates()
        }
    }
}

extension OrdersController {
    fileprivate func configureWhenTableIsEmpty(){
        
        
        if newPackageOrder.isEmpty {
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] timer in
                
                self?.tableView.setEmptyView(title: "No Orders",
                                             titleColor: .white,
                                             message: "You don't have any order.\nPeople usually request shipping order when people travel from to city")
            }
        }else if inProcessPackageOrder.isEmpty {
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] timer in
                
                self?.tableView.setEmptyView(title: "No Accepted Orders",
                                             titleColor: .white,
                                             message: "You have not accepted any orders yet\nAccepted orders will be displayed here")
            }
            
        } else  if completedPackageOrder.isEmpty {
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] timer in
                
                self?.tableView.setEmptyView(title: "No Delivered Orders",
                                             titleColor: .white,
                                             message: "You have not delivered any orders yet\nOnce the order is completed , it will be displayed here")
            }
            
        } else {
            tableView.restore()
            tableView.reloadData()
        }
    }
}

