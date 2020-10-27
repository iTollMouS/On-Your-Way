//
//  ReviewService.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/15/20.
//

import Foundation
import Firebase

class ReviewService {
    
    static let shared = ReviewService()
    
    func uploadNewReview(userId: String, review: Review , completion: @escaping(Error?) -> Void ){
        do {
            try   Firestore.firestore().collection("reviews")
                .document(userId).collection("reviews").document(review.reviewId)
                .setData(from: review, merge: true, completion: completion)
            
        } catch (let error) {
            print("DEBUG: error uploading reveiw \(error.localizedDescription)")
        }
    }
    
    func deleteMyReview(userId: String, review: Review,  completion: @escaping(Error?) -> Void ){
        Firestore.firestore().collection("reviews")
            .document(userId).collection("reviews")
            .document(review.reviewId).delete(completion: completion)
    }
    
    func editMyReview(userId: String, review: Review,  completion: @escaping(Error?) -> Void ){
        do {
            try Firestore.firestore().collection("reviews")
                .document(userId).collection("reviews")
                .document(review.reviewId).setData(from: review, merge: true, completion:  completion)
        } catch (let error){
            print(error.localizedDescription)
        }
    }
    
    func fetchPeopleReviews(userId: String, completion: @escaping([Review]) -> Void){
        var reviewsDictionary = [String: Review]()
        var reviews: [Review] = []
        Firestore.firestore().collection("reviews").document(userId).collection("reviews").addSnapshotListener { (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            for review in snapshot.documentChanges {
                if review.type == .added {
                    let result = Result {
                        try? review.document.data(as: Review.self)
                    }
                    switch result {
                    
                    case .success( let review):
                        if let review = review {
                            reviews
                                .append(review)
                        }
                    case .failure(let error ):
                        print("DEBUG: error \(error.localizedDescription)")
                    }
                }
                
                if review.type == .modified {
                    let result = Result {
                        try? review.document.data(as: Review.self)
                    }
                    switch result {
                    case .success( let review):
                        if let review = review {
                            reviews.append(review)
                        }
                    case .failure(let error ):
                        print("DEBUG: error \(error.localizedDescription)")
                    }
                }
                
                if review.type == .removed {
                    let result = Result {
                        try? review.document.data(as: Review.self)
                    }
                    switch result {
                    case .success( let review):
                        if let review = review {
                            reviews.append(review)
                        }
                    case .failure(let error ):
                        print("DEBUG: error \(error.localizedDescription)")
                    }
                }
            }
            reviews.forEach{ review in
                let tempReview = review
                reviewsDictionary[tempReview.reviewId] = tempReview
            }
            reviews = Array(reviewsDictionary.values)
            reviews.sort(by: { $0.timestamp! > $1.timestamp! })
            completion(reviews)
            
        }
    }
    
    
}
