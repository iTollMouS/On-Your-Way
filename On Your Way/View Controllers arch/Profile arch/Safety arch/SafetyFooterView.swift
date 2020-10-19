//
//  SafetyFooterView.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/28/20.
//

import UIKit

protocol SafetyFooterViewDelegate: class {
    func handleDismissal(_ view: SafetyFooterView)
}

class SafetyFooterView: UIView {

    // MARK: - Delegate
    weak var delegate: SafetyFooterViewDelegate?
    
    
    // MARK: - Properties 
    lazy var dismissalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Okay", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleReport), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
        button.layer.cornerRadius = 50 / 2
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.clipsToBounds = true
        button.alpha = 0
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.5, radius: 16, offset: CGSize(width: 0.0, height: 8.0), color: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1))
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(dismissalButton)
        dismissalButton.anchor(left: leftAnchor, right: rightAnchor,
                            paddingLeft: 32, paddingRight: 32)
        dismissalButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        dismissalButton.centerY(inView: self)
        backgroundColor = .clear
    }
    
    @objc func handleReport(){
        delegate?.handleDismissal(self)
    }
    
    override func layoutSubviews() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
