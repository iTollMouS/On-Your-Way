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
        tableView.tableFooterView = UIView()
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
    
    
    var darkMode = false
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return darkMode ? .lightContent : .lightContent
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.dismissPopupBar(animated: true, completion: nil)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    
    // MARK: - fetchRecentChats
    fileprivate func fetchRecentChats(){
        RecentChatService.shared.fetchRecentChatFromFirestore { [weak self] allRecent in
            self?.allRecent = allRecent
            // check with all aip why this fucn worsk good and not duplicate stuff
            DispatchQueue.main.async {
                self?.configureWhenTableIsEmpty()
                self?.tableView.reloadData()
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
    
    
    // MARK: - numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredAllRecent.count : allRecent.count
    }
    
    
    // MARK: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! RecentCell
        cell.recentChat = searchController.isActive ? filteredAllRecent[indexPath.row] : allRecent[indexPath.row]
        
        return cell
    }
    
    
    
    // MARK: - didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recent = searchController.isActive ?  filteredAllRecent[indexPath.row] : allRecent[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        // make sure we have 2 recents 
        reStartChat(charRoomId: recent.chatRoomId, memberIds: recent.memberIds)
        
        RecentChatService.shared.clearUnreadCounter(recent: recent)
        let chatViewController = ChatViewController(chatRoomId: recent.chatRoomId,
                                                    recipientId: recent.receiverId,
                                                    recipientName: recent.receiverName)
        chatViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    
    // MARK: - delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recent = searchController.isActive ?  filteredAllRecent[indexPath.row] : allRecent[indexPath.row]
            RecentChatService.shared.deleteRecent(recent) { error in
                print("DEBUG: success deleting recent")
            }
            searchController.isActive ? self.filteredAllRecent.remove(at: indexPath.row) : self.allRecent.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
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
        guard let searchedText = searchController.searchBar.text else { return }
        filteredAllRecent = allRecent.filter({ recent -> Bool in
            return recent.receiverName.lowercased().contains(searchedText.lowercased())
        })
    }
    
}




extension RecentController {
    fileprivate func configureWhenTableIsEmpty(){
        if allRecent.isEmpty {
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] timer in
                
                self?.tableView.setEmptyView(title: "No DMs",
                                             titleColor: .white,
                                             message: "People DM you when you announce your travel info for packaging shipping details and process",
                                             paddingTop: 40)
            }
        } else {tableView.restore()}
        
    }
}

