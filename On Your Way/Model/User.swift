//
//  User.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable, Equatable{
    
    var id = ""
    var username: String
    var email: String
    var pushId = ""
    var avatarLink = ""
    var status: String
    var password: String?
    var phoneNumber: String?
    var reviewsCount: Int?
    
    static var currentId: String{
        guard let uid = Auth.auth().currentUser?.uid else { return "" }
        return uid
    }
    
    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {
                let decoder = JSONDecoder()
                do {
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                } catch (let error ) {
                    print("DEBUG: error while finding user \(error.localizedDescription) ")
                }
            }
        }
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {  lhs.id == rhs.id  }
    
}
 
func saveUserLocally(_ user: User) {
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
    } catch (let error ) {
        print("DEBUG: error while daving user \(error.localizedDescription)")
    }
}
