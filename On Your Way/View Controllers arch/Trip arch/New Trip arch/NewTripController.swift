//
//  NewTripController.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/27/20.
//

import UIKit
import LNPopupController
import Firebase
import FirebaseFirestoreSwift
import CoreLocation
import SwiftEntryKit
import Lottie

protocol NewTripControllerDelegate: class {
    func dismissNewTripView(_ view: NewTripController)
    func dismissLoggingAnonymousOut(_ view: NewTripController)
}

class NewTripController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - ScrollView setup
    private lazy var contentSizeView = CGSize(width: self.view.frame.width,
                                              height: self.view.frame.height + 10)
    
    
    // MARK: - NewTripControllerDelegate
    weak var delegate: NewTripControllerDelegate?
    
    
    private lazy var animationView: AnimationView = {
        let animationView = AnimationView()
        animationView.setDimensions(height: 100, width: 100)
        animationView.clipsToBounds = true
        animationView.layer.cornerRadius = 100 / 5
        animationView.backgroundColor = .clear
        animationView.contentMode = .scaleAspectFill
        return animationView
    }()
    
    
    private lazy var customAlertView = UIView()
    var attributes = EKAttributes.bottomNote
    
    private lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.2156862745, green: 0.2156862745, blue: 0.2156862745, alpha: 1)
        view.layer.cornerRadius = 30
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "Ops!\n",
                                                       attributes: [.foregroundColor : #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1),
                                                                    .font: UIFont.boldSystemFont(ofSize: 18)])
        attributedText.append(NSMutableAttributedString(string: "You can not ship packages or chat without an account.\nPlease press Ok on the bottom to go back",
                                                        attributes: [.foregroundColor : UIColor.lightGray,
                                                                     .font: UIFont.systemFont(ofSize: 16)]))
        
        label.attributedText = attributedText
        label.setHeight(height: 80)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var dismissalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Okay", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1), for: .normal)
        button.setDimensions(height: 50, width: 300)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 50 / 2
        button.backgroundColor = #colorLiteral(red: 0.3450980392, green: 0.3450980392, blue: 0.3450980392, alpha: 1)
        button.addTarget(self, action: #selector(handleAnonymousMode), for: .touchUpInside)
        return button
    }()
    
    
    
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
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        view.frame.size = contentSizeView
        view.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        return view
    }()
    
    // MARK: - Containers
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
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        return label
    }()
    
    
    
    // MARK: - form custom containers
    private let currentLocationTextField = CustomTextField(textColor: .white, placeholder: "Your current location",
                                                           placeholderColor: .blueLightFont, placeholderAlpa: 1, isSecure: false)
    
    private lazy var currentLocationContainerView = CustomContainerView(image: UIImage(systemName: "target"),
                                                                        textField: currentLocationTextField, iconTintColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1), dividerViewColor: .black,
                                                                        dividerAlpa: 1, setViewHeight: 50, iconAlpa: 1, backgroundColor: .clear)
    
    private let destinationTextField = CustomTextField(textColor: .white, placeholder: "destination",
                                                       placeholderColor: .blueLightFont, placeholderAlpa: 1, isSecure: false)
    
    
    private lazy var destinationContainerView = CustomContainerView(image: UIImage(systemName: "location.fill"),
                                                                    textField: destinationTextField, iconTintColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1), dividerViewColor: .black,
                                                                    dividerAlpa: 1, setViewHeight: 50, iconAlpa: 1, backgroundColor: .clear)
    
    private let meetingForPickupTextField = CustomTextField(textColor: .white, placeholder: "Where you want to meet",
                                                            placeholderColor: .blueLightFont, placeholderAlpa: 1, isSecure: false)
    
    
    private lazy var meetingForPickupDestinationContainerView = CustomContainerView(image: #imageLiteral(resourceName: "Untitled_Artwork_2-removebg-preview").withRenderingMode(.alwaysOriginal),
                                                                                    textField: meetingForPickupTextField, iconTintColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1),
                                                                                    dividerViewColor: .lightGray, dividerAlpa: 1 ,setViewHeight: 50, iconAlpa: 1, backgroundColor: .clear)
    
    private let timeToPickPackageTextField = CustomTextField(textColor: .white, placeholder: "when to meet?",
                                                             placeholderColor: .blueLightFont, placeholderAlpa: 1, isSecure: false)
    
    
    private lazy var timeToPickPackageContainerView = CustomContainerView(image:  UIImage(systemName: "clock.fill"),
                                                                          textField: timeToPickPackageTextField, iconTintColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1),
                                                                          dividerViewColor: .lightGray, dividerAlpa: 1,
                                                                          setViewHeight: 50, iconAlpa: 1, backgroundColor: .clear)
    
    private let basePriceTextField = CustomTextField(textColor: .white, placeholder: "base price?",
                                                     placeholderColor: .blueLightFont, placeholderAlpa: 1, isSecure: false)
    
    
    private lazy var basePriceContainerView = CustomContainerView(image:  UIImage(systemName: "dollarsign.circle.fill"),
                                                                  textField: basePriceTextField, iconTintColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1),
                                                                  dividerViewColor: .lightGray, dividerAlpa: 1,
                                                                  setViewHeight: 50, iconAlpa: 1, backgroundColor: .clear)
    
    
    
    // MARK: - stacks
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentLocationContainerView,
                                                       destinationContainerView])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var middleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [meetingForPickupDestinationContainerView,
                                                       timeToPickPackageContainerView,
                                                       basePriceContainerView])
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
    
    private lazy var fromCityPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.tag = 0
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    private lazy var destinationCityPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.tag = 1
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    private lazy var toolbar: UIToolbar = {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let dismissButton = UIBarButtonItem(title: "done", style: .plain, target: self,
                                            action: #selector(handlePickViewDismissal))
        toolBar.barStyle = .black
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        toolBar.setItems([flexButton, dismissButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }()
    
    private lazy var timestampPickerView: UIDatePicker = {
        let pickerView = UIDatePicker()
        pickerView.datePickerMode = .time
        pickerView.preferredDatePickerStyle = .wheels
        pickerView.addTarget(self, action: #selector(handleTimeSelected(_ :)), for: .valueChanged)
        return pickerView
    }()
    
    private var currentLocationCity: Cities?
    private var destinationLocationCity: Cities?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTextFields()
        self.hideKeyboardWhenTouchOutsideTextField()
        
    }
    
    var darkMode = false
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return darkMode ? .lightContent : .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("DEBUG: user info is \(User.currentUser?.id)")
        print("DEBUG: user info is \(User.currentUser?.username)")
        configureNavigationBar(withTitle: "Trip", largeTitleColor: #colorLiteral(red: 0.6274509804, green: 0.6274509804, blue: 0.6274509804, alpha: 1), tintColor: .white, navBarColor: #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1),
                               smallTitleColorWhenScrolling: .light, prefersLargeTitles: false)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        currentLocationTextField.endEditing(true)
        destinationTextField.endEditing(true)
    }
    
    // MARK: - configureUI()
    func configureUI(){
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        titleLabel.centerX(inView: contentView, topAnchor: contentView.topAnchor, paddingTop: 60)
        titleLabel.anchor(left: contentView.leftAnchor, right: contentView.rightAnchor)
        
        contentView.addSubview(mainContentView)
        mainContentView.anchor(top: titleLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor,
                               paddingTop: 20 , paddingLeft: 20, paddingBottom: 20 , paddingRight: 20, height: 450)
        
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
    
    func configureTextFields(){
        
        currentLocationTextField.inputView = fromCityPickerView
        currentLocationTextField.inputAccessoryView = toolbar
        currentLocationTextField.delegate = self
        destinationTextField.inputView = destinationCityPickerView
        destinationTextField.inputAccessoryView = toolbar
        destinationTextField.delegate = self
        timeToPickPackageTextField.inputView = timestampPickerView
        basePriceTextField.keyboardType = .asciiCapableNumberPad
    }
    
    
    // MARK: - Actions
    
    @objc func handleTimeSelected(_ sender: UIDatePicker){
        timeToPickPackageTextField.text = sender.date.convertDate(formattedString: .timeOnly)
    }
    
    
    @objc func handleDateAndTimeTapped(){
        if User.currentUser?.id == nil {
            showCustomAlertView(condition: .error)
            return
        }
        guard let currentLocationCity = currentLocationCity else {
            self.showAlertMessage("Error", "Please make sure you choose current city and destination")
            return
        }
        guard let destinationLocationCity = destinationLocationCity else {
            self.showAlertMessage("Error", "Please make sure you choose current city and destination")
            return
        }
        
        
        let tripEstimateArrival = getEstimatedTimeArrivalWith(currentLocation: currentLocationCity,
                                                              destinationLocation: destinationLocationCity)
        
        guard let currentCity  = currentLocationTextField.text else {return}
        guard let destinationCity  = destinationTextField.text else { return }
        guard let pickupLocation  = meetingForPickupTextField.text else { return }
        guard let pickupTime  = timeToPickPackageTextField.text else { return }
        guard let basePrice = basePriceTextField.text else {return}
        
        [basePrice, pickupTime, pickupLocation].forEach{if $0.isEmpty{
            self.showAlertMessage("Error", "Please make sure you fill out all the fields")
            return
        }}
        
        
        let trip = Trip(userID: "",
                        tripID: UUID().uuidString,
                        tripDepartureTime: "",
                        tripDepartureDate: "",
                        tripEstimateTimeArrival: tripEstimateArrival,
                        currentLocation: currentCity,
                        destinationLocation: destinationCity,
                        basePrice: basePrice,
                        packageType: "", timestamp: Date(),
                        packagePickupLocation: pickupLocation,
                        packagePickupTime: pickupTime)
        
        let dateAndTimeController = DateAndTimeController()
        dateAndTimeController.delegate = self
        dateAndTimeController.trip = trip
        dateAndTimeController.modalPresentationStyle = .fullScreen
        present(dateAndTimeController, animated: true, completion: nil)
    }
    
    @objc func handlePickViewDismissal(){
        currentLocationTextField.endEditing(true)
        destinationTextField.endEditing(true)
    }
    
    func getEstimatedTimeArrivalWith(currentLocation: Cities, destinationLocation: Cities) -> String {
        let currentLocation = CLLocation(latitude: currentLocation.locationCoordinates.0, longitude: currentLocation.locationCoordinates.1)
        let destinationLocation = CLLocation(latitude: destinationLocation.locationCoordinates.0, longitude: destinationLocation.locationCoordinates.1)
        let intervalDistance = (currentLocation.distance(from: destinationLocation)) / 1000
        guard let estimateTimeArrival = Double((String(format: "%.00f", intervalDistance))) else {return ""}
        return String(((estimateTimeArrival / 100.00).rounded(.awayFromZero)))
    }
    
    @objc fileprivate func handleAnonymousMode(_ sender: UIButton){
        SwiftEntryKit.dismiss() { [weak self] in
            self?.view.isUserInteractionEnabled = true
            self?.delegate?.dismissLoggingAnonymousOut(self!)
        }
    }
    
}


// MARK: - Picker time and
extension NewTripController : UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Cities.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Cities.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            currentLocationTextField.text = Cities.allCases[row].rawValue
            currentLocationCity = Cities.allCases[row]
        case 1:
            destinationTextField.text = Cities.allCases[row].rawValue
            destinationLocationCity = Cities.allCases[row]
        default:
            break
        }
    }
    
}


