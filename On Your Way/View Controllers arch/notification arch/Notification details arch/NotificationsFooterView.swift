//
//  NotificationsFooterView.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/20/20.
//

import UIKit

class NotificationsFooterView: UIView {
    
    lazy var deleteOrderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("الغاء طلبي", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1).withAlphaComponent(0.6)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleDeleteOrder), for: .touchUpInside)
        button.layer.cornerRadius = 50 / 2
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.5, radius: 16, offset: CGSize(width: 0.0, height: 8.0), color: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1))
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(deleteOrderButton)
        deleteOrderButton.anchor(left: leftAnchor, right: rightAnchor,
                            paddingLeft: 32, paddingRight: 32)
        deleteOrderButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        deleteOrderButton.centerY(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func handleDeleteOrder(){
        
    }
    
}
