//
//  DateAndTimeController.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/27/20.
//

import UIKit
import FSCalendar
import ProgressHUD

// MARK: - protocol
protocol DateAndTimeControllerDelegate: class {
    func dismissDateAndTimeController(_ view: DateAndTimeController)
}


class DateAndTimeController: UIViewController, UIScrollViewDelegate {
    
    
    // MARK: - Delegate
    weak var delegate: DateAndTimeControllerDelegate?
    
    // MARK: - dynamicScreen
    var dynamicScreen: CGFloat {
        var height: CGFloat = 200
        switch UIScreen.main.bounds.height {
        // iPhone XS Max + 11
        case 896:
            height = 120
        // iPhone 11 pro
        case 812:
            height = 200
        // iPhone 8+
        case 736:
            height = 160
        // iPhone 8
        case 667:
            height = 230
        default:
            break
        }
        return height
    }
    
    
    
    // MARK: - scrollView
    private lazy var contentSizeView = CGSize(width: self.view.frame.width,
                                              height: self.view.frame.height + dynamicScreen)
    
    
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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "رحلتي"
        label.textAlignment = .center
        label.textColor = .blueLightFont
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.setHeight(height: 80)
        label.clipsToBounds = true
        label.layer.masksToBounds = false
        label.setupShadow(opacity: 0.2, radius: 3, offset: CGSize(width: 0.0, height: 8.0), color: .black)
        return label
    }()
    
    private lazy var tripDetailsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "اعدادات الرحلة"
        label.textAlignment = .right
        label.textColor = .blueLightFont
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.setHeight(height: 40)
        return label
    }()
    
    private lazy var calendarView: FSCalendar = {
        let calendarView = FSCalendar()
        calendarView.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        calendarView.scrollDirection = .horizontal
        calendarView.setHeight(height: UIScreen.main.bounds.height > 800 ? 400 : 300)
        calendarView.delegate = self
        calendarView.locale = Locale(identifier: "ar")
        calendarView.dataSource = self
        calendarView.appearance.titleFont = UIFont.systemFont(ofSize: 17)
        
        calendarView.appearance.headerTitleColor = .white // monthly header color
        calendarView.appearance.weekdayTextColor = .gray // weekly header color
        
        calendarView.appearance.titlePlaceholderColor = UIColor.white.withAlphaComponent(0.1)
        // today configure selection
        calendarView.appearance.todayColor = .blueLightIcon
        calendarView.appearance.titleTodayColor = .white
        calendarView.appearance.todaySelectionColor = .blueLightIcon
        
        // selection
        calendarView.appearance.titleSelectionColor = .white
        calendarView.appearance.selectionColor = #colorLiteral(red: 0.3568627451, green: 0.4745098039, blue: 0.4431372549, alpha: 1)
        
        calendarView.appearance.titleWeekendColor = #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
        calendarView.appearance.titleDefaultColor = .white // color your week days
        
        calendarView.clipsToBounds = true
        calendarView.layer.masksToBounds = false
        calendarView.layer.cornerRadius = 20
        calendarView.setupShadow(opacity: 0.2, radius: 3, offset: CGSize(width: 0.0, height: 8.0), color: .black)
        return calendarView
    }()
    
    private lazy var dateTextField: UITextField = {
        let textField = CustomTextField(textColor: .white, placeholder: "اختر تاريخ سفرتك من التقويم",
                                        placeholderColor: .blueLightFont, placeholderAlpa: 1, isSecure: false)
        textField.adjustsFontSizeToFitWidth = true
        return textField
    }()
    
    private lazy var dateTextContainerView = CustomContainerView(image: UIImage(systemName: "calendar.badge.plus"), textField: dateTextField,
                                                                 iconTintColor: .blueLightFont, dividerViewColor: .blueLightIcon,
                                                                 dividerAlpa: 1, setViewHeight: 50, iconAlpa: 1, backgroundColor: .clear)
    
    private lazy var timeTextField = CustomTextField(textColor: .blueLightFont, placeholder: "اعدادات الوقت",
                                                     placeholderColor: .blueLightFont, placeholderAlpa: 1, isSecure: false)
    
    
    private lazy var timeContainerView = CustomContainerView(image: UIImage(systemName: "clock.fill"), textField: timeTextField,
                                                             iconTintColor: .blueLightFont, dividerViewColor: .clear, dividerAlpa: 1, setViewHeight: 50, iconAlpa: 1, backgroundColor: .clear)
    
    
    private lazy var packageInfoTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .right
        textView.textColor = .blueLightFont
        textView.setHeight(height: 100)
        textView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        textView.layer.cornerRadius = 10
        textView.keyboardAppearance = .dark
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = self
        textView.clipsToBounds = true
        return textView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tripDetailsTitleLabel,
                                                       dateTextContainerView,
                                                       timeContainerView,
                                                       packageInfoTextView,
                                                       submitTripe])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.addSubview(stackView)
        stackView.anchor(top: view.topAnchor, left: view.leftAnchor,
                         bottom: view.bottomAnchor, right: view.rightAnchor,
                         paddingLeft: 14, paddingRight: 14)
        view.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        return view
    }()
    
    private lazy var submitTripe: UIButton = {
        let button = UIButton(type: .system)
        button.setHeight(height: 60)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("تاكيد ", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
        button.layer.cornerRadius = 60 / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleSubmitNewTrip), for: .touchUpInside)
        return button
    }()
    
    private lazy var dismissView: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.down"), for: .normal)
        button.setDimensions(height: 50, width: 50)
        button.tintColor = .white
        button.layer.cornerRadius = 50 / 2
        button.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.5, radius: 3, offset: CGSize(width: 0.0, height: 8.0), color: .black)
        return button
    }()
    
    private let blurView : UIVisualEffectView = {
        let blurView = UIBlurEffect(style: .regular)
        let view = UIVisualEffectView(effect: blurView)
        return view
    }()
    
    private lazy var timestampPickerView: UIDatePicker = {
        let pickerView = UIDatePicker()
        pickerView.datePickerMode = .time
        pickerView.preferredDatePickerStyle = .wheels
        pickerView.addTarget(self, action: #selector(handleTimeSelected(_ :)), for: .valueChanged)
        return pickerView
    }()
    
    private lazy var toolbar: UIToolbar = {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barTitle = UIBarButtonItem(title: "اختر وقت السفر", style: .plain, target: nil, action: nil)
        let dismissButton = UIBarButtonItem(title: "تم", style: .plain, target: self,
                                            action: #selector(handlePickViewDismissal))
        barTitle.isEnabled = false
        barTitle.tintColor = .white
        toolBar.barStyle = .black
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        toolBar.setItems([barTitle,flexButton, dismissButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }()
    
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "ماذا تستطيع ان تحمل معك في سفرك ؟ \n حقائب ، صناديق ، بضائع ثقيلة"
        label.textAlignment = .center
        label.textColor = .blueLightFont
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    
    // MARK: - Properties
    var trip: Trip?
    
    
    
    // MARK: - Lifecyce
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        self.hideKeyboardWhenTouchOutsideTextField()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    
    
    // MARK: - configureUI()
    func configureUI(){
        view.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(dismissView)
        dismissView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 60, paddingLeft: 36)
        contentView.addSubview(titleLabel)
        titleLabel.anchor(top: dismissView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor,
                          paddingLeft: 20, paddingRight: 20)
        
        contentView.addSubview(calendarView)
        calendarView.anchor(top: titleLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingLeft: 12, paddingRight: 12)
        contentView.addSubview(bottomContainerView)
        bottomContainerView.centerX(inView: calendarView, topAnchor: calendarView.bottomAnchor, paddingTop: 10)
        bottomContainerView.anchor(left: contentView.leftAnchor, right: contentView.rightAnchor)
        
        timeTextField.delegate = self
        timeTextField.inputView = timestampPickerView
        timeTextField.inputAccessoryView = toolbar
        dateTextField.isUserInteractionEnabled = false
        
        packageInfoTextView.addSubview(placeholderLabel)
        placeholderLabel.anchor(top: packageInfoTextView.topAnchor, left: packageInfoTextView.leftAnchor,
                                paddingTop: 8, paddingLeft: 42)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChanger), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    
    
    // MARK: - Actions
    @objc func handlePickViewDismissal(){
        timeTextField.endEditing(true)
    }
    
    @objc func handleTimeSelected(_ sender: UIDatePicker){
        timeTextField.text = sender.date.convertDate(formattedString: .timeOnly)
    }
    
    
    
    @objc func handleSubmitNewTrip(){
        guard var trip = trip else { return  }
        guard let departureTime = timeTextField.text else { return }
        guard let departureDate = dateTextField.text else { return }
        guard let packageType = packageInfoTextView.text else { return }
        
        if departureDate.isEmpty {
            self.showAlertMessage("حقل فارغ", "الرجاء التاكد من اختيار تاريخ السفر")
            return
        }
        
        if departureTime.isEmpty {
            self.showAlertMessage("حقل فارغ", "الرجاء التاكد من اختيار وقت السفر")
            return
        }
        
        if packageType.isEmpty {
            self.showAlertMessage("حق فارغ", "الرجاء التاكد من كتابه البضائع المسموحة بالنقل")
            return
        }
        
        trip.userID = User.currentId
        trip.tripDepartureTime = departureTime
        trip.packageType = packageType
        trip.tripDepartureDate = departureDate
        
        self.showBlurView()
        self.showLoader(true, message: "الرجاء الانتظار...")
        TripService.shared.saveTripToFirestore(trip) { [weak self] error in
            
            if let error = error {
                self?.showBlurView()
                self?.showLoader(false)
                self?.showAlertMessage("Error", error.localizedDescription)
                return
            }
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                self?.removeBlurView()
                self?.showLoader(false)
                self?.showBanner(message: "تم الاعلان عن رحلتك", state: .success,
                                 location: .top, presentingDirection: .vertical, dismissingDirection: .vertical,
                                 sender: self!)
            }
            
            Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { [weak self] timer in
                self?.delegate?.dismissDateAndTimeController(self!)
            }
        }
    }
    
    @objc func handleTextInputChanger(){
        placeholderLabel.isHidden = !packageInfoTextView.text.isEmpty
    }
    
    @objc func handleDismissal(){
        dismiss(animated: true, completion: nil)
    }
    
    
}

// MARK: - extension




// MARK: - Show selected date in label
extension DateAndTimeController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateTextField.text = date.convertDate(formattedString: .formattedType2)
        
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateTextField.text = date.convertDate(formattedString: .formattedType2)
    }
    
}
//MARK:-Prevent user choosing past date
extension DateAndTimeController: FSCalendarDataSource {
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
}


// MARK: - UITextFieldDelegate
extension DateAndTimeController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = textField.text else { return  }
        if text.isEmpty {
            timeTextField.text = timestampPickerView.date.convertDate(formattedString: .timeOnly)
        }
    }
}

// MARK: - UITextViewDelegate
extension DateAndTimeController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 150
    }
}
