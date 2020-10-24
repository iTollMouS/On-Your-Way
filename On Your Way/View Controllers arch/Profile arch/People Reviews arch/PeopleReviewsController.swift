//
//  PeopleReviewsController.swift
//  OnMyWay
//
//  Created by Tariq Almazyad on 9/29/20.
//

import UIKit
import SwiftEntryKit
import Cosmos
import Firebase
import Lottie

private let reuseIdentifier = "PeopleReviewsCell"

protocol PeopleReviewsControllerDelegate: class {
    func handleLoggingOutAnonymousUser(_ view: PeopleReviewsController)
}

class PeopleReviewsController: UIViewController {
    
    weak var delegate: PeopleReviewsControllerDelegate?
    
    private lazy var reviewSheetPopOver = UIView()
    var attributes = EKAttributes.bottomNote
    
    
    private lazy var customAlertView = UIView()
    private lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.2156862745, green: 0.2156862745, blue: 0.2156862745, alpha: 1)
        view.layer.cornerRadius = 30
        return view
    }()
    
    private lazy var animationView: AnimationView = {
        let animationView = AnimationView()
        animationView.setDimensions(height: 100, width: 100)
        animationView.clipsToBounds = true
        animationView.layer.cornerRadius = 100 / 5
        animationView.backgroundColor = .clear
        animationView.contentMode = .scaleAspectFill
        return animationView
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
    
    
    
    
    
    private lazy var writeReviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
        button.setTitle("Write a review", for: .normal)
        button.setDimensions(height: 50, width: view.frame.width - 50)
        button.layer.cornerRadius = 50 / 2
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.setTitleColor(#colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1), for: .normal)
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.1, radius: 10, offset: CGSize(width: 0.0, height: 3), color: .white)
        button.addTarget(self, action: #selector(handleShowReview), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        view.setHeight(height: 100)
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        view.setupShadow(opacity: 0.1, radius: 10, offset: CGSize(width: 0.0, height: 8.0), color: .white)
        view.addSubview(writeReviewButton)
        writeReviewButton.centerX(inView: view, topAnchor: view.topAnchor, paddingTop: 16)
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        tableView.register(PeopleReviewsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = headerView
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = headerView
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = 1000
        return tableView
    }()
    
    private lazy var reviewLabel: UILabel = {
        let label = UILabel()
        label.text = "How was Tariq Almazyad\ndealing with your order"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.setHeight(height: 60)
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var drawerView: UIView = {
        let view = UIView()
        view.setDimensions(height: 5, width: 60)
        view.layer.cornerRadius = 2
        view.backgroundColor = .gray
        return view
    }()
    
    private lazy var topDividerView: UIView = {
        let view = UIView()
        view.setHeight(height: 1)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return view
    }()
    
    private lazy var bottomDividerView: UIView = {
        let view = UIView()
        view.setHeight(height: 1)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return view
    }()
    
    private lazy var ratingView: CosmosView = {
        let view = CosmosView()
        view.settings.fillMode = .half
        view.settings.filledImage = #imageLiteral(resourceName: "RatingStarFilled").withRenderingMode(.alwaysOriginal)
        view.settings.emptyImage = #imageLiteral(resourceName: "RatingStarEmpty").withRenderingMode(.alwaysOriginal)
        view.settings.starSize = 26
        view.settings.totalStars = 5
        view.settings.textMargin = 10
        view.settings.textFont = .boldSystemFont(ofSize: 20)
        view.settings.textColor = .white
        view.settings.starMargin = 3.0
        view.rating = 0
        view.text = "No Reviews"
        view.backgroundColor = .clear
        view.setDimensions(height: 30, width: 180)
        return view
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Add comment ......"
        label.textAlignment = .left
        label.textColor = .gray
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var reviewTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.textColor = .white
        textView.delegate = self
        textView.setHeight(height: 200)
        textView.backgroundColor = .clear
        textView.layer.cornerRadius = 10
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.clipsToBounds = true
        tableView.tableFooterView = UIView()
        textView.keyboardAppearance = .dark
        textView.addSubview(placeholderLabel)
        placeholderLabel.anchor(top: textView.topAnchor, left: textView.leftAnchor,
                                paddingTop: 8, paddingLeft: 8)
        return textView
    }()
    
    private lazy var submitReviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.alpha = 0
        button.transform = .init(scaleX: 0.0, y: 0.01)
        button.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.4745098039, blue: 0.4431372549, alpha: 1)
        button.setTitle("Submit Review", for: .normal)
        button.setDimensions(height: 50, width: view.frame.width - 50)
        button.layer.cornerRadius = 50 / 2
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.setTitleColor(#colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1), for: .normal)
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.2, radius: 10, offset: CGSize(width: 0.0, height: 3), color: .white)
        button.addTarget(self, action: #selector(handleDismissPopView), for: .touchUpInside)
        return button
    }()
    
    
    private var user: User{
        didSet{ headerView.user = user}
    }
    
    private var reviews = [Review]()
    private lazy var headerView = PeopleReviewHeader(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        configureTableView()
        configureReviewSheetPopOver()
        self.hideKeyboardWhenTouchOutsideTextField()
        fetchUser()
        headerView.user = user
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchReviews()
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.tabBar.isHidden = true
        canUserReview()
        tabBarController?.dismissPopupBar(animated: true, completion: nil)
    }
    
    
    var darkMode = false
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return darkMode ? .lightContent : .lightContent
    }
    
    func fetchReviews(){
        var sumAllReviews = 0.0
        DispatchQueue.main.async { [weak self] in
            ReviewService.shared.fetchPeopleReviews(userId: self!.user.id) { [weak self]  in
                self?.reviews = $0
                self?.headerView.reviewRate.text = "\(self!.reviews.count)"
                self?.reviews.forEach{
                    sumAllReviews += $0.rate
                    self?.user.reviewsCount = Double(String(format: "%.02f", Double(self!.reviews.count)))!
                    self?.user.sumAllReviews = sumAllReviews
                }
                self?.tableView.reloadData()
            }
        }
        
    }
    
    func canUserReview(){
        
        guard let reviewerId = Auth.auth().currentUser?.uid else {
            showCustomAlertView(condition: .error)
            view.isUserInteractionEnabled = false
            return
            
        }
        
        DispatchQueue.main.async { 
            TripService.shared.fetchMyRequest(userId: reviewerId) { [weak self] packages in
                if packages.isEmpty{
                    self?.writeReviewButton.setTitle("You can not review \(self!.user.username)", for: .normal)
                    self?.writeReviewButton.isEnabled = false
                } else {
                    packages.forEach{
                        if $0.packageStatus == .packageIsAccepted {
                            self?.submitReviewButton.setTitle("Write a review for \(self!.user.username)", for: .normal)
                            self?.updateReviewOnTouch()
                        } else {
                            self?.writeReviewButton.setTitle("You can not review \(self!.user.username)", for: .normal)
                            self?.writeReviewButton.isEnabled = false
                        }
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func fetchUser(){
        guard let uid = Auth.auth().currentUser?.uid else { return  }
        if user.id == uid {
            self.tableView.reloadData()
            self.tableView.fillSuperview()
            self.buttonContainerView.isHidden = true
        }
        
    }
    
    func updateReviewOnTouch(){
        ratingView.didTouchCosmos = { [self] in ratingView.text = "\($0)" }
        ratingView.didFinishTouchingCosmos = { [self] in  ratingView.text = "\($0)" }
    }
    
    
    func configureReviewSheetPopOver(){
        
        reviewSheetPopOver.addSubview(drawerView)
        drawerView.centerX(inView: reviewSheetPopOver, topAnchor: reviewSheetPopOver.topAnchor, paddingTop: 10)
        
        reviewSheetPopOver.addSubview(reviewLabel)
        reviewLabel.anchor(top: drawerView.topAnchor, left: reviewSheetPopOver.leftAnchor,
                           right: reviewSheetPopOver.rightAnchor, paddingTop: 12)
        
        reviewSheetPopOver.addSubview(ratingView)
        ratingView.centerX(inView: reviewLabel, topAnchor: reviewLabel.bottomAnchor, paddingTop: 12)
        
        reviewSheetPopOver.addSubview(topDividerView)
        topDividerView.anchor(top: ratingView.bottomAnchor, left: reviewSheetPopOver.leftAnchor,
                              right: reviewSheetPopOver.rightAnchor, paddingTop: 20)
        
        reviewSheetPopOver.addSubview(reviewTextView)
        reviewTextView.anchor(top: topDividerView.bottomAnchor, left: reviewSheetPopOver.leftAnchor, right: reviewSheetPopOver.rightAnchor)
        
        reviewSheetPopOver.addSubview(submitReviewButton)
        submitReviewButton.centerX(inView: reviewTextView, topAnchor: reviewTextView.bottomAnchor, paddingTop: 70)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChanger), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @objc func handleTextInputChanger(){
        placeholderLabel.isHidden = !reviewTextView.text.isEmpty
        if !reviewTextView.text.isEmpty {
            submitReviewButton.setTitle("Submit Review", for: .normal)
            submitReviewButton.transform = .identity
            submitReviewButton.alpha = 1
        } else {
            submitReviewButton.alpha = 0
            submitReviewButton.transform = .init(scaleX: 0.0, y: 0.01)
        }
    }
    
    @objc func handleAnonymousMode(){
        SwiftEntryKit.dismiss() { [weak self] in
            self?.view.isUserInteractionEnabled = true
            self?.delegate?.handleLoggingOutAnonymousUser(self!)
        }
    }
    
    @objc func handleShowReview(){
        configureReviewSheet()
    }
    
    func configureTableView(){
        view.addSubview(buttonContainerView)
        buttonContainerView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: buttonContainerView.topAnchor, right: view.rightAnchor)
    }
    
    func configureNavBar(){
        self.title = "Reviews"
        view.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
    }
}

extension PeopleReviewsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PeopleReviewsCell
        cell.review = reviews[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let selectedReview = reviews[indexPath.row]
        if uid == selectedReview.userID {
            if editingStyle == .delete {
                DispatchQueue.main.async { [weak self] in
                    ReviewService.shared.deleteMyReview(userId: self!.user.id, review: selectedReview) { error in
                        print("DEBUG: success!!!!")
                        self?.reviews.remove(at: indexPath.row)
                        self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
}

extension PeopleReviewsController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 300
    }
}


extension PeopleReviewsController {
    
    func configureReviewSheet(){
        
        reviewSheetPopOver.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        reviewSheetPopOver.layer.cornerRadius = 10
        reviewSheetPopOver.setDimensions(height: 800, width: view.frame.width)
        attributes.screenBackground = .visualEffect(style: .dark)
        attributes.positionConstraints.safeArea = .overridden
        attributes.positionConstraints.verticalOffset = -300
        attributes.windowLevel = .normal
        attributes.position = .bottom
        attributes.precedence = .override(priority: .max, dropEnqueuedEntries: false)
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches // do something when the user touch the card e.g .dismiss make the card dismisses on touch
        attributes.screenInteraction = .dismiss // do something when the user touch the screen e.g .dismiss make the card dismisses on touch
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.statusBar = .light
        attributes.lifecycleEvents.willAppear = { [self] in
            // Executed before the entry animates inside
            ratingView.rating = 3
            ratingView.text = "\(3.0)"
            
        }
        attributes.entryBackground = .visualEffect(style: .dark)
        SwiftEntryKit.display(entry: reviewSheetPopOver, using: attributes)
    }
    
    @objc func handleDismissPopView(){
        
        guard let reviewComment = reviewTextView.text else { return }
        let rate = ratingView.rating
        let reviewId = UUID().uuidString
        let review = Review(userID: User.currentId,
                            timestamp: Date(),
                            reviewComment: reviewComment,
                            rate: rate, reviewId: reviewId)
        user.sumAllReviews += rate
        user.reviewsCount += 1
        PushNotificationService.shared.sendPushNotification(userIds: [user.id], body: "Someone wrote a review 🤩 check it out", title: "Rating 5/ \(rate)")
        UserServices.shared.saveUserToFirestore(user)
        ReviewService.shared.uploadNewReview(userId: user.id, review: review) { error in
            if let error = error {
                print("DEBUG: error while \(error.localizedDescription)")
                return
            }
            print("DEBUG:: success")
        }
        SwiftEntryKit.dismiss(.displayed) { [self] in reviewTextView.text = "" }
        self.fetchReviews()
        self.tableView.reloadData()
        
    }
    
}

extension PeopleReviewsController {
    
    
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
            self?.delegate?.handleLoggingOutAnonymousUser(self!)
        }
        attributes.entryBackground = .clear
        SwiftEntryKit.display(entry: customAlertView, using: attributes)
    }
}

// MARK: - show case table is empty
extension PeopleReviewsController {
    func configureWhenTableIsEmpty(){
        DispatchQueue.main.async { [weak self] in
        if self!.reviews.isEmpty {
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] timer in
                if User.currentId == self?.user.id {
                    self?.tableView.setEmptyView(title: "No Reviews",
                                                 titleColor: .white,
                                                 message: "No one has wrote a review about you.\nOnce you accept people packages, people they can submit reviews")
                } else if User.currentId != self?.user.id {
                    self?.tableView.setEmptyView(title: "No Reviews",
                                                 titleColor: .white,
                                                 message: "No one has wrote a review about \(self!.user.username)")
                } else {self?.tableView.restore()}
            }
        }
        }
    }
}
