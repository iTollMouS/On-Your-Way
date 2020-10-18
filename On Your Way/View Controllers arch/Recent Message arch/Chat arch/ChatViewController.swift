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


class ChatViewController: MessagesViewController {
    
    // MARK: - Properties
    
    
    let leftBarButtonLeft: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
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
        IQKeyboardManager.shared.enable = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureNavBar()
        tabBarController?.dismissPopupBar(animated: true, completion: nil)
        
    }
    
    
    
    fileprivate func configureLeftBarButton(){
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain,
                                                                  target: self, action: #selector(handleDismissal))]
        leftBarButtonLeft.addSubview(titleLabel)
        leftBarButtonLeft.addSubview(subTitleLabel)
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonLeft)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        titleLabel.text = recipientName
    }
    
    @objc fileprivate func handleDismissal(){
        
        
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
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
    }
    
    
    // MARK: - configureMessageInputBar
    fileprivate func configureMessageInputBar(){
        messageInputBar.delegate = self
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { item in
            //            self.actionAttachMessage()
        }
        
        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        //        micButton.addGestureRecognizer(longPressGesture)
        
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
        // we get the locam message from realm by providing the key remember chatRoomId <- is the key
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
                print("")
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
    
    
    fileprivate func insertMessage(_ localMessage: LocalMessage){
        let incoming  = IncomingMessageService(_collectionView: self)
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        displayingMessagesCount += 1
    }
    
    
    
    // MARK: - messageSend
    func messageSend(text: String?, photo: UIImage?, video: String?, audio: String?, location: String?, audioDuration: Float = 0.0 ){
        guard let text = text else { return }
        PushNotificationService.shared.sendPushNotification(userIds:  [User.currentId, recipientId], body: text , title: recipientName)
        
        OutgoingMessageService.send(chatId: chatRoomId, text: text, photo: photo, video: video,
                                    audio: audio, location: location, memberIds: [User.currentId, recipientId])
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
        subTitleLabel.text = show ? "Typing ..." : ""
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
    
    
    fileprivate func lastMessageDate() -> Date {
        guard let lastMessageDate = allLocalMessages.last?.date else {return  Date() }
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
}
