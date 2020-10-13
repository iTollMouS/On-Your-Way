//
//  ProfileFooterView.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/30/20.
//

import UIKit

protocol OrderDetailsFooterViewDelegate: class {
    func handleLogout(view: OrderDetailsFooterView)
}

class OrderDetailsFooterView: UIView {

    weak var delegate: OrderDetailsFooterViewDelegate?
    
    lazy var rejectButton = createButton(tagNumber: 0, title: "Reject", backgroundColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), colorAlpa: 0.6)
    lazy var acceptButton = createButton(tagNumber: 1, title: "Accept", backgroundColor: #colorLiteral(red: 0.1803921569, green: 0.5215686275, blue: 0.431372549, alpha: 1), colorAlpa: 0.6)
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [acceptButton,
                                                       rejectButton])
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        stackView.anchor(left: leftAnchor, right: rightAnchor,
                            paddingLeft: 40, paddingRight: 40)
        stackView.heightAnchor.constraint(equalToConstant: CGFloat(stackView.subviews.count * 80)).isActive = true
        stackView.centerY(inView: self)
    }
    
    
    @objc fileprivate func handleActions(_ sender: UIButton){
        switch sender.tag {
        case 0:
            print("DEBUG: tag 000")
        case 1:
            print("DEBUG: tag 111")
        default: break
        }
        
    }
    
     func createButton(tagNumber: Int, title: String, backgroundColor: UIColor, colorAlpa: CGFloat ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("\(title) order", for: .normal)
        button.backgroundColor = backgroundColor.withAlphaComponent(alpha)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleActions), for: .touchUpInside)
        button.layer.cornerRadius = 50 / 2
        button.tag = tagNumber
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.5, radius: 16, offset: CGSize(width: 0.0, height: 8.0), color: backgroundColor)
        return button
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
}
