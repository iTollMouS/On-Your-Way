//
//  ProfileFooterView.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/30/20.
//

import UIKit

protocol OrderDetailsFooterViewDelegate: class {
    func assignPackageStatus(_ sender: UIButton)
}

class OrderDetailsFooterView: UIView {
    
    weak var delegate: OrderDetailsFooterViewDelegate?
    
    lazy var rejectButton = createButton(tagNumber: 0, title: "Reject", backgroundColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), colorAlpa: 0.6, systemName: "xmark.circle.fill")
    lazy var acceptButton = createButton(tagNumber: 1, title: "Accept", backgroundColor: #colorLiteral(red: 0.1803921569, green: 0.5215686275, blue: 0.431372549, alpha: 1), colorAlpa: 0.6, systemName: "checkmark.circle.fill")
    lazy var startChatButton = createButton(tagNumber: 2, title: "Chat", backgroundColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1), colorAlpa: 0.4, systemName: "bubble.left.and.bubble.right.fill")

    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [acceptButton,
                                                       startChatButton,
                                                       rejectButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.setDimensions(height: 180, width: 200)
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stackView)
        stackView.centerInSuperview()
      
    }
    
    
    @objc fileprivate func handleActions(_ sender: UIButton){
        delegate?.assignPackageStatus(sender)
    }
    
    func createButton(tagNumber: Int, title: String, backgroundColor: UIColor, colorAlpa: CGFloat, systemName: String  ) -> UIButton {
        let button = UIButton(type: .system)
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.setTitle("\(title) order ", for: .normal)
        button.setImage(UIImage(systemName: systemName), for: .normal)
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
