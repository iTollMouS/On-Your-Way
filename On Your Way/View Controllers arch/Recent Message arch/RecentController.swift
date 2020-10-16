//
//  RecentController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit


private let reuseIdentifier = "RecentCell"

class RecentController: UIViewController {
    
    
    // MARK: - Properties
    var allRecent: [RecentChat] = []
    var filteredAllRecent: [RecentChat] = []
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let refreshController = UIRefreshControl()
    
    private let blurView : UIVisualEffectView = {
        let blurView = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurView)
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RecentCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = .clear
        tableView.rowHeight = 100
        return tableView
    }()
    
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        configureTableView()
        configureSearchController()
        configureRefreshControl()
        fetchRecentChats()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.dismissPopupBar(animated: true, completion: nil)
        navigationItem.largeTitleDisplayMode = .always
    }
    
    // step 10
    fileprivate func fetchRecentChats(){
        FirebaseRecentService.shared.fetchRecentChatFromFirestore { allRecent in
            self.allRecent = allRecent
            // check with all aip why this fucn worsk good and not duplicate stuff
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - configureRefreshControl
    func configureRefreshControl(){
        refreshController.tintColor = .white
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:
                                                                [.foregroundColor: UIColor.white])
        tableView.refreshControl = refreshController
        
    }
    
    // MARK: - configureSearchController(
    func configureSearchController(){
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a user"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    
    // MARK: - configureTableView
    func configureTableView(){
        view.addSubview(blurView)
        blurView.frame = view.frame
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                         bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    
    // MARK: - configureNavBar
    func configureNavBar(){
        self.title = "Messages"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(handleDismissal))
        self.navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    // MARK: - Actions
    @objc func handleDismissal(){
        dismiss(animated: true, completion: nil)
    }
    
    
    
}


// MARK: - Table extensions
extension RecentController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredAllRecent.count : allRecent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! RecentCell
        let recent = searchController.isActive ? filteredAllRecent[indexPath.row] : allRecent[indexPath.row]
        cell.configure(recent: recent)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refreshController.isRefreshing {
            // download user
            self.refreshController.endRefreshing()
        }
    }
}


// MARK: - UISearchResultsUpdating
extension RecentController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        print("DEBUG: \(searchController.searchBar.text)")
    }
    
}
