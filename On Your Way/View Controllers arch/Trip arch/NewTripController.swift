//
//  NewTripController.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/27/20.
//

import UIKit
import LNPopupController

protocol NewTripControllerDelegate: class {
    func dismissNewTripView(_ view: NewTripController)
}

class NewTripController: UIViewController, UIScrollViewDelegate {
    
    
    private lazy var contentSizeView = CGSize(width: self.view.frame.width,
                                              height: self.view.frame.height + 10)
    
    weak var delegate: NewTripControllerDelegate?
    
    private lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        scrollView.frame = self.view.bounds
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.scrollIndicatorInsets = .zero
        scrollView.contentSize = contentSizeView
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
    
    
    private let blurView : UIVisualEffectView = {
        let blurView = UIBlurEffect(style: .regular)
        let view = UIVisualEffectView(effect: blurView)
        return view
    }()
    
    
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        view.frame.size = contentSizeView
        view.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        return view
    }()
    
    
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        view.setupShadow(opacity: 0.2, radius: 20, offset: CGSize(width: 0.0, height: 8.0), color: .black)
        return view
    }()
    
    private lazy var topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        view.layer.cornerRadius = 20
        view.setHeight(height: 150)
        view.setupShadow(opacity: 0.2, radius: 10, offset: CGSize(width: 0.0, height: 4.0), color: UIColor.white.withAlphaComponent(0.4))
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Setup your trip info"
        label.textAlignment = .center
        label.setHeight(height: 40)
        label.textColor = #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
        return label
    }()
    
    
    private let currentLocationTextField = CustomTextField(textColor: .white, placeholder: "Your current location",
                                                           placeholderColor: .blueLightFont, placeholderAlpa: 1, isSecure: false)
    
    
    private lazy var currentLocationContainerView = CustomContainerView(image: UIImage(systemName: "target"),
                                                                        textField: currentLocationTextField, iconTintColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1), dividerViewColor: .black,
                                                                        dividerAlpa: 1, setViewHeight: 50, iconAlpa: 1, backgroundColor: .clear)
    
    private let destinationTextField = CustomTextField(textColor: .white, placeholder: "destination",
                                                       placeholderColor: .blueLightFont, placeholderAlpa: 1, isSecure: false)
    
    
    
    
    private lazy var destinationContainerView = CustomContainerView(image: UIImage(systemName: "location.fill"),
                                                                    textField: currentLocationTextField, iconTintColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1), dividerViewColor: .black,
                                                                    dividerAlpa: 1, setViewHeight: 50, iconAlpa: 1, backgroundColor: .clear)
    
    private let meetingForPickupTextField = CustomTextField(textColor: .white, placeholder: "Where you want to meet",
                                                            placeholderColor: .blueLightFont, placeholderAlpa: 1, isSecure: false)
    
    
    
    
    private lazy var meetingForPickupDestinationContainerView = CustomContainerView(image:  #imageLiteral(resourceName: "35_Spy-512"), textField: meetingForPickupTextField, iconTintColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1),
                                                                                    dividerViewColor: .lightGray, dividerAlpa: 1 ,setViewHeight: 50, iconAlpa: 1, backgroundColor: .clear)
    
    private let packageDescriptionTextField = CustomTextField(textColor: .white, placeholder: "what inside the package ?",
                                                              placeholderColor: .blueLightFont, placeholderAlpa: 1, isSecure: false)
    
    
    private lazy var packageDescriptionContainerView = CustomContainerView(image:  UIImage(systemName: "shippingbox.fill"),
                                                                           textField: packageDescriptionTextField, iconTintColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1),
                                                                           dividerViewColor: .lightGray, dividerAlpa: 1,
                                                                           setViewHeight: 50, iconAlpa: 1, backgroundColor: .clear)
    
    
    
    private let whatCanTakeTextField = CustomTextField(textColor: .white, placeholder: "what can you take?",
                                                       placeholderColor: .blueLightFont, placeholderAlpa: 1, isSecure: false)
    
    private lazy var whatCanTakeContainerView = CustomContainerView(image:  #imageLiteral(resourceName: "btn_google_light_pressed_ios"),
                                                                    textField: whatCanTakeTextField, iconTintColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1),
                                                                    dividerViewColor: .lightGray, dividerAlpa: 1,
                                                                    setViewHeight: 50, iconAlpa: 1, backgroundColor: .clear)
    
    private let timeToPickPackageTextField = CustomTextField(textColor: .white, placeholder: "when to meet?",
                                                             placeholderColor: .blueLightFont, placeholderAlpa: 1, isSecure: false)
    
    
    private lazy var timeToPickPackageContainerView = CustomContainerView(image:  UIImage(systemName: "clock.fill"),
                                                                          textField: timeToPickPackageTextField, iconTintColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1),
                                                                          dividerViewColor: .lightGray, dividerAlpa: 1,
                                                                          setViewHeight: 50, iconAlpa: 1, backgroundColor: .clear)
    
    
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentLocationContainerView,
                                                       destinationContainerView])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var middleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [meetingForPickupDestinationContainerView,
                                                       packageDescriptionContainerView,
                                                       whatCanTakeContainerView,
                                                       timeToPickPackageContainerView])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.setHeight(height: CGFloat(stackView.subviews.count * 70))
        return stackView
    }()
    
    
    
    private lazy var setupDateAndTimeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "calendar"), for: .normal)
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        button.setTitle("Setup date and time travel\t", for: .normal)
        button.setHeight(height: 50)
        button.setTitleColor(#colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1), for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
        button.layer.cornerRadius = 50 / 2
        button.tintColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
        button.addTarget(self, action: #selector(handleDateAndTimeTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        self.hideKeyboardWhenTouchOutsideTextField()
    }
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        configureNavigationBar(withTitle: "Trip", largeTitleColor: #colorLiteral(red: 0.6274509804, green: 0.6274509804, blue: 0.6274509804, alpha: 1), tintColor: .white, navBarColor: #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1),
                               smallTitleColorWhenScrolling: .light, prefersLargeTitles: false)
        navigationController?.navigationBar.isHidden = true
    }
    
    func configureUI(){
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        titleLabel.centerX(inView: contentView, topAnchor: contentView.topAnchor, paddingTop: 60)
        titleLabel.anchor(left: contentView.leftAnchor, right: contentView.rightAnchor)
        
        contentView.addSubview(mainContentView)
        mainContentView.anchor(top: titleLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor,
                               paddingTop: 20 , paddingLeft: 20, paddingBottom: 20 , paddingRight: 20, height: 550)
        
        
        titleLabel.centerX(inView: contentView)
        contentView.addSubview(topContainerView)
        topContainerView.anchor(top: mainContentView.topAnchor, left: mainContentView.leftAnchor, right: mainContentView.rightAnchor)
        topContainerView.addSubview(topStackView)
        topStackView.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
        mainContentView.addSubview(middleStackView)
        middleStackView.anchor(top: topStackView.bottomAnchor, left: mainContentView.leftAnchor, right: mainContentView.rightAnchor,
                               paddingTop: 0, paddingLeft: 20, paddingRight: 20)
        mainContentView.addSubview(setupDateAndTimeButton)
        setupDateAndTimeButton.anchor(left: mainContentView.leftAnchor, bottom: mainContentView.bottomAnchor ,right: mainContentView.rightAnchor,
                                      paddingLeft: 20, paddingBottom: 20 ,paddingRight: 20)
        
    }
    
    @objc func handleDateAndTimeTapped(){
        let dateAndTimeController = DateAndTimeController()
        dateAndTimeController.delegate = self
        dateAndTimeController.modalPresentationStyle = .fullScreen
        present(dateAndTimeController, animated: true, completion: nil)
    }
    
    
}

extension NewTripController: DateAndTimeControllerDelegate {
    func dismissDateAndTimeController(_ view: DateAndTimeController) {
        view.dismiss(animated: true) { [self] in
            delegate?.dismissNewTripView(self)
        }
    }
}
