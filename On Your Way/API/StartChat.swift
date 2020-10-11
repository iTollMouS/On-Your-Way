//
//  StartChat.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/11/20.
//

import Foundation
import Firebase

//func startChat(currentUser: String, selectedUser: String) -> String {
//    let chatRoomId = chatRoomIdMaker(currentUser: currentUser, selectedUser: selectedUser)
//
//
//}

func createRecentChat(chatRoomId: String, users: [User]) {
    
    guard let currentUser = users.first?.id else { return  }
    guard let selectedUser = users.last?.id else { return }
    var members = [ currentUser, selectedUser ]
    
    Firestore.firestore().collection("recent").whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {return}
        
        if !snapshot.isEmpty {
            members = removeMemberWhoHasRecent(snapshot: snapshot, members: members)
        }
        
        for user in members {
            let currentUser = user == User.currentId ? User.currentUser! : getReceiverFrom(users: users)
            let selectedUser = user == User.currentId ?  getReceiverFrom(users: users) : User.currentUser!
            let recent = RecentChat(id: UUID().uuidString,
                                    chatRoomId: chatRoomId,
                                    senderId: currentUser.id,
                                    senderName: currentUser.username,
                                    receiverId: selectedUser.id,
                                    receiverName: selectedUser.username,
                                    date: Date(), memberIds: members,
                                    lastMessage: "", unreadCounter: 0,
                                    avatarLink: selectedUser.avatarLink)
        }
    }
    
}

func removeMemberWhoHasRecent(snapshot: QuerySnapshot, members: [String]) -> [String] {
    
    var members = members
    
    for recentData in snapshot.documents {
        let currentRecent = recentData.data() as Dictionary
        
        if let currentUserId = currentRecent[kSENDERID] {
            if members.contains(currentUserId as! String) {
                members.remove(at: members.firstIndex(of: currentUserId as! String)!)
            }
        }
    }
    
    return members
}

func getReceiverFrom(users: [User]) -> User {
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    return allUsers.first!
}


// whoseever tap on the selected user , the result will be always the same
func chatRoomIdMaker(currentUser: String, selectedUser: String) -> String {
    var chatRoomId = ""
    let value = currentUser.compare(selectedUser).rawValue
    chatRoomId = value < 0 ? (currentUser + selectedUser) : (selectedUser + currentUser)
    return chatRoomId
}
