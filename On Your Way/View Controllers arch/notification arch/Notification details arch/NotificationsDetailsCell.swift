//
//  NotificationsDetailsCell.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/20/20.
//

import UIKit

class NotificationsDetailsCell: UITableViewCell {

    
    var package: Package?{
        didSet{configure()}
    }
    
    
    private lazy var packageTypeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1)
        addSubview(packageTypeLabel)
        packageTypeLabel.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    
    
    fileprivate func configure(){
        guard let package = package else { return }
        packageTypeLabel.text = package.packageType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
