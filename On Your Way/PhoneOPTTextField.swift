//
//  PhoneOPTTextField.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import UIKit

class PhoneOPTTextField: UITextField {
    
    
    /*
     
     // call this in the main controller
     
     oneTimeCodeTextField.configure()
     oneTimeCodeTextField.didEnterLastDigit = { [weak self] code in
         self?.showAlertMessage("Success!", "Success enter last digit \(code)")
     }
     
     */
    
    var didEnterLastDigit: ((String) -> Void)?
    
    var defaultCharacter = "-"
    
    
    
    private var isConfigured = false
    private var digitsLabel = [UILabel]()
    
    
    lazy var digitsStackView = createLabelsStackView(with: 6)
    
    
    private lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(becomeFirstResponder))
        return tap
    }()
    
    func configure(){
        guard isConfigured == false else { return }
        isConfigured.toggle()
        configureTextField()
        digitsStackView.alpha = 0
        addSubview(digitsStackView)
        addGestureRecognizer(tap)
        digitsStackView.fillSuperview()
        setHeight(height: 50)
    }
    
    
    private func configureTextField(){
        tintColor = .clear
        textColor = .clear
        keyboardType = .numberPad
        textContentType = .oneTimeCode
        keyboardAppearance = .dark
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        delegate = self
    }
    
    private func createLabelsStackView(with count: Int) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        for _ in 1 ... count {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 40)
            label.setDimensions(height: 50, width: 50)
            label.layer.cornerRadius = 50 / 2
            label.text = defaultCharacter
            label.textColor = .white
            label.clipsToBounds = true
            label.backgroundColor = .clear
            label.isUserInteractionEnabled = true
            stackView.addArrangedSubview(label)
            digitsLabel.append(label)
        }
        return stackView
    }
    
    @objc private func textDidChange(){
        guard let text = self.text, text.count <= digitsLabel.count else { return  }
        
        for i in 0..<digitsLabel.count {
            let currentLabel = digitsLabel[i]
            
            if i < text.count {
                let index = text.index(text.startIndex, offsetBy: i)
                currentLabel.text = String(text[index])
            } else {
                currentLabel.text = defaultCharacter
            }
        }
        
        if text.count == digitsLabel.count { didEnterLastDigit?(text) }
        
    }
    
}

extension PhoneOPTTextField : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let characterCount = textField.text?.count else { return false }
        return characterCount < digitsLabel.count || string == ""
    }
    
}
