//
//  AdminHeaderView.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/22/20.
//

import UIKit


protocol AdminHeaderViewDelegate: class {
    func handleActionTapped(_ sender: UIButton)
}

class AdminHeaderView: UIView {
    
    
    weak var delegate: AdminHeaderViewDelegate?
    
    lazy var notificationButton = createButton(tagNumber: 1, backgroundColor: #colorLiteral(red: 0.1803921569, green: 0.5215686275, blue: 0.431372549, alpha: 1), colorAlpa: 0.6, systemName: "app.badge.fill")
    lazy var sendEmailButton = createButton(tagNumber: 2,backgroundColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1), colorAlpa: 1, systemName: "paperplane.fill")
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customAddSubViews(notificationButton, sendEmailButton)
        notificationButton.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 100)
        sendEmailButton.centerY(inView: self)
        sendEmailButton.anchor(right: rightAnchor, paddingRight: 100)
        
    }
    
    @objc fileprivate func handleActions(_ sender: UIButton){
        delegate?.handleActionTapped(sender)
    }
    
    
    fileprivate func createButton(tagNumber: Int, backgroundColor: UIColor, colorAlpa: CGFloat, systemName: String  ) -> UIButton {
        let button = UIButton(type: .system)
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.backgroundColor = backgroundColor.withAlphaComponent(colorAlpa)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleActions), for: .touchUpInside)
        button.setDimensions(height: 50, width: 50)
        button.layer.cornerRadius = 50 / 2
        button.tag = tagNumber
        button.titleLabel?.numberOfLines = 0
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.5, radius: 16, offset: CGSize(width: 0.0, height: 8.0), color: backgroundColor)
        return button
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
