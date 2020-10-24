//
//  ChatViewController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/16/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift
import Firebase
import IQKeyboardManagerSwift
import LNPopupController
import SwiftEntryKit


class ChatViewController: MessagesViewController {
    
    // MARK: - Properties
    
    lazy var cameraButton = createButton(tagNumber: 0, title: "Camera", backgroundColor: #colorLiteral(red: 0.337254902, green: 0.337254902, blue: 0.337254902, alpha: 1), colorAlpa: 0.6, systemName: "camera.fill")
    lazy var libraryButton = createButton(tagNumber: 1, title: "Library", backgroundColor: #colorLiteral(red: 0.3568627451, green: 0.4078431373, blue: 0.4901960784, alpha: 1), colorAlpa: 0.6, systemName: "photo")
    lazy var locationButton = createButton(tagNumber: 2, title: "Location", backgroundColor: .blueLightIcon, colorAlpa: 0.6, systemName: "mappin.and.ellipse")
    lazy var cancelButton = createButton(tagNumber: 3, title: "Cancel", backgroundColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), colorAlpa: 0.6, systemName: "xmark")
    
    private lazy var customAlertView = UIView()
    private lazy var topDividerCustomAlertView = UIView()
    var attributes = EKAttributes.bottomNote
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cameraButton,
                                                       libraryButton,
                                                       locationButton,
                                                       cancelButton])
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.distribution = .fillEqually
        stackView.setHeight(height: 300)
        return stackView
    }()
    
    
    private lazy var checkMarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark.seal.fill"), for: .normal)
        button.tintColor = .systemGreen
        button.backgroundColor = .white
        button.imageView?.setDimensions(height: 14, width: 14)
        button.setDimensions(height: 14, width: 14)
        button.layer.cornerRadius = 14 / 2
        button.clipsToBounds = true
        button.isHidden = true
        return button
    }()
    
    
    
    let leftBarButtonLeft: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Share Media"
        label.font = UIFont.systemFont(ofSize: 18)
        label.setHeight(height: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    
    
    let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 140, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 12)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    
    let subTitleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 22, width: 140, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 12)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    private let blurView : UIVisualEffectView = {
        let blurView = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurView)
        return view
    }()
    
    private var chatRoomId = ""
    private var recipientId = ""
    private var recipientName = ""
    private let refreshController = UIRefreshControl()
    private let realm = try! Realm()
    var allLocalMessages: Results<LocalMessage>!
    private let micButton = InputBarButtonItem()
    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    var gallery = GalleryController()
    
    var typingCounter = 0
    
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    // for realm to listen to any changes
    var notificationToken: NotificationToken?
    
    
    // create an array
    var mkMessages: [MKMessage] = []
    
    init(chatRoomId: String, recipientId: String, recipientName: String) {
        
        self.chatRoomId =  chatRoomId
        self.recipientId =  recipientId
        self.recipientName =  recipientName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadChats()
        configureMessageInputBar()
        configureLeftBarButton()
        listenToNewChats()
        listenForOldChats()
        createTypingObserver()
        configureMessageCollectionView()
        listenForReadStatusChange()
        
    }
    
    fileprivate func fetchUser(){
        UserServices.shared.fetchUser(userId: recipientId) { [weak self] user in
            self?.checkMarkButton.isHidden = !user.isUserVerified
        }
    }
    
    var darkMode = false
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return darkMode ? .lightContent : .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("DEBUG: user info is \(User.currentUser?.id)")
        print("DEBUG: user info is \(User.currentUser?.username)")
        IQKeyboardManager.shared.enable = false
        configureNavBar()
        fetchUser()
        tabBarController?.dismissPopupBar(animated: true, completion: nil)
        
    }
    
    
    
    fileprivate func configureLeftBarButton(){
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain,
                                                                  target: self, action: #selector(handleDismissal))]
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stackView.axis = .vertical
        leftBarButtonLeft.addSubview(checkMarkButton)
        checkMarkButton.centerY(inView: leftBarButtonLeft)
        
        leftBarButtonLeft.addSubview(stackView)
        stackView.centerY(inView: checkMarkButton, leftAnchor: checkMarkButton.rightAnchor, paddingLeft: -6)
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonLeft)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        titleLabel.text = "    \(recipientName)"
    }
    
    
    // MARK: - handleDismissal
    @objc fileprivate func handleDismissal(){
        IQKeyboardManager.shared.enable = true
        RecentChatService.shared.resetRecentCounter(chatRoomId: chatRoomId)
        removeListener()
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - configureNavBar
    fileprivate func configureNavBar(){
        
        configureNavigationBar(withTitle: "", largeTitleColor: .white, tintColor: .white,
                               navBarColor: #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1), smallTitleColorWhenScrolling: .dark,
                               prefersLargeTitles: false)
    }
    
    
    
    // step 1 to configure the chat delegate s
    // MARK: - configureMessageCollectionView
    fileprivate func configureMessageCollectionView(){
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        messagesCollectionView.refreshControl = refreshController
        refreshController.tintColor = .white
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:
                                                                [.foregroundColor: UIColor.white])
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
    }
    
    
    // MARK: - configureMessageInputBar
    fileprivate func configureMessageInputBar(){
        messageInputBar.delegate = self
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { [weak self] item in
            self?.actionDisplayButtonAttachments()
        }
        
        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.inputTextView.isImagePasteEnabled = true
        messageInputBar.backgroundView.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        messageInputBar.inputTextView.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        messageInputBar.inputTextView.keyboardAppearance = .dark
        messageInputBar.inputTextView.layer.cornerRadius = 20
        updateMicButtonStatus(show: true)
    }
    
    // MARK: - Actions
    
    @objc fileprivate func handleActionAttachment(_ sender: UIButton){
        
        switch sender.tag {
        // camera
        case 0:
            self.showImageGallery(camera: true)
            SwiftEntryKit.dismiss()
        // camera roll
        case 1:
            self.showImageGallery(camera: false)
            SwiftEntryKit.dismiss()
        // location
        case 2:
            if let _ = LocationManager.shared.currentLocation {
                self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: kLOCATION)
            }
            SwiftEntryKit.dismiss()
        // cancel
        case 3:
            SwiftEntryKit.dismiss()
        default:
            break
        }
    }
    
    // we send any outgoing message
    // responsible to pop the messages
    func updateMicButtonStatus(show: Bool){
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    // MARK: - loadChats
    fileprivate func loadChats(){
        // we get the local message from realm by providing the key remember chatRoomId <- is the key
        let predicate = NSPredicate(format: "chatRoomId = %@", chatRoomId)
        // get access to the database , declare type , then filter it .
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        
        if allLocalMessages.isEmpty {
            print("DEBUG: ")
        }
        notificationToken = allLocalMessages.observe({  (changes: RealmCollectionChange) in
            
            // MARK: - notificationToken
            switch changes {
            case .initial:
                // to check all messages inside the database
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true)
            case .update(_, _, let insertions, _):
                // to insert new message in the database
                for index in insertions {
                    self.insertMessage(self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: true)
                }
            case .error(let error):
                print("DEBUG: error while \(error.localizedDescription)")
            }
            self.messagesCollectionView.reloadData()
            
        })
    }
    
    
    
    // MARK: - listenToNewChats
    fileprivate func listenToNewChats(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        MessageService.shared.listenForNewChats(uid, collectionId: chatRoomId, lastMessageDate: lastMessageDate())
    }
    
    
    
    // MARK: - Check for old messages
    private func listenForOldChats(){
        guard let uid = Auth.auth().currentUser?.uid else { return  }
        MessageService.shared.checkForOldChats(uid, collectionId: chatRoomId)
    }
    
    
    
    // MARK: - insertMessages
    fileprivate func insertMessages(){
        
        maxMessageNumber = allLocalMessages.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalMessages[i])
        }
        
    }
    
    fileprivate func loadMoreMessages(maxNumber: Int, minNumber: Int){
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            insertOlderMessage(allLocalMessages[i])
        }
    }
    
    fileprivate func insertOlderMessage(_ localMessage: LocalMessage){
        let incoming  = IncomingMessageService(_collectionView: self)
        self.mkMessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
        displayingMessagesCount += 1
    }
    
    private func markMessageAsRead(_ localMessage: LocalMessage){
        
        if localMessage.senderId != User.currentId && localMessage.status != kREAD {
            MessageService.shared.updateMessageInFirebase(localMessage, memberIds: [User.currentId, recipientId])
        }
    }
    
    
    fileprivate func insertMessage(_ localMessage: LocalMessage){
        
        if localMessage.senderId != User.currentId{
            markMessageAsRead(localMessage)
        }
        
        let incoming  = IncomingMessageService(_collectionView: self)
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        
        displayingMessagesCount += 1
    }
    
    
    
    private func listenForReadStatusChange(){
        MessageService.shared.listenForReadStatusChange(User.currentId, collectionId: chatRoomId) { [weak self] updatedMessage in
            if updatedMessage.status != kSENT {
                self?.updateMessage(updatedMessage)
            }
        }
    }
    
    fileprivate func updateMessage(_ localMessage: LocalMessage){
        
        for index in 0 ..< mkMessages.count {
            let tempMessage = mkMessages[index]
            if localMessage.id == tempMessage.messageId {
                mkMessages[index].status = localMessage.status
                mkMessages[index].readDate = localMessage.date
                RealmService.shared.saveToRealm(localMessage)
                if mkMessages[index].status == kREAD {
                    self.messagesCollectionView.reloadData()
                }
            }
        }
        
    }
    
    
    // MARK: - messageSend
    func messageSend(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0 ){
        
        
        
        OutgoingMessageService.send(chatId: chatRoomId, text: text, photo: photo, video: video,
                                    audio: audio, location: location, memberIds: [User.currentId, recipientId])
        //        PushNotificationService.shared.sendPushNotification(userIds:  [User.currentId, recipientId], body: text , title: recipientName)
    }
    
    
    // MARK: - updateTypingIndictor
    
    func createTypingObserver(){
        TypingListenerService.shared.createTypingObserver(chatRoomId: chatRoomId) { [weak self] isTyping in
            DispatchQueue.main.async {
                self?.updateTypingIndictor(isTyping)
            }
        }
    }
    
    
    func typingIndicator(){
        typingCounter += 1
        TypingListenerService.saveTypingCounter(typing: true, chatRoomId: chatRoomId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.typingCounterStop()
        }
    }
    
    func typingCounterStop(){
        typingCounter -= 1
        if typingCounter == 0 {
            TypingListenerService.saveTypingCounter(typing: false, chatRoomId: chatRoomId)
        }
    }
    
    func updateTypingIndictor(_ show: Bool){
        subTitleLabel.text = show ? "   Typing ..." : ""
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if refreshController.isRefreshing {
            if displayingMessagesCount < allLocalMessages.count {
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshController.endRefreshing()
        }
        
    }
    
    fileprivate func removeListener(){
        TypingListenerService.shared.removeTypingListener()
        MessageService.shared.removeListener()
        
    }
    
    
    fileprivate func lastMessageDate() -> Date {
        guard let lastMessageDate = allLocalMessages.last?.date else {return  Date() }
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
    
    // MARK: - Gallery
    fileprivate func showImageGallery(camera: Bool){
        
        gallery.delegate = self
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30
        
        self.present(gallery, animated: true, completion: nil)
    }
    
}

extension ChatViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            images.first?.resolve(completion: { image in
                self.messageSend(text: nil, photo: image, video: nil, audio: nil, location: nil)
            })
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
        self.messageSend(text: nil, photo: nil, video: video, audio: nil, location: nil)
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}

