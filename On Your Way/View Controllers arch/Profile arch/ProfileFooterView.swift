//
//  ProfileFooterView.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/30/20.
//

import UIKit

protocol ProfileFooterDelegate: class {
    func handleLogout(view: ProfileFooterView)
    func handleShowAdminPage(view: ProfileFooterView)
}

class ProfileFooterView: UIView {
    
    weak var delegate: ProfileFooterDelegate?
    var user: User?{
        didSet{configure()}
    }
    
    lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(systemName: "power"), for: .normal)
        button.tintColor = .white
        button.setTitle("Log out  ", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1).withAlphaComponent(0.6)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        button.layer.cornerRadius = 50 / 2
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.5, radius: 16, offset: CGSize(width: 0.0, height: 8.0), color: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1))
        return button
    }()
    
    
    lazy var adminButton: UIButton = {
        let button = UIButton(type: .system)
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Admin  ", for: .normal)
        button.setImage(UIImage(systemName: "lock.shield.fill"), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleShowAdminPage), for: .touchUpInside)
        button.setHeight(height: 50)
        button.layer.cornerRadius = 50 / 2
        button.clipsToBounds = true
        button.alpha = 0
        button.isEnabled = false
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.5, radius: 16, offset: CGSize(width: 0.0, height: 8.0), color: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1))
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [logoutButton,
                                                       adminButton])
        stackView.axis = .vertical
        stackView.spacing = 40
        stackView.setHeight(height: 150)
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    fileprivate func configure(){
        guard let user = user else { return  }
        DispatchQueue.main.async { [weak self] in
            UserServices.shared.adminAuthentication(userId: user.id) { [weak self]isAuthenticate in
                self?.adminButton.alpha = isAuthenticate ? 1 : 0
                self?.adminButton.isEnabled = isAuthenticate ? true : false
            }
        }
        addSubview(stackView)
        stackView.fillSuperview(padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func handleLogout(){
        delegate?.handleLogout(view: self)
    }
    
    @objc func handleShowAdminPage(){
        delegate?.handleShowAdminPage(view: self)
        
    }
}
