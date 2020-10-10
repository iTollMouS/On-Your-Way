//
//  AuthServices.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import Foundation
import Firebase
import ProgressHUD
import GoogleSignIn


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
    
    func registerUserWithGoogle(didSignInfo user: GIDGoogleUser, completion: @escaping(Error?) -> Void) {
        guard let user = user.authentication else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: user.idToken, accessToken: user.accessToken)
        Auth.auth().signIn(with: credentials) { (authResult, error) in
            if let error = error {
                print("DEBUG: error authenticate via phone number \(error)")
                completion(error)
                return
            }
            guard let uid = authResult?.user.uid  else {return}
            guard let firstName = authResult?.user.displayName else {return}
            guard let email = authResult?.user.email else {return}
            guard let profileImageUrl = authResult?.user.photoURL?.absoluteString else {return}
            guard let authResult = authResult else {return}
            let user = User(id: uid, username: firstName, email: email,
                            pushId: "", avatarLink: profileImageUrl, status: "")
            emailVerification(withEmail: email, userResult: authResult)
            saveUserToFirestore(user)
            saveUserLocally(user)
            completion(error)
            
        }
    }
    
    func signInWithAppleID(credential: AuthCredential, fullname: String, completion: @escaping(Error?) -> Void){
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("DEBUG: error authenticate via phone number \(error)")
                completion(error)
                return
            }
            guard let authResult = authResult?.user else {return}
            guard let email = authResult.email else {return}
            let user = User(id: authResult.uid, username: fullname, email: email, pushId: "", avatarLink: "", status: "")
            print("DEBUG: user info is \(user.id)")
            print("DEBUG: user info is \(user.email)")
            saveUserToFirestore(user)
            saveUserLocally(user)
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
    
    func emailVerification(withEmail: String, userResult: AuthDataResult){
        userResult.user.sendEmailVerification { error in
            if let error = error {
                print("DEBUG: error while verifying email\(error.localizedDescription)")
                return
            }
        }
    }
    
}
