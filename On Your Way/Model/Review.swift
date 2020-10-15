//
//  Review.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/15/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
 
struct Review: Codable {
    var userID = ""
    @ServerTimestamp var timestamp = Date()
    var reviewComment = ""
    var rate : Double = 0.0
    var reviewId = ""
}

