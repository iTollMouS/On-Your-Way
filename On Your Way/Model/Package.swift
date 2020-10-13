//
//  Package.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/13/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
 
struct Package: Codable, Hashable {
    var userID = ""
    var tripID = ""
    var packageType = ""
    @ServerTimestamp var timestamp = Date()
    var packageImages = [String]()
    var packageID = ""
}
