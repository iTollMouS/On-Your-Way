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


// MARK: - protocol
protocol PeopleReviewsControllerDelegate: class {
    func handleLoggingOutAnonymousUser(_ view: PeopleReviewsController)
}

class PeopleReviewsController: UIViewController {
    
    
    // MARK: - delegate
    weak var delegate: PeopleReviewsControllerDelegate?
    
    
    
    
    // MARK: - Properties
    private lazy var reviewSheetPopOver = UIView()
    var attributes = EKAttributes.bottomNote
    
    private lazy var writeReviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
        button.setTitle("اكتب تقييم", for: .normal)
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
    
    let refreshController = UIRefreshControl()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        tableView.register(PeopleReviewsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = headerView
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
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
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        configureTableView()
        configureReviewSheetPopOver()
        self.hideKeyboardWhenTouchOutsideTextField()
        configureRefreshController()
        fetchUser()
        configureNavBar()
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
    
    // MARK: - configureTableView()
    fileprivate func configureTableView(){
        view.addSubview(buttonContainerView)
        buttonContainerView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: buttonContainerView.topAnchor, right: view.rightAnchor)
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    }
    
    fileprivate func configureNavBar(){
        self.title = "التقييمات"
        view.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "رجوع", style: .plain, target: self, action: #selector(handleDismissalView))
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
    }
    
    
    
    // MARK: - fetchReviews()
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
    
    // MARK: - canUserReview()
    func canUserReview(){
        
        guard let reviewerId = Auth.auth().currentUser?.uid else {
            view.isUserInteractionEnabled = false
            CustomAlertMessage(condition: .error,
                               messageTitle: "تصفح بدون حساب",
                               messageBody: "لاتستطيع ارسال شحنه ، او المحادثه بدون حساب \n الرجاء الرجوع للصفحة الرئيسية لانشاء حساب ",
                               size: CGSize(width: view.frame.width - 50, height: 280)) { [weak self] in
                self?.delegate?.handleLoggingOutAnonymousUser(self!)
                return
            }
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
    
    
    // MARK: - configureRefreshController
    func configureRefreshController(){
        refreshController.tintColor = .white
        refreshController.attributedTitle = NSAttributedString(string: "اسحب للأسفل للتحديث", attributes:
                                                                [.foregroundColor: UIColor.white])
        tableView.refreshControl = refreshController
    }
    
    
    // MARK: - fetchUser()
    func fetchUser(){
        guard let uid = Auth.auth().currentUser?.uid else { return  }
        if user.id == uid {
            self.tableView.reloadData()
            self.tableView.fillSuperview()
            self.buttonContainerView.isHidden = true
        }
        
    }
    
    
    // MARK: - updateReviewOnTouch()
    func updateReviewOnTouch(){
        ratingView.didTouchCosmos = { [self] in ratingView.text = "\($0)" }
        ratingView.didFinishTouchingCosmos = { [self] in  ratingView.text = "\($0)" }
    }
    
    
    // MARK: - configureReviewSheetPopOver()
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
    
    
    // MARK: - handleTextInputChanger()
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
    
    // MARK: - handleShowReview()
    @objc func handleShowReview(){
        configureReviewSheet()
    }
    
    @objc fileprivate func handleDismissalView(){
        dismiss(animated: true, completion: nil)
    }
    
}

extension PeopleReviewsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] time in
            DispatchQueue.main.async { [weak self] in
                if self?.reviews.isEmpty ?? false {
                    self?.tableView.setEmptyView(title: "لايوجد اي تقييم",
                                                 titleColor: .white,
                                                 message: "العملاء يرسلون تقييمات المسافرين عندما يتم قبول طلباتهم")
                } else { tableView.restore() }
            }
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let selectedReview = reviews[indexPath.row]
        if selectedReview.userID == User.currentId {
            let deleteAction = deleteMyReview(review: selectedReview ,at: indexPath)
            return UISwipeActionsConfiguration(actions: [deleteAction])
        } else {
            return nil
        }
    }
    
    func deleteMyReview(review: Review ,at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "ازالة") { [weak self] (action, view, completion) in
            let alert = UIAlertController(title: nil, message: "هل انت متاكد من ازاله التقييم؟", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "مسح التقييم", style: .destructive, handler: { [weak self] (alertAction) in
                DispatchQueue.main.async { [weak self] in
                    self?.user.sumAllReviews -= review.rate
                    self?.user.reviewsCount -= Double(self!.reviews.count - 1)
                    UserServices.shared.saveUserToFirestore(self!.user)
                    ReviewService.shared.deleteMyReview(userId: self!.user.id, review: review) { error in
                        if let error = error {
                            CustomAlertMessage(condition: .error, messageTitle: "حدث خطا ما",
                                               messageBody: "حدث خطا ما ، الرجاء التاكد من الاتصال بالانترنت\(error.localizedDescription)",
                                               size: CGSize(width: view.frame.width - 50, height: 280)) { [weak self] in
                            }
                            return
                        }
                        print("DEBUG: success!!!!")
                        self?.reviews.remove(at: indexPath.row)
                        self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                        self?.tableView.reloadData()
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "الغاء", style: .cancel, handler: nil))
            self!.present(alert, animated: true, completion: nil)
        }
        return action
    }

        func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let selectedReview = reviews[indexPath.row]
            if selectedReview.userID == User.currentId {
                let reportAction = reportReview(review: selectedReview ,at: indexPath)
                return UISwipeActionsConfiguration(actions: [reportAction])
            } else {
                return nil
            }
        }
    
 
    
    func reportReview(review: Review ,at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "ابلاغ عن مخالفه") { [weak self] (action, view, completion) in
            let alert = UIAlertController(title: nil, message: "هل انت متاكد من الابلاغ غن مخالفه؟", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "الابلاغ", style: .destructive, handler: { [weak self] (alertAction) in
                DispatchQueue.main.async { [weak self] in
                    ReviewService.shared.editMyReview (userId: self!.user.id, review: review) { error in
                        print("DEBUG: success!!!!")
                        self?.tableView.updateRow(row: indexPath.row)
                        self?.tableView.reloadData()
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "الغاء", style: .cancel, handler: nil))
            self!.present(alert, animated: true, completion: nil)
        }
        return action
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            fetchReviews()
            refreshController.endRefreshing()
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
        reviewLabel.text = "كيف كانت تجربتك مع \(user.username)"
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
        PushNotificationService.shared.sendPushNotification(userIds: [user.id], body: "احدهم كتب تقييم عنك 🤩", title: "Rating 5/ \(rate)")
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
