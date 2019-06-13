//
//  Utilities.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-06.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import Foundation
import SystemConfiguration
import MMDrawerController
import Firebase
import SwiftyJSON

var MAINQUEUE: DispatchQueue {
    return DispatchQueue.main
}

var FIREBASEQUEUE: DispatchQueue {
    if #available(iOS 10, *) {
        return DispatchQueue.init(label: "FIREBASEQUEUE", qos: .userInitiated, attributes: [], autoreleaseFrequency: .never, target: nil)
    } else {
        return DispatchQueue.init(label: "FIREABSEQUEUE")
    }
}

var UTILITYQUEUE: DispatchQueue {
    if #available(iOS 10.0, *) {
        return DispatchQueue.init(label: "UTILITYQUEUE", qos: .userInteractive, attributes: [], autoreleaseFrequency: .never, target: nil)
    } else {
        return DispatchQueue.init(label: "UTILITYQUEUE")
    }
}

var BACKGROUNDQUEUE: DispatchQueue {
    if #available(iOS 10.0, *) {
        return DispatchQueue.init(label: "BACKGROUNDQUEUE", qos: .background, attributes: [], autoreleaseFrequency: .never, target: nil)
    } else {
        return DispatchQueue.init(label: "BACKGROUNDQUEUE")
    }
}

class InstructionsView:UIView {
    
    let pictureHolder = UIImageView()
    let exit = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews(frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func addSubviews(_ frame: CGRect) {
        
        self.layer.zPosition = 0
        
        pictureHolder.frame = frame
        pictureHolder.contentMode = UIViewContentMode.scaleAspectFit
        pictureHolder.layer.zPosition = 1
        self.addSubview(pictureHolder)
        
        exit.frame=CGRect(x: 10, y: 70, width: 30, height: 30)
        exit.setImage(UIImage(named: "Delete"), for: UIControlState())
        exit.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        exit.layer.zPosition = 2
        self.addSubview(exit)
        
    }
    
}

func signOut () throws {

    try FIRAuth.auth()!.signOut()

}

func passwordCheck(_ text : String) -> Bool{
    
    let capitalLetterRegEx  = ".*[A-Z]+.*"
    let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
    let capitalresult = texttest.evaluate(with: text)
    
    let numberRegEx  = ".*[0-9]+.*"
    let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
    let numberresult = texttest1.evaluate(with: text)
    
    let specialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
    let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
    let specialresult = texttest2.evaluate(with: text)
    
    if capitalresult && numberresult && specialresult {
        return true
    }
    
    return false
    
}

func retrieveErrorFirebase(error:String,callback:@escaping (_ error17014:Bool) -> Void) {

    let errorRegex  = ".*(17014)+.*"
    let errorTest = NSPredicate(format:"SELF MATCHES %@", errorRegex)
    if(errorTest.evaluate(with: error)){
        callback(true)
    }


}

func registrationCallbackError(_ text : String,callback:@escaping (_ fault:String)->Void){
    
    let emailRegex  = ".*(email)+.*"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    if(emailTest.evaluate(with: text)){
        callback("email")
    }
    
    let usernameRegex  = ".*(username)+.*"
    let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegex)
    if(usernameTest.evaluate(with: text)){
        callback("username")
    }
    
}

func isValidEmail(_ testStr:String) -> Bool {
    // print("validate calendar: \(testStr)")
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}

func getDefaultArray (_ key:String) -> [String] {
    
    return UserDefaults.standard.stringArray(forKey: key)!
    
}

func checkForDefault (_ key:String) -> Bool {
    
    if UserDefaults.standard.object(forKey: key) != nil {
        return true
    } else {
        return false
    }

}

func deleteDefault (_ key:String) {

    UserDefaults.standard.removeObject(forKey: key)
    UserDefaults.standard.synchronize()
    
}

func toggleMenu() {
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.drawerContainer?.toggle(MMDrawerSide.left, animated: true, completion: nil)
}

func saveDefaults (_ value: AnyObject, forKey: String) {
    
    UserDefaults.standard.set(value, forKey: forKey)
    UserDefaults.standard.synchronize()
    
}

func getDefault (_ key: String) -> String! {
    
    return UserDefaults.standard.string(forKey: key)
    
}

