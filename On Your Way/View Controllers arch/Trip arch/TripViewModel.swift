//
//  TripViewModel.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/12/20.
//

import UIKit

struct TripViewModel {
    let trip: Trip
    
    var userID: String {
        return trip.userID
    }
    var tripID: String {
        return trip.tripID
    }
    var tripDepartureTime: String {
        return trip.tripDepartureTime
    }
    var tripDepartureDate: String {
        return trip.tripDepartureDate
    }
    var tripEstimateTimeArrival: String {
        return trip.tripEstimateTimeArrival
    }
    var currentLocation: String {
        return trip.currentLocation
    }
    var destinationLocation: String {
        return trip.destinationLocation
    }
    var basePrice: String {
        return trip.basePrice
    }
    var packageType: String {
        return trip.packageType
    }
    
    var timestamp: String {
        guard let timestamp = trip.timestamp?.convertDate(formattedString: .formattedType1) else { return "" }
        return timestamp
    }
    
    var packagePickupLocation: String {
        return trip.packagePickupLocation
    }
    
    var packagePickupTime: String {
        return trip.packagePickupTime
    }
    
    var currentLocationInfoAttributedText:  NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: currentLocation,
                                                       attributes: [.foregroundColor : #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1),
                                                                    .font: UIFont.systemFont(ofSize: 14)])
        attributedText.append(NSMutableAttributedString(string: "\n\(tripDepartureDate)\n\(tripDepartureTime)",
                                                        attributes: [.foregroundColor : UIColor.lightGray,
                                                                     .font: UIFont.systemFont(ofSize: 12)]))
        return attributedText
    }
    
    var destinationLocationInfoAttributedText:  NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: destinationLocation,
                                                       attributes: [.foregroundColor : #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1),
                                                                    .font: UIFont.systemFont(ofSize: 14)])
        attributedText.append(NSMutableAttributedString(string: "\n\(tripDepartureDate)\n\(tripEstimateTimeArrival) hour/s",
                                                        attributes: [.foregroundColor : UIColor.lightGray,
                                                                     .font: UIFont.systemFont(ofSize: 12)]))
        return attributedText
    }
    
    init(trip: Trip) { self.trip = trip }
}
