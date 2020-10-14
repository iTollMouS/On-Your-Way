//
//  OrderDetailHeaderCell.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/13/20.
//

import UIKit

class OrderDetailHeaderCell: UICollectionViewCell {
    
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.fillSuperview()
        clipsToBounds = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