func getDefaultBool (_ key: String) -> Bool {
    
    return UserDefaults.standard.bool(forKey: key)
    
}

func alertController(_ title:String, message: String, vc: UIViewController) {
    
    let myAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    myAlert.addAction(okAction)
    vc.present(myAlert, animated: true, completion: nil)
    
}

func trimString(_ word:String) -> String {
    
    let cleanString = word.trimmingCharacters(in: CharacterSet.whitespaces)
    return cleanString
    
}

//MARK: Helper functions

let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}

class Reachability {
    
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        return isReachable && !needsConnection
        
    }
}

func controlSegue (_ controller:UIViewController, segues:[String]) {

    switch UIDevice().modelName {
        
    case "iPhone":
        performSegueController("iPhone", controller: controller, segueIdent: segues)
        break;
    case "iPad":
        performSegueController("iPad", controller: controller, segueIdent: segues)
        break;
    case "Simulator":
        performSegueController("Simulator", controller: controller, segueIdent: segues)
        break;
    default:
        break;
        
    }



}

func performSegueController (_ modelName:String, controller:UIViewController, segueIdent:[String]) {
    
    switch modelName {
    
        case "iPhone":
            controller.performSegue(withIdentifier: segueIdent[0], sender: nil)
            break;
        case "Simulator":
            controller.performSegue(withIdentifier: segueIdent[0], sender: nil)
            break;
        case "iPad":
            controller.performSegue(withIdentifier: segueIdent[1], sender: nil)
            break;
        default:
            break;
    
    }
    

}

func returnString(_ user:JSON, callback:@escaping(_ offering:String)->Void) {
    
    var offer = ""
    
    UTILITYQUEUE.async {
        var skills:[String] = []
        
        if let skillOne = user["SkillOne"].string {
            if skillOne != "" {
                skills.append(skillOne)
            }
        }
        if let skillTwo = user["SkillTwo"].string {
            if skillTwo != "" {
                skills.append(skillTwo)
            }
        }
        if let skillThree = user["SkillThree"].string {
            if skillThree != "" {
                skills.append(skillThree)
            }
        }
        
        for i in 1...skills.count {
            
            switch i {
                
            case 1:
                offer = "Offers: \(skills[0])"
            case 2:
                offer = "Offers: \(skills[0]),\(skills[1])"
            case 3:
                offer = "Offers: \(skills[0]),\(skills[1]),\(skills[2])"
            default:
                break
            }
        }
        MAINQUEUE.async {
            callback(offer)
        }
    }
}


public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        
        case "iPhone5,1", "iPhone5,2","iPhone5,3", "iPhone5,4","iPhone6,1", "iPhone6,2","iPhone8,4","iPod5,1","iPod7,1","iPhone3,1", "iPhone3,2", "iPhone3,3","iPhone4,1","iPhone7,2","iPhone8,1", "iPhone9,1", "iPhone9,3","iPhone7,1","iPhone8,2","iPhone9,2", "iPhone9,4":                                return "iPhone"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4","iPad3,1", "iPad3,2", "iPad3,3","iPad3,4", "iPad3,5", "iPad3,6","iPad4,1", "iPad4,2", "iPad4,3","iPad5,3", "iPad5,4","iPad2,5", "iPad2,6", "iPad2,7","iPad4,4", "iPad4,5", "iPad4,6","iPad4,7", "iPad4,8", "iPad4,9","iPad5,1", "iPad5,2","iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":                                  return "iPad"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
        
    }
    
}

public extension UIColor {

    class var defaultBlue:UIColor {
        return UIColor(red: 0/255.0, green: 113/255.0, blue: 188/255.0, alpha: 1.0)
    }


}

public extension String {
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.characters.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end > 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start > 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.characters.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return self[startIndex ..< endIndex]
    }
    
    func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }
    
    func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }
    
    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        
        return self.substring(from: from, to: end)
    }
    
    func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        
        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return self.substring(from: start, to: to)
    }
    
    func substringStart() -> Character {
        
        var first:Character {
            let index = self.index(self.startIndex, offsetBy: 0, limitedBy: self.endIndex)
            return self[index!]
        }
        return first
        
    }
    
}


