//
//  OrderDetailsController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/13/20.
//

import UIKit

private let reuseIdentifier = "OrderDetail"

class OrderDetailsController: UIViewController {
    
    
    private var package: Package
    
    private lazy var headerView = OrderDetailHeader(package: package)

    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(TripDetailsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = headerView
//        tableView.tableFooterView = footerView
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = 60
        return tableView
    }()
    
    init(package: Package) {
        self.package = package
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        print("DEBUG: package id is \(package.packageID)")
        configureUI()
    }
    
    fileprivate func configureUI(){
        view.addSubview(tableView)
        tableView.fillSuperview()
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
    }
}

extension OrderDetailsController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        cell.backgroundColor = .green
        
        return cell
    }
}

extension OrderDetailsController: SendPackageImagesStackViewDelegate {
    func imagesStackView(_ view: SendPackageImagesStackView, index: Int) {
        
        
    }
}
