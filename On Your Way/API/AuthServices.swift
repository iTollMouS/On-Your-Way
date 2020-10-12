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

// MARK: - userCredential
struct userCredential {
    let email: String
    let password: String
    let fullName: String
    let profileImageUrl: String
}




// MARK: -  AuthServices
struct AuthServices {
    static let shared = AuthServices()
    
    private init() {}
    
    
    // MARK: - typealias APICompletion
    typealias APICompletion = ((Error?) -> Void)
    
    
    // MARK: - registerUserWithPhoneNumber
    func registerUserWithPhoneNumber(withCredentials authCredential : PhoneAuthCredential, completion: @escaping APICompletion){
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
                            email: "", pushId: "", avatarLink: "", status: "", password: "",
                            phoneNumber: phoneNumber,
                            reviewsCount: 0)
            saveUserLocally(user)
            UserServices.shared.saveUserToFirestore(user)
            completion(error)
        }
    }
    
    
    // MARK: - registerUserWithGoogle
    func registerUserWithGoogle(didSignInfo user: GIDGoogleUser, completion: @escaping APICompletion) {
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
                            pushId: "", avatarLink: profileImageUrl, status: "", password: "",
                            phoneNumber: "",
                            reviewsCount: 0)
            emailVerification(withEmail: email, userResult: authResult)
            UserServices.shared.saveUserToFirestore(user)
            saveUserLocally(user)
            completion(error)
            
        }
    }
    
    
    // MARK: - signInWithAppleID
    func signInWithAppleID(credential: AuthCredential, fullname: String, completion: @escaping APICompletion){
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("DEBUG: error authenticate via phone number \(error)")
                completion(error)
                return
            }
            guard let authResult = authResult?.user else {return}
            guard let email = authResult.email else {return}
            let user = User(id: authResult.uid, username: fullname, email: email, pushId: "", avatarLink: "", status: "", password: "" ,phoneNumber: "",
                            reviewsCount: 0)
            UserServices.shared.saveUserToFirestore(user)
            saveUserLocally(user)
            completion(error)
            
        }
    }
    
    
    
    // MARK: - logUserWitEmail
    func logUserWitEmail(email: String, password: String, completion: @escaping APICompletion) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                print("DEBUG: error while registering new user\(error)")
                completion(error)
                return
            }
            completion(error)
        }
    }
    
    
    // MARK: - registerUserWith
    func registerUserWith(credential: userCredential , completion: @escaping  APICompletion) {
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
                            email: credential.email, pushId: "", avatarLink: credential.profileImageUrl, status: "", password: credential.password,
                            phoneNumber: "",
                            reviewsCount: 0)
            saveUserLocally(user)
            UserServices.shared.saveUserToFirestore(user)
            completion(error)
        }
        
    }
    
    
    // MARK: - resetPassword
    func resetPassword(email: String, completion: @escaping APICompletion ){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("DEBUG: error while registering new user\(error)")
                completion(error)
                return
            }
            completion(error)
        }
    }
    
    
    // MARK: - logOutUser
    func logOutUser(completion: @escaping APICompletion){
        do {
            try Auth.auth().signOut()
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
        } catch (let error) {
            print("Error while logging user out! \(error.localizedDescription)")
        }
        
    }

    // MARK: - emailVerification
    func emailVerification(withEmail: String, userResult: AuthDataResult){
        userResult.user.sendEmailVerification { error in
            if let error = error {
                print("DEBUG: error while verifying email\(error.localizedDescription)")
                return
            }
        }
    }
    
}
