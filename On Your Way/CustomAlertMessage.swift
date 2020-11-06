//
//  CustomeAlertMessage.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 11/6/20.
//

import UIKit
import SwiftEntryKit
import Lottie

class CustomAlertMessage: UIView {
    
    var messageDidDismiss: (() -> Void)
    
    private lazy var animationView: AnimationView = {
        let animationView = AnimationView()
        animationView.setDimensions(height: 100, width: 100)
        animationView.clipsToBounds = true
        animationView.layer.cornerRadius = 100 / 5
        animationView.backgroundColor = .clear
        animationView.contentMode = .scaleAspectFill
        return animationView
    }()
    
    var attributes = EKAttributes.bottomNote
    
    private lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.2156862745, green: 0.2156862745, blue: 0.2156862745, alpha: 1)
        view.layer.cornerRadius = 30
        return view
    }()
    
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.setHeight(height: 80)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var dismissalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("تخطي", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1), for: .normal)
        button.setDimensions(height: 50, width: 300)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 50 / 2
        button.backgroundColor = #colorLiteral(red: 0.3450980392, green: 0.3450980392, blue: 0.3450980392, alpha: 1)
        button.addTarget(self, action: #selector(handleAnonymousMode), for: .touchUpInside)
        return button
    }()
    
    
    init(condition: Conditions ,messageTitle: String, messageBody: String, size: CGSize, completion: @escaping(() -> Void)) {
        self.messageDidDismiss = completion
        super.init(frame: .zero)
        
        layer.cornerRadius = 10
        backgroundColor = .clear
        setDimensions(height: size.height, width: size.width)
        clipsToBounds = true
        
        configureUI()
        configureSwiftEKAttributes()
        conditionType(condition: condition)
        message(messageTitle, messageBody)
        
    }
    
    fileprivate func configureSwiftEKAttributes(){
        
        
        attributes.screenBackground = .visualEffect(style: .dark)
        attributes.positionConstraints.safeArea = .overridden
        attributes.positionConstraints.verticalOffset = 250
        attributes.windowLevel = .normal
        attributes.position = .bottom
        attributes.precedence = .override(priority: .max, dropEnqueuedEntries: false)
        attributes.displayDuration = .infinity
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.statusBar = .light
        attributes.lifecycleEvents.willDisappear = { [weak self] in
            self?.messageDidDismiss()
        }
        attributes.entryBackground = .clear
        SwiftEntryKit.display(entry: self, using: attributes)
        
        
    }
    
    fileprivate func configureUI(){
        
        addSubview(bottomContainerView)
        addSubview(animationView)
        
        animationView.centerX(inView: self, topAnchor: topAnchor, paddingTop: 0)
        bottomContainerView.anchor(top: animationView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: -50)
        
        bottomContainerView.addSubview(messageLabel)
        messageLabel.anchor(top: bottomContainerView.topAnchor, left: bottomContainerView.leftAnchor, right: bottomContainerView.rightAnchor, paddingTop: 50)
        bottomContainerView.addSubview(dismissalButton)
        dismissalButton.anchor(left: bottomContainerView.leftAnchor, bottom: bottomContainerView.bottomAnchor, right: bottomContainerView.rightAnchor,
                               paddingLeft: 30, paddingBottom: 30, paddingRight: 30)
        
        
    }
    
    fileprivate func message(_ messageTitle: String, _ messageBody: String){
        
        let attributedText = NSMutableAttributedString(string: "\(messageTitle)\n",
                                                       attributes: [.foregroundColor : #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1),
                                                                    .font: UIFont.boldSystemFont(ofSize: 18)])
        attributedText.append(NSMutableAttributedString(string: messageBody,
                                                        attributes: [.foregroundColor : UIColor.lightGray,
                                                                     .font: UIFont.systemFont(ofSize: 16)]))
        messageLabel.attributedText = attributedText
        
    }
    
    fileprivate func conditionType(condition: Conditions){
        
        switch condition {
        case .success:
            animationView.animation = Animation.named(condition.JSONStringName)
            animationView.play()
            animationView.loopMode = .repeat(5)
        case .warning:
            animationView.animation = Animation.named(condition.JSONStringName)
            animationView.play()
            animationView.loopMode = .repeat(5)
        case .error:
            animationView.animation = Animation.named(condition.JSONStringName)
            animationView.play()
            animationView.loopMode = .repeat(5)
        }
    }
    
    @objc fileprivate func handleAnonymousMode(){
        SwiftEntryKit.dismiss()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
