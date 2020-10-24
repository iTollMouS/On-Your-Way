//
//  LocationMessage.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/23/20.
//

import Foundation
import CoreLocation
import MessageKit

class LocationMessage: NSObject, LocationItem {
    
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation){
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
    
}
