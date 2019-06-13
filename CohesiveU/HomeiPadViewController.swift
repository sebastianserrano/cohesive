//
//  HomeiPadViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-15.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON

class HomeiPadViewController: UIViewController {
    
    @IBOutlet weak var Logo: UIImageView!
    @IBOutlet weak var SearchBar: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        BackgroundiPad(self)
        SearchBar.addTarget(self, action: #selector(toSearch), for: .editingDidEndOnExit)
        Logo.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Menu(_ sender: AnyObject) {
        toggleMenu()
    }
    
    @objc fileprivate func toSearch() {
        if self.SearchBar.text! == "" {
            alertController("Alert", message: "Please make an entry", vc: self)
            return
        } else {
            if (REACHABLE.connectedToNetwork()) {
                
                ProgressHUD.show("Searching for matches...")
                
                textSearched = trimString(self.SearchBar.text!)
                searchRequest(search: textSearched, callback: { (success) in
                    if(success) {
                        guard let count = matches?.count,count > 0  else {
                            ProgressHUD.showError("Sorry :( we found no matches")
                            return
                        }
                        ProgressHUD.dismiss()
                        self.performSegue(withIdentifier: "toMatches", sender: nil)
                    } else {
                        ProgressHUD.showError("Oops!, something went wrong...Please try again")
                    }
                })
                
            } else {
                ProgressHUD.showError("You appear to be offline, please connect your device")
            }
            
        }
    }
    
    fileprivate func searchRequest (search:String,callback:@escaping (_ success:Bool) -> Void){
        
        if let currentUser = FIRAuth.auth()?.currentUser {
            guard let displayName = currentUser.displayName else {return}
            
            let body:Parameters = [
                "search": search,
                "username": displayName
            ]
            
            Alamofire.request("https://cohesivebackend.herokuapp.com/search", method: .post, parameters: body, encoding: JSONEncoding.default).responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    matches = json
                    callback(true)
                    print("JSON: \(json)")
                case .failure(let error):
                    callback(false)
                    print(error)
                }}
            
        } else {
            
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let alert = UIAlertController(title: "Alert", message: "You appear to be logged out...Please log back in to gain access to your account", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction)in
                appDelegate.defaultView()
            })
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
}
