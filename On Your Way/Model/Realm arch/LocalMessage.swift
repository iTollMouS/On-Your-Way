//
//  LocalMessage.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/16/20.
//

import Foundation
import RealmSwift

/// from Realm 
class LocalMessage: Object, Codable {
    
    @objc dynamic var id = ""
    @objc dynamic var chatRoomId = ""
    @objc dynamic var date = Date()
    @objc dynamic var senderName = ""
    @objc dynamic var senderId = ""
    @objc dynamic var senderinitials = ""
    @objc dynamic var readDate = Date()
    @objc dynamic var type = ""
    @objc dynamic var status = ""
    @objc dynamic var message = ""
    @objc dynamic var audioUrl = ""
    @objc dynamic var videoUrl = ""
    @objc dynamic var pictureUrl = ""
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = ""
    @objc dynamic var audioDuration = ""
    
    override class func primaryKey() -> String? { return "id" }
    
}