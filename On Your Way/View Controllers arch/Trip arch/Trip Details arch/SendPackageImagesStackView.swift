//
//  TopImagesView.swift
//  PetsServe
//
//  Created by Tariq Almazyad on 7/14/20.
//  Copyright © 2020 TariqAlmazyad. All rights reserved.
//

import UIKit

protocol SendPackageImagesStackViewDelegate: class {
    func imagesStackView(_ view: SendPackageImagesStackView, index: Int)
}

class SendPackageImagesStackView: UIView {
    
    weak var delegate: SendPackageImagesStackViewDelegate?
    
    lazy var button0 = createButton(0)
    lazy var button1 = createButton(1)
    lazy var button2 = createButton(2)
    lazy var button3 = createButton(3)
    lazy var button4 = createButton(4)
    lazy var button5 = createButton(5)
    
    var buttons = [UIButton]()
    var imageIndex = 0
    
    
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [button0, button1, button2 ])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        stackView.setHeight(height: 100)
        return stackView
    }()
    
    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [button3, button4, button5])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.setHeight(height: 100)
        return stackView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [topStackView,bottomStackView])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        stackView.fillSuperview()
        
        [button0, button1, button2, button3, button4, button5].forEach { buttons.append($0) }
        
    }
    
    @objc func handleSelectPhoto(_ sender: UIButton){
        delegate?.imagesStackView(self, index: sender.tag)
        
    }
    
    
    func createButton(_ index: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
        button.setTitle("  \(index + 1)", for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.tag = index
        return button
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
