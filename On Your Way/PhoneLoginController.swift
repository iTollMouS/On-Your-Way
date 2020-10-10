//
//  PhoneLoginController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit

class PhoneLoginController: UIViewController {
    
    
    // MARK: - Propertes
    private let blurView : UIVisualEffectView = {
        let blurView = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurView)
        return view
    }()
    
    private lazy var dismissView: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.down"), for: .normal)
        button.setDimensions(height: 50, width: 50)
        button.layer.cornerRadius = 50 / 2
        button.backgroundColor = UIColor.systemRed.withAlphaComponent(0.6)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "Enter your phone number",
                                                       attributes: [.foregroundColor : UIColor.white, .font: UIFont.boldSystemFont(ofSize: 26)])
        attributedText.append(NSMutableAttributedString(string: "\nWe will send you a code to verify your phone number",
                                                        attributes: [.foregroundColor : UIColor.white, .font: UIFont.systemFont(ofSize: 16)]))
        label.attributedText = attributedText
        label.setDimensions(height: 160, width: 300)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
 
    private lazy var oneTimeCodeTextField = PhoneOPTTextField()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureUI()
        configureTextField()
        
    }
    
    
    func configureTextField(){
        oneTimeCodeTextField.configure()
        oneTimeCodeTextField.didEnterLastDigit = { [weak self] code in
            self?.showAlertMessage("Success!", "Success enter last digit \(code)")
        }
        
    }
    
    func configureUI(){
        view.addSubview(blurView)
        blurView.frame = view.frame
        view.addSubview(dismissView)
        dismissView.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 20, paddingRight: 20)
        view.addSubview(infoLabel)
        infoLabel.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 30)
        infoLabel.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 20, paddingRight: 20)
        view.addSubview(oneTimeCodeTextField)
        oneTimeCodeTextField.centerX(inView: infoLabel, topAnchor: infoLabel.bottomAnchor, paddingTop: 20)
        oneTimeCodeTextField.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 20, paddingRight: 20)
        
    }
    
    
    // MARK: - Actions
    
    @objc func handleDismissal(){
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
