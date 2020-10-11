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
}
