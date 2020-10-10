//
//  AuthServices.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import Foundation
import Firebase
import ProgressHUD


struct AuthServices {
    static let shared = AuthServices()
    
    private init() {}
    
    func registerUserWithPhoneNumber(withCredentials authCredential : PhoneAuthCredential, completion: @escaping(Error?) -> Void){
        Auth.auth().signIn(with: authCredential) { (authResult, error) in
            if let error = error {
                print("DEBUG: error authenticate via phone number \(error)")
                completion(error)
                return
            }
            
            guard let authResult = authResult else {return}
            guard let phoneNumber = authResult.user.phoneNumber else {return}
            let user = User(id: authResult.user.uid,
                            username: phoneNumber,
                            email: phoneNumber, pushId: "", avatarLink: "", status: "")
            saveUserLocally(user)
            self.saveUserToFirestore(user)
            completion(error)
        }
        
    }
    
    func saveUserToFirestore(_ user: User){
        do {
            
            try Firestore.firestore().collection("users").document(user.id).setData(from: user, merge: true)
            
        } catch (let error ) {
            print("DEBUG: error while saving user locally \(error.localizedDescription)")
        }
    }
    
}
