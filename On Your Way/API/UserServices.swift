//
//  UserServices.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/11/20.
//

import Foundation
import Firebase

class UserServices {
    
    static let shared = UserServices()
    
    private init() {}
    
    // MARK: - saveUserToFirestore
    func saveUserToFirestore(_ user: User){
        do {
            try Firestore.firestore().collection("users").document(user.id).setData(from: user, merge: true)
            
        } catch (let error ) {
            print("DEBUG: error while saving user locally \(error.localizedDescription)")
        }
    }
    
    // MARK: - fetchUser
    func fetchUser(userId: String, completion: @escaping(User) -> Void){
        Firestore.firestore().collection("users").document(userId).getDocument { (snapshot, error) in
            if let error = error {
                print("DEBUG: error while getting error \(error.localizedDescription) ")
                return
            }
            guard let snapshot  = snapshot else {return}
            let result = Result {
                try? snapshot.data(as: User.self)
            }
            
            switch result {
            case .success(let userObject):
                guard let user = userObject else { return }
                saveUserLocally(user)
                completion(user)
            case .failure(let error):
                print("DEBUG: error while saving user info\(error.localizedDescription)")
            }
        }
    }
    
    func fetchAllUsers(completion: @escaping (_ allUsers: [User]) -> Void) {
        Firestore.firestore().collection("users").getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            let users = snapshot.documents.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            completion(users)
        }
    }
    
    func downloadUsersFromFirebase(withIds: [String], completion: @escaping (_ allUsers: [User]) -> Void) {
        
        var count = 0
        var usersArray: [User] = []
        
        for userId in withIds {
            
            Firestore.firestore().collection("users").document(userId).getDocument { (querySnapshot, error) in
                
                guard let document = querySnapshot else {
                    print("no document for user")
                    return
                }
                
                let user = try? document.data(as: User.self)
                
                usersArray.append(user!)
                count += 1
                
                if count == withIds.count {
                    completion(usersArray)
                }
            }
        }
    }
}
