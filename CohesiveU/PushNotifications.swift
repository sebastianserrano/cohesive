//
//  PushNotifications.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-12.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import Foundation
import Firebase

@objc
public class BatchClientPush: NSObject, URLSessionDelegate {
    private static let apiURLFormat = "https://api.batch.com/1.0/%@/transactional/send"
    private static let apiMaxRecipients = 10000
    private static let jsonContentType = "application/json"
    
    private let apiKey: String
    private let restKey: String
    
    private let session = URLSession(configuration: .default)
    
    // TODO: Document all this
    public private(set) var message = BatchClientPushMessage()
    public private(set) var recipients = BatchClientPushRecipients()
    public var sandbox = false
    public var customPayload: [String: Any]? = nil
    public var groupId = "ios_push"
    public var deeplink: String? = nil
    
    init?(apiKey: String, restKey: String) {
        
        if apiKey.characters.count != 30 {
            return nil
        }
        
        if restKey.characters.count != 32 {
            return nil
        }
        
        self.apiKey = apiKey
        self.restKey = restKey
    }
    
    func send(completionHandler: @escaping (_ response: String?, _ error: NSError?) -> ()) {
        guard recipients.count > 0 else {
            completionHandler(nil, NSError(domain: "BatchClientPushErrorDomain",
                                           code: -2,
                                           userInfo: [NSLocalizedDescriptionKey: "Validation error: No recipients were specified"]))
            return
        }
        
        guard recipients.count <= BatchClientPush.apiMaxRecipients else {
            completionHandler(nil, NSError(domain: "BatchClientPushErrorDomain",
                                           code: -2,
                                           userInfo: [NSLocalizedDescriptionKey: "Validation error: Recipients count exceeds \(BatchClientPush.apiMaxRecipients)"]))
            return
        }
        
        var jsonPayload: Data?
        
        if let customPayload = customPayload {
            do {
                jsonPayload = try JSONSerialization.data(withJSONObject: customPayload, options: [])
            } catch let error as NSError {
                completionHandler(nil, NSError(domain: "BatchClientPushErrorDomain",
                                               code: -3,
                                               userInfo: [
                                                NSUnderlyingErrorKey: error,
                                                NSLocalizedDescriptionKey: "Validation error: An error occurred while serializing the custom payload to JSON. Make sure it's a dictionary only made of foundation objects compatible with NSJSONSerialization. (Additional info: \(error.localizedDescription)"
                    ]))
                return
            }
        }
        
        guard let request = buildRequest(customPayload: jsonPayload) else {
            completionHandler(nil, NSError(domain: "BatchClientPushErrorDomain",
                                           code: -1,
                                           userInfo: [NSLocalizedDescriptionKey: "Unknown error while building the HTTP request"]))
            return
        }
        
        let task = session.dataTask(with: request, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            var stringResponseData: String?
            if let data = data {
                stringResponseData = String(data: data, encoding: String.Encoding.utf8)
            }
            
            var userFacingError = error as? NSError
            
            if let response = response as? HTTPURLResponse
                , response.statusCode != 201 && error == nil {
                userFacingError = NSError(domain: "BatchClientPushErrorDomain",
                                          code: -4,
                                          userInfo: [
                                            NSLocalizedDescriptionKey: "Server error: Status code \(response.statusCode), please see the response string for more info."
                    ])
            }
            
            completionHandler(stringResponseData, userFacingError)
        })
        
