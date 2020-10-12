//
//  TripDetailsController.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 10/4/20.
//

import UIKit

private let reuseIdentifier = "TripDetailsCell"

class TripDetailsController: UIViewController {
    
    private lazy var headerView = TripDetailsHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
    private lazy var footerView = TripDetailsFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
    
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(TripDetailsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        tableView.rowHeight = 160
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureDelegates()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let peopleReviewsController = PeopleReviewsController()
        peopleReviewsController.popupItem.title = "People Reviews "
        peopleReviewsController.popupItem.subtitle = "Tab here to see who wrote a review about you"
        peopleReviewsController.popupItem.progress = 0.34
        tabBarController?.popupBar.titleTextAttributes = [ .foregroundColor: UIColor.white ]
        tabBarController?.popupBar.subtitleTextAttributes = [ .foregroundColor: UIColor.gray ]
        tabBarController?.presentPopupBar(withContentViewController: peopleReviewsController, animated: true, completion: nil)
    }
    
    
    func configureDelegates(){
        headerView.delegate = self
        footerView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func configureUI(){
        view.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
    
}

extension TripDetailsController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TripDetailsViewModel.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfCells = TripDetailsViewModel(rawValue: section) else { return 0 }
        return numberOfCells.numberOfCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TripDetailsCell
        guard let viewModel = TripDetailsViewModel(rawValue: indexPath.section) else { return cell }
        cell.viewModel = viewModel
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellHeight = TripDetailsViewModel(rawValue: indexPath.section) else { return 0 }
        return cellHeight.cellHeight
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let titleInSection = TripDetailsViewModel(rawValue: section) else { return nil }
        let label = UILabel()
        label.text = titleInSection.titleInSection
        label.textAlignment = .left
        label.textColor = .lightGray
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionHeight = TripDetailsViewModel(rawValue: section) else { return 0 }
        return sectionHeight.heightInSection
    }
    
}

extension TripDetailsController : TripDetailsHeaderViewDelegate {
    func handleStartToChat(_ view: TripDetailsHeaderView) {
        
        // it is working , now you have to implement the functionality
        print("DEBUG: ctart chat in veiw controller ")
    }
    
    
}

extension TripDetailsController: TripDetailsFooterViewDelegate {
    
    func handleSendingPackage(_ footer: TripDetailsFooterView) {
        print("DEBUG: handle pressed in view controller ")
    }
    
    
}
