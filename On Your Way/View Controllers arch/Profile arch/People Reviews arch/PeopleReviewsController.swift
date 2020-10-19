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

private let reuseIdentifier = "PeopleReviewsCell"

class PeopleReviewsController: UIViewController {
    
    
    private lazy var reviewSheetPopOver = UIView()
    var attributes = EKAttributes.bottomNote
    
    
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
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func fetchReviews(){
        var sumAllReviews = 0.0
        ReviewService.shared.fetchPeopleReviews(userId: user.id) { [weak self]  in
            self?.reviews = $0
            self?.headerView.reviewRate.text = "\(self!.reviews.count)"
            self?.reviews.forEach{
                sumAllReviews += $0.rate
                self?.user.reviewsCount = Double(self!.reviews.count)
                self?.user.sumAllReviews = sumAllReviews
                saveUserLocally(self!.user)
                UserServices.shared.saveUserToFirestore(self!.user)
            }
            self?.tableView.reloadData()
        }
        configureWhenTableIsEmpty()
    }
    
    func canUserReview(){
        
        guard let reviewerId = Auth.auth().currentUser?.uid else { return }
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
    
    @objc func handleShowReview(){
        configureReviewSheet()
    }
    
    @objc func handleDismissPopView(){
        
        guard let reviewComment = reviewTextView.text else { return }
        let rate = ratingView.rating
        let reviewId = UUID().uuidString
        let review = Review(userID: User.currentId,
                            timestamp: Date(),
                            reviewComment: reviewComment,
                            rate: rate, reviewId: reviewId)
        PushNotificationService.shared.sendPushNotification(userIds: [user.id], body: "Someone wrote a review 🤩 check it out", title: "Rating 5/\(rate)")
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


// MARK: - show case table is empty
extension PeopleReviewsController {
    func configureWhenTableIsEmpty(){
        if self.reviews.isEmpty {
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] timer in
                if User.currentId == self?.user.id {
                    self?.tableView.setEmptyView(title: "No Reviews",
                                                 titleColor: .white,
                                                 message: "No one has wrote a review about you\nOnce you accept people packages , then they can submit reviews")
                } else if User.currentId != self?.user.id {
                    self?.tableView.setEmptyView(title: "No Reviews",
                                                 titleColor: .white,
                                                 message: "No one has wrote a review about \(self!.user.username)")
                } else {self?.tableView.restore()}
            }
        }
    }
}
