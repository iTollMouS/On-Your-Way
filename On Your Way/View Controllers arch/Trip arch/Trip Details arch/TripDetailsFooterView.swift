//
//  TripDetailsFooterView.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 10/6/20.
//

import UIKit



protocol TripDetailsFooterViewDelegate: class {
    func handleSendingPackage(_ footer: TripDetailsFooterView)
}

class TripDetailsFooterView: UIView {
    
    weak var delegate: TripDetailsFooterViewDelegate?

    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        button.setTitle("Send package with  ", for: .normal)
        button.setImage(UIImage(systemName: "shippingbox.fill"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleRequestSendingPackage), for: .touchUpInside)
        button.layer.cornerRadius = 50 / 2
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.5, radius: 16, offset: CGSize(width: 0.0, height: 8.0), color: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1))
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(logoutButton)
        logoutButton.anchor(left: leftAnchor, right: rightAnchor,
                            paddingLeft: 32, paddingRight: 32)
        logoutButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logoutButton.centerY(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func handleRequestSendingPackage(){
        delegate?.handleSendingPackage(self)
    }
}
