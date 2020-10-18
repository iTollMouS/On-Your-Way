//
//  SafetyControllerGuidelines.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/28/20.
//

import UIKit

private let reuseIdentifier = "SafetyCell"

class SafetyControllerGuidelines: UIViewController {
    
    private lazy var headerView = TableHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 250))
    private lazy var footerView = SafetyFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
    
    
    private let blurView : UIVisualEffectView = {
        let blurView = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurView)
        return view
    }()
    
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.tableHeaderView = headerView
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.separatorColor = .clear
        tableView.register(SafetyCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 100
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = footerView
        footerView.delegate = self
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
    }
    
    func configureTableView(){
        view.addSubview(blurView)
        blurView.frame = view.frame
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.footerView.dismissalButton.alpha = 1
        }
    }
    
}

extension SafetyControllerGuidelines : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SafetyCellViewModel.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SafetyCell
        guard let viewModel = SafetyCellViewModel(rawValue: indexPath.row) else { return cell }
        cell.viewModel = viewModel
        return cell
    }
    
    
}
extension SafetyControllerGuidelines: SafetyFooterViewDelegate {
    func handleDismissal(_ view: SafetyFooterView) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