        task.resume()
    }
    
    private func buildRequest(customPayload: Data?) -> URLRequest? {
        guard let url = URL(string: String(format: BatchClientPush.apiURLFormat, apiKey)) else { return nil }
        
        guard let body = buildRequestBody(customPayload: customPayload) else { return nil }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue(restKey, forHTTPHeaderField: "X-Authorization")
        request.setValue(BatchClientPush.jsonContentType, forHTTPHeaderField: "Accept")
        request.setValue(BatchClientPush.jsonContentType, forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    private func buildRequestBody(customPayload: Data?) -> Data? {
        var body: [String: Any] = [:]
        body["group_id"] = groupId
        body["sandbox"] = sandbox
        body["recipients"] = [
            "custom_ids": recipients.customIds,
            "tokens": recipients.tokens,
            "install_ids": recipients.installIds
        ]
        
        body["message"] = message.dictionaryRepresentation()
        
        if let customPayload = customPayload {
            body["custom_payload"] = String(data: customPayload, encoding: String.Encoding.utf8)
        }
        
        if let deeplink = deeplink {
            body["deeplink"] = deeplink
        }
        
        do {
            return try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            return nil
        }
    }
    
}

@objc
public class BatchClientPushMessage: NSObject {
    var title: String?
    var body: String = ""
    
    public func dictionaryRepresentation() -> [String: Any] {
        var res = ["body": body]
        if let title = title {
            res["title"] = title
        }
        
        return res
    }
    
}

@objc
public class BatchClientPushRecipients: NSObject {
    var customIds: [String] = []
    var installIds: [String] = []
    var tokens: [String] = []
    
    public var count: Int {
        get {
            return customIds.count + installIds.count + tokens.count
        }
    }
    
}

func sendPush(recepient:String,message:String){
    
    if let pushClient = BatchClientPush(apiKey: "DEV5845FC45C86B23C17E5FB30CFAE", restKey: "54a04f6379d4d5f23c35f20d7e8cdae2") {
        
        pushClient.sandbox = true
        pushClient.groupId = "Messages"
        pushClient.message.body = message
        pushClient.recipients.customIds = [recepient]
        
        pushClient.send { (response, error) in
            if let error = error {
                print("Something happened while sending the push: \(response) \(error.localizedDescription)")
            } else {
                print("Push sent \(response)")
            }
        }
        
    } else {
        print("Error while initializing BatchClientPush")
    }

}


func createSendPushCounter(_ userId:String,lastMessage:String) {
    FIREBASE.child("PushNotifications").queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: {
        snapshot in
        
        var createPush = true
        
        if snapshot.exists() {
            let recents = (snapshot.value! as AnyObject).allValues
            
            if let recent = recents?.first as? NSDictionary {
                if recent["userId"] as! String == userId {
                    createPush = false
                }
            }
        }
        
        if (createPush) {
            
            let dateString = dateFormatter().string(from: Date())
            let ref = FIREBASE.child("PushNotifications").child(userId)
            let values = ["userId":userId,"counter" : 1, "date" : dateString] as [String : Any]
            
            ref.setValue(values) { (error, fir) -> Void in
                if error != nil {
                    print("couldnt save counter")
                }
            }
        }
    })
}

func retrievePushCounter (_ userId:String, callBack:@escaping (_ counter:Int)->Void) {
    
    FIREBASE.child("PushNotifications").queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: {
        snapshot in
        
        if snapshot.exists() {
            let recents = (snapshot.value! as AnyObject).allValues
            
            if let recent = recents?.first as? NSDictionary {
                print(recent)
                let counter = (recent["counter"] as? Int)!
                callBack(counter)
            }
        }
    })
    
}

func updatePushCounter (_ userId:String) {
    
    FIREBASE.child("PushNotifications").queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: {
        snapshot in
        
        if snapshot.exists() {
            let recents = (snapshot.value! as AnyObject).allValues
            
            if let recent = recents?.first as? NSDictionary {
                let counter = (recent["counter"] as? Int)!
                updateCounter(userId,counter:counter)
            }
        }
    })
    
}

func updateCounter(_ child:String,counter:Int) {
    
    FIREBASE.child("PushNotifications").child(child).updateChildValues(["counter" : counter+1]) { (error, ref) -> Void in
        if error != nil {
            print("Error couldnt update recents counter: \(error!.localizedDescription)")
        }
    }
}

func subtractCounter(_ child:String,currentCounter:Int,counter:Int) {
    
    FIREBASE.child("PushNotifications").child(child).updateChildValues(["counter" : currentCounter-counter]) { (error, ref) -> Void in
        if error != nil {
            print("Error couldnt update push counter: \(error!.localizedDescription)")
        }
    }
}

func withUserIdFromArray(_ users: [String]) -> String? {
    
    var id: String?
    
    for userId in users {
        if userId != FIRAuth.auth()?.currentUser?.uid {
            id = userId
        }
    }
    return id
}

