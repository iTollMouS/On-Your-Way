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
}
