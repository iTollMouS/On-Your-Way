//
//  UserServices.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/11/20.
//

import Foundation
import Firebase

struct userCredential {
    let email: String
    let password: String
    let fullName: String
    let profileImageUrl: String
}


class UserServices {
    
    static let shared = UserServices()
    
    private init() {}
    
    func registerUserWith(credential: userCredential , completion: @escaping(Error?) -> Void){
        Auth.auth().createUser(withEmail: credential.email, password: credential.password) { (authResult, error) in
            if let error = error {
                print("DEBUG: error while registering new user\(error)")
                completion(error)
                return
            }
            guard let authResult = authResult else {return}
            authResult.user.sendEmailVerification { error in
                if let error = error {
                    print("DEBUG: error while registering new user\(error)")
                    completion(error)
                    return
                }
            }
            
            let user = User(id: authResult.user.uid, username: credential.fullName,
                            email: credential.email, pushId: "", avatarLink: credential.profileImageUrl, status: "")
            saveUserLocally(user)
            AuthServices.shared.saveUserToFirestore(user)
            completion(error)
        }
        
    }
    
    func resetPassword(email: String, completion: @escaping(Error?) -> Void){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("DEBUG: error while registering new user\(error)")
                completion(error)
                return
            }
            completion(error)
        }
    }
    
    func logOutUser(completion: @escaping(Error?) -> Void){
        do {
            
            try Auth.auth().signOut()
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
        } catch (let error) {
            print("Error while logging user out! \(error.localizedDescription)")
        }
    }
    
    
}