extension ChatViewController {
    
    
    fileprivate func actionDisplayButtonAttachments(){
        messageInputBar.inputTextView.resignFirstResponder()
        view.isUserInteractionEnabled = false
        
        customAlertView.addSubview(topDividerCustomAlertView)
        topDividerCustomAlertView.centerX(inView: customAlertView, topAnchor: customAlertView.topAnchor, paddingTop: 10)
        topDividerCustomAlertView.setDimensions(height: 4, width: 100)
        topDividerCustomAlertView.backgroundColor = .white
        topDividerCustomAlertView.layer.cornerRadius = 4 / 2
        
        
        customAlertView.addSubview(stackView)
        stackView.anchor(top: topDividerCustomAlertView.bottomAnchor, left: customAlertView.leftAnchor, right: customAlertView.rightAnchor,
                         paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        
        
        customAlertView.clipsToBounds = true
        customAlertView.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        customAlertView.layer.cornerRadius = 10
        customAlertView.setDimensions(height: 430, width: view.frame.width)
        
        
        attributes.screenBackground = .visualEffect(style: .dark)
        attributes.positionConstraints.safeArea = .overridden
        attributes.positionConstraints.verticalOffset = -50
        attributes.windowLevel = .alerts
        attributes.position = .bottom
        attributes.precedence = .override(priority: .max, dropEnqueuedEntries: false)
        attributes.displayDuration = .infinity
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.statusBar = .light
        attributes.lifecycleEvents.willDisappear = { [weak self] in
            self?.view.isUserInteractionEnabled = true
        }
        attributes.entryBackground = .clear
        SwiftEntryKit.display(entry: customAlertView, using: attributes)
    }
    
    
    
    func createButton(tagNumber: Int, title: String?, backgroundColor: UIColor, colorAlpa: CGFloat, systemName: String) -> UIButton {
        let button = UIButton(type: .system)
        guard let title = title else { return UIButton() }
        button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.titleLabel?.numberOfLines = 0
        button.setTitle("\(title)  ", for: .normal)
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.backgroundColor = backgroundColor.withAlphaComponent(colorAlpa)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleActionAttachment), for: .touchUpInside)
        button.layer.cornerRadius = 50 / 2
        button.tag = tagNumber
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.setupShadow(opacity: 0.5, radius: 16, offset: CGSize(width: 0.0, height: 8.0), color: backgroundColor)
        return button
    }
}
