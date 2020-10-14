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
    
    
    func updatePackageStatus(userId: String, package: Package, completion: @escaping(Error?) -> Void) {
        do {
            try  Firestore.firestore().collection("users-requests")
                .document(userId).collection("shipping-request")
                .document(package.packageID).setData(from: package, merge: true, completion: completion)
            try Firestore.firestore().collection("users-send-packages")
                .document(package.userID).collection("packages")
                .document(package.packageID).setData(from: package, merge: true, completion: completion)
            
        } catch (let error){
            completion(error)
        }
    }
    
    
    func fetchAllTrips(completion: @escaping([Trip]) -> Void) {
        var tripsDictionary: [String: Trip] = [:]
        var trips = [Trip]()
        Firestore.firestore().collection("trips").addSnapshotListener { (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            trips = snapshot.documentChanges.compactMap {(queryDocumentSnapshot) -> Trip? in
                
                return try? queryDocumentSnapshot.document.data(as: Trip.self)
            }

            trips.forEach { trip in
                let tempTrip = trip
                tripsDictionary[tempTrip.tripID] = trip
            }
            trips = Array(tripsDictionary.values)
            trips.sort(by: { $0.timestamp! > $1.timestamp! })
            completion(trips)
            
        }
    }
    
    
    func fetchMyRequest(userId: String, completion: @escaping([Package]) -> Void){
        var packages: [Package] = []
        Firestore.firestore().collection("users-send-packages").document(userId).collection("packages").addSnapshotListener { (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            let allPackages = snapshot.documents.compactMap { (queryDocumentSnapshot) -> Package? in
                return try? queryDocumentSnapshot.data(as: Package.self)
            }
            for trip in allPackages {  packages.append(trip) }
            packages.sort(by: { $0.timestamp! > $1.timestamp! })
            completion(packages)
        }
        
    }
    
    
    func rejectPackageOrderWith(userId: String, packageId: String, completion: @escaping(Error?) -> Void){
        Firestore.firestore().collection("users-requests").document(userId).collection("shipping-request").document(packageId).delete(completion: completion)
    }
    
    func fetchTrip(tripId: String, completion: @escaping(User) -> Void){
        Firestore.firestore().collection("trips").document(tripId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            guard let trip = try? snapshot.data(as: Trip.self) else {return}
            UserServices.shared.fetchUser(userId: trip.userID) {  user in
                completion(user)
            }
        }
        
    }
    
    func sendPackageToTraveler(trip: Trip, userId: String, package: Package , completion: @escaping(Error?) -> Void){
        do {
            try Firestore.firestore().collection("users-requests")
                .document(trip.userID).collection("shipping-request")
                .document(package.packageID).setData(from: package, merge: true, completion: completion)
            try Firestore.firestore().collection("users-send-packages")
                .document(userId).collection("packages")
                .document(package.packageID).setData(from: package, merge: true, completion: completion)
            
        } catch (let error) {
            print("DEBUG: error while uploading package\(error.localizedDescription)")
        }
    }
    
    func fetchMyTrips(userId: String,  completion: @escaping([Package]) -> Void){
        var packages: [Package] = []
        Firestore.firestore().collection("users-requests").document(userId).collection("shipping-request").addSnapshotListener { (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            let allTrips = snapshot.documents.compactMap { (queryDocumentSnapshot) -> Package? in
                return try? queryDocumentSnapshot.data(as: Package.self)
            }
            for trip in allTrips {  packages.append(trip) }
            packages.sort(by: { $0.timestamp! > $1.timestamp! })
            
            completion(packages)
        }
    }
    
    func deleteMyTrip(trip: Trip, completion: @escaping(Error?) -> Void){
        Firestore.firestore().collection("trips").document(trip.tripID).delete(completion: completion)
    }
}
