//
//  TripService.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/11/20.
//

import Foundation
import Firebase


public let pendingPackage = "pendingPackage"
public let acceptedPackage = "acceptedPackage"
public let completedPackage = "completedPackage"

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
        var packagesDictionary: [String: Package] = [:]
        var packages: [Package] = []
        Firestore.firestore().collection("users-send-packages").document(userId).collection("packages").addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            
            for packageChanged in snapshot.documentChanges {
                if packageChanged.type == .added {
                    let result = Result {
                        try? packageChanged.document.data(as: Package.self)
                    }
                    switch result {
                    
                    case .success( let package):
                        if let package = package {
                            packages.append(package)
                        }
                    case .failure(let error ):
                        print("DEBUG: error \(error.localizedDescription)")
                    }
                }
                
                if packageChanged.type == .modified {
                    let result = Result {
                        try? packageChanged.document.data(as: Package.self)
                    }
                    switch result {
                    case .success( let package):
                        if let package = package {
                            packages.append(package)
                        }
                    case .failure(let error ):
                        print("DEBUG: error \(error.localizedDescription)")
                    }
                }
                
                if packageChanged.type == .removed {
                    let result = Result {
                        try? packageChanged.document.data(as: Package.self)
                    }
                    switch result {
                    case .success( let package):
                        if let package = package {
                            packages.append(package)
                        }
                    case .failure(let error ):
                        print("DEBUG: error \(error.localizedDescription)")
                    }
                }
                
            }
            
            packages.forEach { package in
                let tempPackage = package
                packagesDictionary[tempPackage.packageID] = package
            }
            packages = Array(packagesDictionary.values)
            packages.sort(by: { $0.timestamp! > $1.timestamp! })
            completion(packages)
        }
        
    }
    
    /// when traveler decide to reject / accept
    func updatePackageStatus(userId: String, package: Package, completion: @escaping(Error?) -> Void){
        switch package.packageStatus {
        case .packageIsPending:
            fallthrough
        case .packageIsRejected:
            Firestore.firestore().collection("users-requests")
                .document(userId).collection(pendingPackage)
                .document(package.packageID).delete(completion: completion)
            
            do {// when traveler rejects order , user will be notified
                try Firestore.firestore().collection("users-send-packages")
                    .document(package.userID).collection("packages")
                    .document(package.packageID).setData(from: package, merge: true, completion: completion)
                
            } catch (let error){
                completion(error)
            }
            
        case .packageIsAccepted:
            do {
                Firestore.firestore().collection("users-requests")
                    .document(userId).collection(pendingPackage)
                    .document(package.packageID).delete()
                
                try Firestore.firestore().collection("users-requests")
                    .document(userId).collection(acceptedPackage)
                    .document(package.packageID).setData(from: package, merge: true)
                
                
                try Firestore.firestore().collection("users-send-packages")
                    .document(package.userID).collection("packages")
                    .document(package.packageID).setData(from: package, merge: true, completion: completion)
                
            } catch (let error){
                completion(error)
            }
        case .packageIsDelivered:
            do {
                Firestore.firestore().collection("users-requests")
                    .document(userId).collection(acceptedPackage)
                    .document(package.packageID).delete()
                
                try Firestore.firestore().collection("users-requests")
                    .document(userId).collection(completedPackage)
                    .document(package.packageID).setData(from: package, merge: true)
                
                try Firestore.firestore().collection("users-send-packages")
                    .document(package.userID).collection("packages")
                    .document(package.packageID).setData(from: package, merge: true, completion: completion)
                
            } catch (let error){
                completion(error)
            }
        }
    }
    
    func fetchUserFromTrip(tripId: String, completion: @escaping(User) -> Void){
        Firestore.firestore().collection("trips").document(tripId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            guard let trip = try? snapshot.data(as: Trip.self) else {return}
            UserServices.shared.fetchUser(userId: trip.userID) {  user in
                completion(user)
            }
        }
    }
    
    
    /// when user wants to send a package with traveler
    func sendPackageToTraveler(trip: Trip, userId: String, package: Package , completion: @escaping(Error?) -> Void){
        do {
            try Firestore.firestore().collection("users-requests")
                .document(trip.userID).collection(pendingPackage)
                .document(package.packageID).setData(from: package, merge: true, completion: completion)
            
            try Firestore.firestore().collection("users-send-packages")
                .document(userId).collection("packages")
                .document(package.packageID).setData(from: package, merge: true, completion: completion)
            
        } catch (let error) {
            print("DEBUG: error while uploading package\(error.localizedDescription)")
        }
    }
    
    /// when user decides to delete his order (it will be deleted from his side and the traveler side))
    func deleteMyOutgoingPackage(trip: Trip, userId: String, package: Package , completion: @escaping(Error?) -> Void){
        Firestore.firestore().collection("users-requests")
            .document(trip.userID).collection(pendingPackage)
            .document(package.packageID).delete(completion: completion)
        Firestore.firestore().collection("users-send-packages")
            .document(userId).collection("packages")
            .document(package.packageID).delete(completion: completion)
    }
    
    
    /// fetch traveler orders accordingly
    func fetchMyTrips(userId: String, packageStatus: String , completion: @escaping([Package]) -> Void){
        var packagesDictionary: [String: Package] = [:]
        var packages: [Package] = []
        Firestore.firestore().collection("users-requests").document(userId).collection(packageStatus).addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            
            for packageChanged in snapshot.documentChanges {
                if packageChanged.type == .added {
                    let result = Result {
                        try? packageChanged.document.data(as: Package.self)
                    }
                    switch result {
                    
                    case .success( let package):
                        if let package = package {
                            packages.append(package)
                        }
                    case .failure(let error ):
                        print("DEBUG: error \(error.localizedDescription)")
                    }
                }
                
                if packageChanged.type == .modified {
                    let result = Result {
                        try? packageChanged.document.data(as: Package.self)
                    }
                    switch result {
                    case .success( let package):
                        if let package = package {
                            packages.append(package)
                        }
                    case .failure(let error ):
                        print("DEBUG: error \(error.localizedDescription)")
                    }
                }
                
                if packageChanged.type == .removed {
                    let result = Result {
                        try? packageChanged.document.data(as: Package.self)
                    }
                    switch result {
                    case .success( let package):
                        if let package = package {
                            packages.append(package)
                        }
                    case .failure(let error ):
                        print("DEBUG: error \(error.localizedDescription)")
                    }
                }
                
            }
            
            packages.forEach { package in
                let tempPackage = package
                packagesDictionary[tempPackage.packageID] = package
            }
            packages = Array(packagesDictionary.values)
            packages.sort(by: { $0.timestamp! > $1.timestamp! })
            completion(packages)
        }
    }
    
    func fetchTrip(tripId: String,  completion: @escaping(Trip) -> Void){
        Firestore.firestore().collection("trips").document(tripId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            guard let trip = try? snapshot.data(as: Trip.self) else {return}
            completion(trip)
        }
    }
    
    func deleteMyTrip(trip: Trip, completion: @escaping(Error?) -> Void){
        Firestore.firestore().collection("trips").document(trip.tripID).delete(completion: completion)
    }
}