// MARK: - UITextFieldDelegate
extension NewTripController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
        case currentLocationTextField:
            guard let textCurrentLocation = currentLocationTextField.text else { return  }
            if textCurrentLocation.isEmpty {
                currentLocationTextField.text = Cities.allCases.first?.rawValue
            }
        case destinationTextField:
            guard let destination = destinationTextField.text else { return  }
            if destination.isEmpty {
                destinationTextField.text = Cities.allCases.first?.rawValue
            }
        default: break
        }
    }
}

// MARK: - DateAndTimeControllerDelegate
extension NewTripController: DateAndTimeControllerDelegate {
    func dismissDateAndTimeController(_ view: DateAndTimeController) {
        
        view.dismiss(animated: true) { self.delegate?.dismissNewTripView(self) }
    }
}


// MARK: - Cities enum
enum Cities: String, CaseIterable {
    case Arrass = "Arrass"
    case Riyadh = "Riyadh"
    case Qassim = "Qassim"
    case Makkah = "Makkah"
    case Dammam = "Dammam"
    case Abha = "Abha"
    case Jazan = "Jazan"
    case Madinah = "Madinah"
    case Buraidah = "Buraidah"
    case Tabuk = "Tabuk"
    case Hail = "Hail"
    case Najran = "Najran"
    case Sakaka = "Sakaka"
    
