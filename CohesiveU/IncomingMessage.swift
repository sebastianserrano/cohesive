//
//  IncomingMessage.swift
//  Cohesive
//
//  Created by Sebastian Serrano on 2016-07-27.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import Firebase

class IncomingMessage {
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    func createMessage(_ dictionary: NSDictionary) -> JSQMessage? {
        
        var message: JSQMessage?
        
        let type = dictionary["type"] as? String
        
        if type == "text" {
            //create text message
            message = createTextMessage(dictionary)
        }
        if type == "location" {
            //create loacation message
            message = createLocationMessage(dictionary)
        }
        if type == "picture" {
            //create picture message
            message = createPictureMessage(dictionary)
        }
        if type == "audio" {
            message = createAudioMessage(dictionary)
        }
        
        if let mes = message {
            return mes
        }
        
        return nil
    }
    
    fileprivate func createTextMessage(_ item: NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        
        let date = dateFormatter().date(from: (item["date"] as? String)!)
        let text = item["message"] as? String
        
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
    

    fileprivate func createLocationMessage(_ item : NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        
        let date = dateFormatter().date(from: (item["date"] as? String)!)

        let latitude = item["latitude"] as? Double
        let longitude = item["longitude"] as? Double
        
        let mediaItem = JSQLocationMediaItem(location: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returneOutgoingStatusFromUser(userId!)
        
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        
        mediaItem?.setLocation(location) { () -> Void in
            // update our collectionView
            self.collectionView.reloadData()
        }
        
        
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
    }
    
    fileprivate func returneOutgoingStatusFromUser(_ senderId: String) -> Bool {
        
        if senderId == FIRAuth.auth()?.currentUser?.uid {
            //outgoing
            return true
        } else {
            return false
        }
    }
    
    fileprivate func createPictureMessage(_ item: NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        
        let date = dateFormatter().date(from: (item["date"] as? String)!)

        let mediaItem = JSQPhotoMediaItem(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returneOutgoingStatusFromUser(userId!)
        
        imageFromData(item) { (image: UIImage?) -> Void in
            mediaItem?.image = image
            self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
    }
    
    fileprivate func imageFromData(_ item: NSDictionary, result : (_ image: UIImage?) ->Void) {
        
        var image: UIImage?
        
        let decodedData = Data(base64Encoded: (item["picture"] as? String)!, options: NSData.Base64DecodingOptions(rawValue: 0))
        
        image = UIImage(data: decodedData!)
        
        result(image)
    }
    
    fileprivate func createAudioMessage (_ item: NSDictionary) -> JSQMessage {
    
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        
        let date = dateFormatter().date(from: (item["date"] as? String)!)
        let audioURL = NSURL(fileURLWithPath: item["audio"] as! String)
        
        let mediaItem = AudioMessage(withFileURL: audioURL, maskOutGoing:returneOutgoingStatusFromUser(userId!))
        
        downloadAudio(audioURL: item["audio"] as! String, result: {(fileName) in
        
            print("THIS IS THE AUDIO URL FOR THE FILE DOWNLOADED \(fileName)")
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
            mediaItem.status = 2
            mediaItem.fileURL = url
            
            self.collectionView.reloadData()
        
        })
        
        return JSQMessage(senderId:userId!, senderDisplayName: name!, date: date, media: mediaItem)
    
    
    }
    
}
