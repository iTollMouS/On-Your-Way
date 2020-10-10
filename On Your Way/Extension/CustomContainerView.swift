//
//  CustomContainerView.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit

class CustomContainerView: UIView {
    
    
    init(image: UIImage?, textField: UITextField, iconTintColor: UIColor,
         dividerViewColor: UIColor, dividerAlpa: CGFloat , setViewHeight:CGFloat, iconAlpa: CGFloat, backgroundColor: UIColor) {
        
        super.init(frame: .zero)
        self.setHeight(height: setViewHeight)
        
        self.backgroundColor = backgroundColor
        layer.cornerRadius = setViewHeight / 2
        
        let icon = UIImageView()
        icon.image = image
        icon.tintColor = iconTintColor
        icon.layer.cornerRadius = 10
        icon.clipsToBounds = true
        
        icon.alpha = iconAlpa
        
        addSubview(icon)
        icon.centerY(inView: self)
        icon.anchor(left: leftAnchor, paddingLeft: 8)
        icon.setDimensions(height: 26, width: 25)
        
        addSubview(textField)
        textField.centerY(inView: self)
        textField.anchor(left: icon.rightAnchor, bottom: bottomAnchor, right: rightAnchor,
                         paddingLeft: 8)
        
        let dividerView = UIView()
        dividerView.backgroundColor = dividerViewColor.withAlphaComponent(dividerAlpa)
        addSubview(dividerView)
        dividerView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                           paddingLeft: 8 , height: 0.75)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
