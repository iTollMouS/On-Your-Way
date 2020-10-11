//
//  FirebaseTripService.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/11/20.
//


import Foundation
import Firebase

class FirebaseTripService {
    
    static let shared = FirebaseTripService()
    
    private init () {}
    
    func uploadNewTrip(trip: Trip, completion: @escaping(Error?) -> Void){
        do {
            try Firestore.firestore().collection("trips").document(trip.tripID).setData(from: trip, merge: true, completion: completion)
            
        } catch (let error ) {
            print("DEBUG: error while uploading new trip")
            completion(error)
        }
    }
    
    
    
}
