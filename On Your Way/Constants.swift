//
//  Constants.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/10/20.
//

import Foundation



public let kSERVERKEY = "AAAAUwmiLvA:APA91bHzWTAwuNV-F0zBcCygN-m7CPWIV1VrMV2hoUHX0boWHZpbOy-AulOoQ0_JBZoI8QxUgVBuDgyvLy8W2a8iG-gtAoAh70Nv66bBoWwS6hCFQmBAz2hM-85neX9pmNsI8WsTHOzW"
let userDefaults = UserDefaults.standard
public let storageReferenceKey = "gs://onyourwayappios.appspot.com"
public let kNUMBEROFMESSAGES = 12
public let kCURRENTUSER = "currentUser"
public let kCHATROOMID = "chatRoomId"
public let kSENDERID = "senderId"
public let kSTATUS = "status"
public let kFRISTRUN = "firstRUN"
public let kSENT = "Sent"
public let kREAD = "Read"
public let kTEXT = "text"
public let kPHOTO = "photo"
public let kVIDEO = "video"
public let kAUDIO = "audio"
public let kLOCATION = "location"
public let kDATE = "date"
public let kREADDATE = "date"
public let tripsCollection = "trips"

enum PackageStatus: String, CaseIterable, Codable {
    case packageIsPending = "package is pending"
    case packageIsRejected = "package is rejected"
    case packageIsAccepted = "package is accepted"
    case packageIsDelivered = "package is delivered"
}
