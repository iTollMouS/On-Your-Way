//
//  PageCell.swift
//  autolayout_lbta
//
//  Created by Brian Voong on 10/12/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit

class OnboardingCell: UICollectionViewCell {
    
    var page: Page? {
        didSet {

        }
    }
    
    lazy var newImage = UIImage.gifImageWithName("tenor")
    
    private lazy var bearImageView: UIImageView = {
        let imageView = UIImageView()
    
        return imageView
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
    
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    private func setupLayout() {
      
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
