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

    weak var delegate: SafetyFooterViewDelegate?
    
    private lazy var reportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Okay", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleReport), for: .touchUpInside)
        button.layer.cornerRadius = 50 / 2
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(reportButton)
        reportButton.anchor(left: leftAnchor, right: rightAnchor,
                            paddingLeft: 32, paddingRight: 32)
        reportButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        reportButton.centerY(inView: self)
        backgroundColor = .clear
    }
    
    @objc func handleReport(){
        delegate?.handleDismissal(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
