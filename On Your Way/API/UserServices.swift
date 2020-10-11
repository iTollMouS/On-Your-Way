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
    
    
}
