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
    
    private var chatRoomId = ""
    private var recipientId = ""
    private var recipientName = ""
    private let refreshController = UIRefreshControl()
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    private let micButton: InputBarButtonItem = {
        let micButton = InputBarButtonItem(type: .system)
        micButton.image = UIImage(systemName: "mic.circle")
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        micButton.tintColor = .green
        return micButton
    }()
    
    private let attachmentButton: InputBarButtonItem = {
        let attachmentButton = InputBarButtonItem(type: .system)
        attachmentButton.image = UIImage(systemName: "paperclip.circle")
        attachmentButton.setSize(CGSize(width: 30, height: 40), animated: false)
        attachmentButton.tintColor = .systemBlue
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
        configureMessageInputBar()
        
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
    
    fileprivate func configureNavBar(){
       
        configureNavigationBar(withTitle: recipientName, largeTitleColor: .white, tintColor: .white,
                               navBarColor: #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1), smallTitleColorWhenScrolling: .dark,
                               prefersLargeTitles: false)        
    }
    
    // step 1 to configure the chat delegate s
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
    
    fileprivate func configureMessageInputBar(){
        messageInputBar.delegate = self
        messageInputBar.setStackViewItems([attachmentButton], forStack: .left, animated: false)
        attachmentButton.onTouchUpInside { [weak self ] action in
            print("DEBUG: attach button pressed")
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 42, animated: false)
        messageInputBar.inputTextView.isImagePasteEnabled = true
        messageInputBar.inputTextView.layer.cornerRadius = 20
        messageInputBar.backgroundView.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
        messageInputBar.inputTextView.backgroundColor = #colorLiteral(red: 0.3450980392, green: 0.3450980392, blue: 0.3450980392, alpha: 1)
        
    }
    
    
}
