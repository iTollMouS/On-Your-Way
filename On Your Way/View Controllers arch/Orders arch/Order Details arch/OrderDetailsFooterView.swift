//
//  ProfileFooterView.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/30/20.
//

import UIKit

protocol OrderDetailsFooterViewDelegate: class {
    func assignPackageStatus(_ sender: UIButton, _ footer: OrderDetailsFooterView)
    func handleShowingProofOfDelivery(_ footerView: OrderDetailsFooterView)
}

class OrderDetailsFooterView: UIView {
    
    
    weak var delegate: OrderDetailsFooterViewDelegate?
    
    var package: Package?{
        didSet{configure()}
    }
    
    
    lazy var rejectButton = createButton(tagNumber: 0, title: "رفض", backgroundColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), colorAlpa: 0.6, systemName: "xmark.circle.fill")
    lazy var acceptButton = createButton(tagNumber: 1, title: "قبول", backgroundColor: #colorLiteral(red: 0.1803921569, green: 0.5215686275, blue: 0.431372549, alpha: 1), colorAlpa: 0.6, systemName: "checkmark.circle.fill")
    lazy var startChatButton = createButton(tagNumber: 2, title: "المحادثه", backgroundColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1), colorAlpa: 0.4, systemName: "bubble.left.and.bubble.right.fill")
    
    private lazy var packageIsDeliveredLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 0
        label.textColor = .white
        label.setHeight(height: 120)
        return label
    }()
    
    lazy var imagePlaceholder: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView.tintColor = .white
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.setDimensions(height: 60, width: 60)
        imageView.layer.cornerRadius = 60 / 2
        imageView.isUserInteractionEnabled = true
        imageView.isHidden = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTapped)))
        return imageView
    }()
    
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [acceptButton,
                                                       startChatButton,
                                                       rejectButton,
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.setDimensions(height: 180, width: 300)
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(packageIsDeliveredLabel)
        packageIsDeliveredLabel.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor,
                                       paddingLeft: 28, paddingRight: 28)
        packageIsDeliveredLabel.backgroundColor = .systemGreen
        addSubview(imagePlaceholder)
        imagePlaceholder.centerX(inView: self, topAnchor: packageIsDeliveredLabel.bottomAnchor, paddingTop: 26)
        
        
        addSubview(stackView)
        stackView.centerX(inView: self, topAnchor: imagePlaceholder.bottomAnchor, paddingTop: 24)
        
    }
    
    fileprivate func configure(){
        guard let package = package else { return }
        
        switch package.packageStatus {
        case .packageIsPending:
            imagePlaceholder.isHidden = true
            imagePlaceholder.setDimensions(height: 10, width: 10)
            packageIsDeliveredLabel.text = "في حالة قبولك للطلب ، تستطيع مشاركة صورة  من اثبات وصول الشحنه عند التسليم\nسيتم ارسال تنبيه للعميل عند رفع صوره اثبات وصول الشحنه"
        case .packageIsRejected:
            print("")
        case .packageIsAccepted:
            acceptButton.setTitle("قمت بقبول الطلب في \n\(package.packageStatusTimestamp)", for: .normal)
            acceptButton.isEnabled = false
            imagePlaceholder.isHidden = false
            imagePlaceholder.setDimensions(height: 60, width: 60)
            imagePlaceholder.isUserInteractionEnabled = false
            packageIsDeliveredLabel.text = "يستطيع العميل ان يرسل تقييم عن جودة الخدمه المقدمة منك"
        case .packageIsDelivered:
            packageIsDeliveredLabel.text = "يستطيع العميل ان يرسل تقييم عن جودة الخدمه المقدمة منك"
            FileStorage.downloadImage(imageUrl: package.packageProofOfDeliveredImage) { [weak self] image in
                guard let image = image else {return}
                self?.imagePlaceholder.image = image
                self?.imagePlaceholder.contentMode = .scaleAspectFill
                self?.imagePlaceholder.setDimensions(height: 60, width: 60)
                self?.imagePlaceholder.clipsToBounds = true
                self?.imagePlaceholder.layer.cornerRadius = 60 / 2
            }
            acceptButton.setTitle(" تم ايصال الطلب في\n\(package.packageStatusTimestamp)", for: .normal)
            imagePlaceholder.isHidden = false
            rejectButton.isEnabled = false
            rejectButton.alpha = 0
            acceptButton.isEnabled = false
            imagePlaceholder.isUserInteractionEnabled = true
        }
    }
    
    
    @objc func handleImageTapped(){
        delegate?.handleShowingProofOfDelivery(self)
    }
    
    
    @objc fileprivate func handleActions(_ sender: UIButton){
        delegate?.assignPackageStatus(sender, self)
    }
    
    fileprivate func createButton(tagNumber: Int, title: String?, backgroundColor: UIColor, colorAlpa: CGFloat, systemName: String  ) -> UIButton {
        let button = UIButton(type: .system)
        guard let title = title else { return UIButton() }
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.titleLabel?.numberOfLines = 0
        button.setTitle("\(title) الطلب ", for: .normal)
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
