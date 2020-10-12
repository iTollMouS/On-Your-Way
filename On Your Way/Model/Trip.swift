//
//  Trip.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/11/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
 

struct Trip: Codable {
    var userID = ""
    var tripID = ""
    var tripDateAnnounced = ""
    var tripDepartureTime = ""
    var tripEstimateArrival = ""
    var fromCity = ""
    var destinationCity = ""
    var basePrice = ""
    var packageType = ""
    @ServerTimestamp var timestamp = Date()
    var pickupLocation = ""
    var timeForPickingPackages = ""
}
