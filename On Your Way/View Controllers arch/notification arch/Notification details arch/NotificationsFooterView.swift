//
//  NotificationsFooterView.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/20/20.
//

import UIKit


protocol NotificationsFooterViewDelegate: class {
    func handleCancellingMyOrder()
    func handleShowingProofOfDelivery(_ footerView: NotificationsFooterView)
}

class NotificationsFooterView: UIView {
    
    var package: Package?{
        didSet{configure()}
    }
    
    weak var delegate: NotificationsFooterViewDelegate?
    
    lazy var packageIsDeliveredLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .right
        label.numberOfLines = 0
        label.textColor = .white
        label.setHeight(height: 80)
        return label
    }()
    
    lazy var imagePlaceholder: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView.tintColor = .white
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.setDimensions(height: 120, width: 120)
        imageView.layer.cornerRadius = 120 / 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTapped)))
        return imageView
    }()
    
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
        
        addSubview(packageIsDeliveredLabel)
        packageIsDeliveredLabel.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor,
                                       paddingLeft: 28, paddingRight: 28)
        addSubview(imagePlaceholder)
        imagePlaceholder.centerX(inView: self, topAnchor: packageIsDeliveredLabel.bottomAnchor, paddingTop: 12)
        
        addSubview(deleteOrderButton)
        deleteOrderButton.centerX(inView: self, topAnchor: imagePlaceholder.bottomAnchor, paddingTop: 36)
        deleteOrderButton.anchor(left: leftAnchor, right: rightAnchor,
                                 paddingLeft: 32, paddingRight: 32)
        deleteOrderButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func configure(){
        guard let package = package else { return }
        switch package.packageStatus {
        
        case .packageIsPending:
            packageIsDeliveredLabel.text = "سوف يتم مشاركة صوره من اثبات وصول الشحنه عندما يسلم المسافر الشحنه"
        case .packageIsRejected:
            print("")
        case .packageIsAccepted:
            packageIsDeliveredLabel.text = "سوف يتم مشاركة صوره من اثبات وصول الشحنه عندما يسلم المسافر الشحنه"
        case .packageIsDelivered:
            packageIsDeliveredLabel.text = "تم مشاركة صورة من اثبات الوصول في الاسفل\n\(package.packageStatusTimestamp)"
        }
    }
    
    @objc func handleImageTapped(){
        delegate?.handleShowingProofOfDelivery(self)
    }
    
    @objc func handleDeleteOrder(){
        delegate?.handleCancellingMyOrder()
    }
    
}
