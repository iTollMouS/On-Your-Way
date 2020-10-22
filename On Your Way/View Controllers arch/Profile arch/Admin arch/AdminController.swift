//
//  AdminController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/22/20.
//

import UIKit

private let reuseIdentifier = "AdminCell"

class AdminController: UIViewController {
    
    private let blurView : UIVisualEffectView = {
        let blurView = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurView)
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style:.insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.rowHeight = 80
        tableView.register(AdminCell.self, forCellReuseIdentifier: reuseIdentifier)
        return tableView
    }()
    
    
    private var users = [User]()
    private var usersDictionary = [String: User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavBar()
        fetchUsers()
    }
    
    
    fileprivate func fetchUsers(){
        DispatchQueue.main.async { [weak self] in
            UserServices.shared.downloadAllUsers { [weak self] users in
                for user in users {
                    self?.usersDictionary[user.id] = user
                }
                self?.users = Array(self!.usersDictionary.values)
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - configureNavBar
    func configureNavBar(){
        self.title = "Admin"
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(handleDismissal))
        self.navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    // MARK: - Actions
    @objc func handleDismissal(){
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func configureUI(){
        view.backgroundColor = .clear
        view.addSubview(blurView)
        blurView.frame = view.frame
        view.addSubview(tableView)
        tableView.fillSuperviewSafeAreaLayoutGuide()
        
    }
    
}

extension AdminController: UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! AdminCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    
}
