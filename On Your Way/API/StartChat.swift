//
//  StartChat.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/11/20.
//

import Foundation
import Firebase


// step 1
func startChat(currentUser: User, selectedUser: User) -> String {
    let chatRoomId = chatRoomIdMaker(currentUser: currentUser.id, selectedUser: selectedUser.id)
    createRecentChat(chatRoomId: chatRoomId, users: [currentUser, selectedUser])
    return chatRoomId
    
}

// step 2 : whosoever tap on the selected user , the result will be always the same
func chatRoomIdMaker(currentUser: String, selectedUser: String) -> String {
    // we compare the 2 users id and combine them together
    var chatRoomId = ""
    let value = currentUser.compare(selectedUser).rawValue
    chatRoomId = value < 0 ? (currentUser + selectedUser) : (selectedUser + currentUser)
    return chatRoomId
}


// step 3   create chat room id by combine 2 users ids
func createRecentChat(chatRoomId: String, users: [User]) {
    
    guard let currentUser = users.first?.id else { return  }
    guard let selectedUser = users.last?.id else { return }
    var members = [ currentUser , selectedUser ]
    
    print("DEBUG: members to create cerent is \(members)")
    
    Firestore.firestore().collection("recents").whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {return}
        
        if !snapshot.isEmpty {
            members = removeMemberWhoHasRecent(snapshot: snapshot, members: members)
            print("DEBUG: check who doesnr have the recent \(members)")
        }
        
        for user in members {
            print("DEBUG: Creating recent for the user who does not have it \(user)")
            // only gets call when any user dont have recent
            let currentUser = user == User.currentId ? User.currentUser! : getReceiverFrom(users: users)
            let selectedUser = user == User.currentId ?  getReceiverFrom(users: users) : User.currentUser!
            let recent = RecentChat(id: UUID().uuidString,
                                    chatRoomId: chatRoomId,
                                    senderId: currentUser.id,
                                    senderName: currentUser.username,
                                    receiverId: selectedUser.id,
                                    receiverName: selectedUser.username,
                                    date: Date(), memberIds: [currentUser.id, selectedUser.id],
                                    lastMessage: "", unreadCounter: 0,
                                    profileImageView: selectedUser.avatarLink)
            print("DEBUG: create new recent who doesn't have one ", currentUser.id, selectedUser.id)
            // step 7
            FirebaseRecentService.shared.addRecent(recent) { error in
                if let error = error {
                    print("DEBUG: errir while maing chat \(error)")
                    return
                }
            }
            
        }
    }
    
}

// step 4
func removeMemberWhoHasRecent(snapshot: QuerySnapshot, members: [String]) -> [String] {
    
    var members = members
    print("DEBUG: members are ", members)
    for recentData in snapshot.documents {
        let currentRecent = recentData.data() as Dictionary
        
        if let currentUserId = currentRecent[kSENDERID] {
            if members.contains(currentUserId as! String) {
                members.remove(at: members.firstIndex(of: currentUserId as! String)!)
            }
        }
    }
    print("DEBUG: the person who needs update is \(members) ")
    
    return members
}
// step 5 which one is the receiver
func getReceiverFrom(users: [User]) -> User {
    var allUsers = users
    // since the user himself is tapping , we remove the first index of the users since we are the tapping
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    return allUsers.first!
}

