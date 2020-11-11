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
    
    
    // MARK: - Properties
    lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["طلبات جديدة", "طلبات مقبولة" , "طلبات منتهية"])
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
    lazy var searchController = UISearchController(searchResultsController: nil)
    
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
    
    
    
    
    // MARK: - vars
    var newPackageOrder = [Package]()
    var inProcessPackageOrder = [Package]()
    var completedPackageOrder = [Package]()
    lazy var rowsToDisplay = newPackageOrder
    lazy var filteredOrders = [Package]()
    
    var packageDictionary = [String: Package]()
    
    private var viewModel: PackageStatus?
    
    private var user: User?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTrips()
        configureNavBar()
        configureUI()
        configureRefreshController()
        fetchUser()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.dismissPopupBar(animated: true,
                                          completion: nil)
    }
    
    // MARK: - toggleSegment
    func toggleSegment(){
        switch segmentedControl.selectedSegmentIndex {
        case 0 :
            rowsToDisplay = newPackageOrder
        case 1 :
            rowsToDisplay = inProcessPackageOrder
        default:
            rowsToDisplay = completedPackageOrder
        }
        tableView.reloadData()
    }
    
    // MARK: - Action handlers
    @objc func handleOrderSectionChanges(){
        toggleSegment()
        fetchTrips()
    }
    
    // MARK: - fetchUser
    func fetchUser(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserServices.shared.fetchUser(userId: uid) { [weak self] user in
            self?.user = user
            self?.tableView.reloadData()
        }
    }
    
    
    // MARK: - fetchTrips
    func fetchTrips() {
        if User.currentUser?.id == nil { return }
        else {
            DispatchQueue.main.async { [weak self] in
                TripService.shared.fetchMyTrips(userId: User.currentId, packageStatus: pendingPackage) { [weak self]  packages in
                    self?.newPackageOrder = packages
                    self?.newPackageOrder.sort(by: {$0.timestamp! > $1.timestamp!})
                    self?.toggleSegment()
                }
                
                TripService.shared.fetchMyTrips(userId: User.currentId, packageStatus: acceptedPackage) { [weak self]  packages in
                    self?.inProcessPackageOrder = packages
                    self?.inProcessPackageOrder.sort(by: {$0.timestamp! > $1.timestamp!})
                    self?.toggleSegment()
                }
                
                TripService.shared.fetchMyTrips(userId: User.currentId, packageStatus: completedPackage) { [weak self]  packages in
                    self?.completedPackageOrder = packages
                    self?.toggleSegment()
                }
            }
        }
    }
    
    // MARK: - configureRefreshController
    func configureRefreshController(){
        refreshController.tintColor = .white
        refreshController.attributedTitle = NSAttributedString(string: "اسحب للأسفل للتحديث", attributes:
                                                                [.foregroundColor: UIColor.white])
    }
    
    
    // MARK: - configureUI
    func configureUI(){
        view.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        view.addSubview(stackView)
        stackView.fillSuperview()
    }
    
    
    
    // MARK: - configureNavBar
    func configureNavBar(){
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "الطلبات"
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "البحث عن طلب"
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


// MARK:- extension
extension OrdersController: UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] time in
            DispatchQueue.main.async { [weak self] in
                if self!.newPackageOrder.isEmpty {
                    
                    self?.tableView.setEmptyView(title: "لاتوجد طلبات جديدة",
                                                 titleColor: .white,
                                                 message: "")
                } else {
                    tableView.restore()
                }
            }
            
        }
        
        return searchController.isActive ? filteredOrders.count : rowsToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! OrderCell
        cell.package = searchController.isActive ? filteredOrders[indexPath.row] : rowsToDisplay[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let package = searchController.isActive ? filteredOrders[indexPath.row] : rowsToDisplay[indexPath.row]
        guard let user = user else { return  }
        let orderDetailsController = OrderDetailsController(package: package, user: user)
        orderDetailsController.delegate = self
        navigationController?.pushViewController(orderDetailsController, animated: true)
    }
}

// MARK: UISearchResultsUpdating
extension OrdersController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchedText = searchController.searchBar.text else { return }
        
        filteredOrders = rowsToDisplay.filter({ (package) -> Bool in
            return package.packageType.lowercased().contains(searchedText.lowercased())
        })
        
        tableView.reloadData()
        
    }
}


//MARK:OrderDetailsControllerDelegate
extension OrdersController : OrderDetailsControllerDelegate {
    func handleRefreshTableAfterAction() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.beginUpdates()
            self?.fetchTrips()
            self?.tableView.reloadData()
            self?.tableView.endUpdates()
        }
    }
    
    
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


