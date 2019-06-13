//
//  UserRequests.swift
//  CohesiveU
//
//  Created by Administrator on 2016-11-12.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import AVFoundation

func updateUser (body:Parameters,callback:@escaping (_ success:Bool) -> Void) {
    
    let body:Parameters = body
    
    Alamofire.request("https://cohesivebackend.herokuapp.com/userUpd", method: .put, parameters: body, encoding: JSONEncoding.default).validate().responseJSON { (response) in
        switch response.result {
        case .success:
            callback(true)
        case .failure:
            callback(false)
        }}

}

func updateUserPhoto (body:Parameters,callback:@escaping (_ success:Bool) -> Void) {
    
    let body:Parameters = body
    
    Alamofire.request("https://cohesivebackend.herokuapp.com/userUpdPhoto", method: .put, parameters: body, encoding: JSONEncoding.default).validate().responseJSON { (response) in
        switch response.result {
        case .success:
            callback(true)
        case .failure:
            callback(false)
        }}
    
}

func getUser(username:String,callback:@escaping(_ sucess:Bool, _ data:JSON) -> Void){
    
    Alamofire.request("https://cohesivebackend.herokuapp.com/user/\(username)").validate().responseJSON { (response) in
        switch response.result {
        case .success(let value):
            let json  = JSON(value)
            callback(true,json)
        case .failure(let error):
            let json  = JSON(error)
            callback(false,json)
        }}
    
}

func registerAbroad(body:Parameters,callback:@escaping(_ success:Bool,_ message:JSON) -> Void){
    
    Alamofire.request("https://cohesivebackend.herokuapp.com/user", method: .post, parameters: body, encoding: JSONEncoding.default).responseJSON { (response) in
        let json = JSON(response.result.value ?? "")
        if let status = response.response?.statusCode {
            switch(status){
            case 201:
                callback(true,json)
            case 500:
                callback(false,json)
            default:
                print("went to default")
            }
        }
    }
}

func sendUserReport(body:Parameters,callback:@escaping(_ success:Bool) -> Void){
    
    Alamofire.request("https://cohesivebackend.herokuapp.com/report", method: .post, parameters: body, encoding: JSONEncoding.default).validate().responseJSON { (response) in
        switch response.result {
        case .success:
            callback(true)
        case .failure:
            callback(false)
        }
    }
}




