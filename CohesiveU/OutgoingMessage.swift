//
//  OutgoingMessage.swift
//  Cohesive
//
//  Created by Sebastian Serrano on 2016-07-20.
//  Copyright © 2016 Serranos Fund. All rights reserved.

import Foundation
import Firebase
import SwiftyJSON

class OutgoingMessage {
    
    fileprivate let ref = FIREBASE.child("Message")
    
    var messageDictionary: NSMutableDictionary
    let flagged = false
    
    init (message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date), status, type, flagged], forKeys: ["message" as NSCopying, "senderId" as NSCopying, "senderName" as NSCopying, "date" as NSCopying, "status" as NSCopying, "type" as NSCopying, "flagged" as NSCopying])
    }
    
    init(message: String, latitude: NSNumber, longitude: NSNumber, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, latitude, longitude, senderId, senderName, dateFormatter().string(from: date), status, type, flagged], forKeys: ["message" as NSCopying, "latitude" as NSCopying, "longitude" as NSCopying, "senderId" as NSCopying, "senderName" as NSCopying, "date" as NSCopying, "status" as NSCopying, "type" as NSCopying, "flagged" as NSCopying])
    }
    
    init (message: String, pictureData: Data, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        let pic = pictureData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        
        messageDictionary = NSMutableDictionary(objects: [message, pic, senderId, senderName, dateFormatter().string(from: date), status, type, flagged], forKeys: ["message" as NSCopying, "picture" as NSCopying, "senderId" as NSCopying, "senderName" as NSCopying, "date" as NSCopying, "status" as NSCopying, "type" as NSCopying, "flagged" as NSCopying])
    }
    
    init (message: String, audio:String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, audio, senderId, senderName, dateFormatter().string(from: date), status, type, flagged], forKeys: ["message" as NSCopying, "audio" as NSCopying, "senderId" as NSCopying, "senderName" as NSCopying, "date" as NSCopying, "status" as NSCopying, "type" as NSCopying, "flagged" as NSCopying])
    }
    
    func sendMessage(_ chatRoomID: String, item: NSMutableDictionary, withUser: JSON) {
        
        let reference = ref.child(chatRoomID).childByAutoId()
        guard let withUserID = withUser["firId"].string ?? withUser["withUserUserId"].string, (FIRAuth.auth()?.currentUser != nil) else {return}
        item["messageId"] = reference.key
        
        reference.setValue(item) { (error, ref) -> Void in
            if error != nil {
                print("Error, couldnt send message")
            }
        }
        if getDefaultBool(withUserID) != true {
            createChat((FIRAuth.auth()?.currentUser)!, user2:withUser,lastMessage: (item["message"] as? String)!)
            createSendPushCounter(withUserID,lastMessage: (item["message"] as? String)!)
        }
            UpdateRecents(chatRoomID, lastMessage: (item["message"] as? String)!)
            updatePushCounter(withUserID)
            sendPush(recepient: withUserID,message: (item["message"] as? String)!)

    }
    
}
