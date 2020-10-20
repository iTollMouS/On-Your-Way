//
//  ProfileFooterView.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/30/20.
//

import UIKit

protocol OrderDetailsFooterViewDelegate: class {
    func assignPackageStatus(_ sender: UIButton, _ footer: OrderDetailsFooterView)
}

class OrderDetailsFooterView: UIView {
    
    
    weak var delegate: OrderDetailsFooterViewDelegate?
    
    var package: Package?{
        didSet{configure()}
    }
    
    
    lazy var rejectButton = createButton(tagNumber: 0, title: "Reject", backgroundColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), colorAlpa: 0.6, systemName: "xmark.circle.fill")
    lazy var acceptButton = createButton(tagNumber: 1, title: "Accept", backgroundColor: #colorLiteral(red: 0.1803921569, green: 0.5215686275, blue: 0.431372549, alpha: 1), colorAlpa: 0.6, systemName: "checkmark.circle.fill")
    lazy var startChatButton = createButton(tagNumber: 2, title: "Chat", backgroundColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1), colorAlpa: 0.4, systemName: "bubble.left.and.bubble.right.fill")
    
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [rejectButton,
                                                       acceptButton,
                                                       startChatButton,
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.setDimensions(height: 180, width: 300)
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stackView)
        stackView.centerInSuperview()
        
    }
    
    fileprivate func configure(){
        guard let package = package else { return }
       
        switch package.packageStatus {
        case .packageIsPending:
            print("")
        case .packageIsRejected:
            print("")
        case .packageIsAccepted:
            acceptButton.setTitle("You have accepted order in \n\(package.packageStatusTimestamp)", for: .normal)
            acceptButton.isEnabled = false
        case .packageIsDelivered:
            print("")
        }
    }
    
    
    @objc fileprivate func handleActions(_ sender: UIButton){
        delegate?.assignPackageStatus(sender, self)
    }
    
    func createButton(tagNumber: Int, title: String?, backgroundColor: UIColor, colorAlpa: CGFloat, systemName: String  ) -> UIButton {
        let button = UIButton(type: .system)
        guard let title = title else { return UIButton() }
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.titleLabel?.numberOfLines = 0
        button.setTitle("\(title) order ", for: .normal)
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.backgroundColor = backgroundColor.withAlphaComponent(alpha)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleActions), for: .touchUpInside)
        button.layer.cornerRadius = 50 / 2
        button.tag = tagNumber
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.5, radius: 16, offset: CGSize(width: 0.0, height: 8.0), color: backgroundColor)
        return button
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