    var locationCoordinates: ( Double,  Double) {
        switch self {
        case .Arrass: return (25.8517, 43.5222)
            
        case .Riyadh: return (24.7136, 46.6753)
            
        case .Qassim: return (26.2078, 43.4837)
            
        case .Makkah: return (21.3891, 39.8579)
            
        case .Dammam: return (26.4207, 50.0888)
            
        case .Abha: return (18.2465, 42.5117)
            
        case .Jazan: return (16.8894, 42.5706)
            
        case .Madinah: return (24.5247, 39.5692)
            
        case .Buraidah: return (26.3592, 43.9818)
            
        case .Tabuk: return (28.3835, 36.5662)
            
        case .Hail: return (27.5114, 41.7208)
            
        case .Najran: return (17.5656, 44.2289)
            
        case .Sakaka: return (29.8780, 40.1043)
            
        }
    }
}

extension NewTripController {
    func showCustomAlertView(condition: Conditions) {
        configureCustomAlertUI()
        
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
    
    func configureCustomAlertUI(){
        view.isUserInteractionEnabled = false
        customAlertView.clipsToBounds = true
        customAlertView.addSubview(bottomContainerView)
        customAlertView.addSubview(animationView)
        
        animationView.centerX(inView: customAlertView, topAnchor: customAlertView.topAnchor, paddingTop: 0)
        bottomContainerView.anchor(top: animationView.bottomAnchor, left: customAlertView.leftAnchor, bottom: customAlertView.bottomAnchor, right: customAlertView.rightAnchor, paddingTop: -50)
        
        bottomContainerView.addSubview(messageLabel)
        messageLabel.anchor(top: bottomContainerView.topAnchor, left: bottomContainerView.leftAnchor, right: bottomContainerView.rightAnchor, paddingTop: 50)
        bottomContainerView.addSubview(dismissalButton)
        dismissalButton.anchor(left: bottomContainerView.leftAnchor, bottom: bottomContainerView.bottomAnchor, right: bottomContainerView.rightAnchor,
                               paddingLeft: 30, paddingBottom: 30, paddingRight: 30)
        
        customAlertView.backgroundColor = .clear
        customAlertView.layer.cornerRadius = 10
        customAlertView.setDimensions(height: 300, width: view.frame.width - 50)
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
            self?.delegate?.dismissLoggingAnonymousOut(self!)
        }
        attributes.entryBackground = .clear
        SwiftEntryKit.display(entry: customAlertView, using: attributes)
    }
}
