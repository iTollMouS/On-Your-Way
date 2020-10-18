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
    var donePackageOrder = [Package]()
    var packagesDictionary: [String: Package] = [:]
    
    private var viewModel: PackageStatus?
    
    lazy var rowsToDisplay = newPackageOrder
    
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureUI()
        configureRefreshController()
        fetchTrips()
        fetchUser()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.dismissPopupBar(animated: true, completion: nil)
    }
    
    
    @objc func handleOrderSectionChanges(){
        
        switch segmentedControl.selectedSegmentIndex {
        case 0 :
            rowsToDisplay = newPackageOrder
        case 1 :
            rowsToDisplay = inProcessPackageOrder
        case 2:
            rowsToDisplay = donePackageOrder
        default:
            rowsToDisplay = newPackageOrder
        }
        
        self.tableView.reloadData()
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
            TripService.shared.fetchMyTrips(userId: User.currentId) { packages in
                packages.forEach { package in
                    let tempPackage = package
                    self.packagesDictionary[tempPackage.packageID] = package
                }
                self.newPackageOrder = Array(self.packagesDictionary.values)
                self.newPackageOrder.sort(by: { $0.timestamp! > $1.timestamp! })
                
                self.rowsToDisplay = self.newPackageOrder
                self.tableView.reloadData()}
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
        navigationController?.pushViewController(orderDetailsController, animated: true)
    }
}

extension OrdersController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("DEBUG: \(searchController.searchBar.text ?? "" )")
    }
}

