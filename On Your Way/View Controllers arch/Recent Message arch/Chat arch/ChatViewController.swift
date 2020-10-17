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
    private var allLocalMessages: Results<LocalMessage>!
    private let micButton = InputBarButtonItem()

    
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
        configureMessageCollectionView()
        configureMessageInputBar()
        configureLeftBarButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureNavBar()
        tabBarController?.dismissPopupBar(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        tabBarController?.tabBar.isHidden = false
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
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
    
    // MARK: - configureMessageInputBar
    fileprivate func configureMessageInputBar(){
        messageInputBar.delegate = self
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
                print("DEBUG: error while get data in realm \(error)")
            }
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom(animated: true)
        })
    }
    
    
    
    // MARK: - Check for old messages
    private func listenForNewChats(){
        guard let uid = Auth.auth().currentUser?.uid else { return  }
        MessageService.shared.checkForOldChats(uid, collectionId: chatRoomId)
    }
    
    
    
    // MARK: - insertMessages
    fileprivate func insertMessages(){
        
        for message in allLocalMessages {
            insertMessage(message)
        }
    }
    
    fileprivate func insertMessage(_ localMessage: LocalMessage){
        print("DEBUG: inserted message")
        let incoming  = IncomingMessageService(_collectionView: self)
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
    }
    
    
    
    // MARK: - messageSend
    func messageSend(text: String?, photo: UIImage?, video: String?, audio: String?, location: String?, audioDuration: Float = 0.0 ){
        
        OutgoingMessageService.send(chatId: chatRoomId, text: text, photo: photo, video: video,
                                    audio: audio, location: location, memberIds: [User.currentId, recipientId])
    }
    
    func updateTypingIndictor(_ show: Bool){
        subTitleLabel.text = show ? "Typing ..." : ""
    }
}
