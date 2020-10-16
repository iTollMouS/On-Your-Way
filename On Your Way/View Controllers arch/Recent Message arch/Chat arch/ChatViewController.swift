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

class ChatViewController: MessagesViewController {
    
    // MARK: - Properties
    private var chatRoomId = ""
    private var recipientId = ""
    private var recipientName = ""
    private let refreshController = UIRefreshControl()
    private let realm = try! Realm()
    private var allLocalMessages: Results<LocalMessage>!
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    private let micButton: InputBarButtonItem = {
        let micButton = InputBarButtonItem(type: .system)
        micButton.image = UIImage(systemName: "mic.circle",
                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 32))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        micButton.tintColor = .green
        return micButton
    }()
    
    private let attachmentButton: InputBarButtonItem = {
        let attachmentButton = InputBarButtonItem(type: .system)
        attachmentButton.image = UIImage(systemName: "paperclip.circle",
                                         withConfiguration: UIImage.SymbolConfiguration(pointSize: 38))
        attachmentButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachmentButton.tintColor = .init(white: 1, alpha: 0.7)
        return attachmentButton
    }()
    
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
        configureMessageCollectionView()
        configureMessageInputBar()
        loadChats()
        
        
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
    
    
    
    // MARK: - configureNavBar
    fileprivate func configureNavBar(){
        
        configureNavigationBar(withTitle: recipientName, largeTitleColor: .white, tintColor: .white,
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
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.refreshControl = refreshController
        
    }
    
    
    // MARK: - configureMessageInputBar
    fileprivate func configureMessageInputBar(){
        messageInputBar.delegate = self
        messageInputBar.setStackViewItems([attachmentButton], forStack: .left, animated: false)
        attachmentButton.onTouchUpInside { [weak self ] action in
            
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 42, animated: false)
        messageInputBar.inputTextView.isImagePasteEnabled = true
        messageInputBar.inputTextView.layer.cornerRadius = 20
        messageInputBar.backgroundView.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        messageInputBar.inputTextView.backgroundColor = #colorLiteral(red: 0.3450980392, green: 0.3450980392, blue: 0.3450980392, alpha: 1)
        
    }
    
    // MARK: - Actions
    // we send any outgoing message
    
    fileprivate func loadChats(){
        // we get the locam message from realm by providing the key remember chatRoomId <- is the key
        let predicate = NSPredicate(format: "chatRoomId = %@", chatRoomId)
        // get access to the database , declare type , then filter it .
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        print("DEBUG: messages are \(allLocalMessages.count)")
    }
    
    
    
    
    
    // MARK: - messageSend
    func messageSend(text: String?, photo: UIImage?, video: String?, audio: String?, location: String?, audioDuration: Float = 0.0 ){
    
        OutgoingMessageService.send(chatId: chatRoomId, text: text, photo: photo, video: video,
                                    audio: audio, location: location, memberIds: [User.currentId, recipientId])
    }
    
    
}
