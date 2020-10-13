//
//  TripService.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/11/20.
//

import Foundation
import Firebase

class TripService {
    static let shared = TripService()
    
    private init () {}
    
    func saveTripToFirestore(_ trip: Trip, completion: @escaping(Error?) -> Void){
        do {
            try Firestore.firestore().collection("trips")
                .document(trip.tripID).setData(from: trip, merge: true, completion: completion)
            
            try Firestore.firestore().collection("users-trips")
                .document(trip.userID).collection("trips")
                .document(trip.tripID).setData(from: trip, merge: true, completion: completion)
            
        } catch (let error){
            completion(error)
        }
    }
    
    func fetchAllTrips(completion: @escaping([Trip]) -> Void) {
        var trips: [Trip] = []
        Firestore.firestore().collection("trips").addSnapshotListener { (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            let allTrips = snapshot.documentChanges.compactMap {(queryDocumentSnapshot) -> Trip? in
                
                return try? queryDocumentSnapshot.document.data(as: Trip.self)
            }
            for trip in allTrips {  trips.append(trip) }
            trips.sort(by: { $0.timestamp! > $1.timestamp! })
            completion(trips)
        }
    }
    
    func sendPackageToTraveler(trip: Trip, userId: String, package: Package , completion: @escaping(Error?) -> Void){
        do {
            try Firestore.firestore().collection("users-requests")
                .document(trip.userID).collection("shipping-request")
                .document(package.packageID).setData(from: package, merge: true, completion: completion)
        } catch (let error) {
            print("DEBUG: error while uploading package\(error.localizedDescription)")
        }
    }
    
    func fetchMyTrips(userId: String,  completion: @escaping([Package]) -> Void){
        var trips: [Package] = []
        Firestore.firestore().collection("users-requests").document(userId).collection("shipping-request").addSnapshotListener { (snapshot, error) in

            guard let snapshot = snapshot else {return}
            let allTrips = snapshot.documents.compactMap { (queryDocumentSnapshot) -> Package? in
                return try? queryDocumentSnapshot.data(as: Package.self)
            }
            for trip in allTrips {  trips.append(trip) }
            trips.sort(by: { $0.timestamp! > $1.timestamp! })
            completion(trips)
        }
    }
    
    func deleteMyTrip(trip: Trip, completion: @escaping(Error?) -> Void){
        Firestore.firestore().collection("trips").document(trip.tripID).delete(completion: completion)
    }
}
