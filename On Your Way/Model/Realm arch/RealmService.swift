//
//  RealmService.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/16/20.
//

import Foundation
import RealmSwift

class RealmService {
    
    static let shared = RealmService()
    let ream = try! Realm()
    
    private init () {}
    
    
    func saveToRealm<T: Object>(_ object: T){
        
        do {
            
            try ream.write{ ream.add(object, update: .all) }
            
        } catch (let error) {
            print("DEBUG: error saving in real object \(error.localizedDescription)")
        }
    }
    
}
