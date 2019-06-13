//
//  MatchUserViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-12.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class MatchUserViewController: UIViewController {
    
    
    @IBOutlet weak var ProfilePhoto: UIImageView!
    @IBOutlet weak var SkillOne: UITextField!
    @IBOutlet weak var SkillTwo: UITextField!
    @IBOutlet weak var SkillThree: UITextField!
    @IBOutlet weak var Indicator: UIActivityIndicatorView!
    @IBOutlet weak var Report: UIButton!
    
    fileprivate var lock = false
    fileprivate var buttonBlock = UIBarButtonItem()
    
    override func viewWillAppear(_ animated: Bool) {
        Indicator.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IndicatorSet = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton(self)
        
        if (fromRecent){
            QueryBlockedField(chatRoomId, callBack: { (blocked) in
                if (blocked) {
                    self.buttonBlock = UIBarButtonItem(image: UIImage(named: "Lock"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.Block))
                    self.lock = true
                    self.navigationItem.rightBarButtonItem = self.buttonBlock
                } else {
                    self.buttonBlock = UIBarButtonItem(image: UIImage(named: "Unlock"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.Block))
                    self.lock = false
                    self.navigationItem.rightBarButtonItem = self.buttonBlock
                }
            })
        }
        
        Background(self)
        
        Indicator.layer.zPosition = 0
        ProfilePhoto.layer.zPosition = 1
        ProfilePhoto.layer.cornerRadius = 2
        Report.layer.cornerRadius = 2
        ProfilePhoto.clipsToBounds = true
        
        loadUserDetails()
        
    }
    
    @IBAction func Back(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc fileprivate func Block (_ sender:UIButton) {
        
        guard let recent = withUser else {return}
        if (!lock) {
            buttonBlock.image = UIImage(named: "Lock")
            UpdateBlockedField(recent, blocked: true)
            lock = true
        } else {
            buttonBlock.image = UIImage(named: "Unlock")
            UpdateBlockedField(recent, blocked: false)
            lock = false
        }
        
    }
    
    fileprivate func loadUserDetails () {
        
        guard let user = withUser, let username = withUser["username"].string ?? withUser["withUserUsername"].string else {return}
        self.title = username
        
        if withUser["SkillOne"].string != nil {
        
            if let imageURL = user["photoPathURL"].string {
                self.ProfilePhoto.af_setImage(withURL: URL(string: imageURL)!)
            } else {
                self.ProfilePhoto.image = UIImage(named: "Person")
            }
            
            SkillOne.text = user["SkillOne"].string!
            SkillTwo.text = user["SkillTwo"].string!
            SkillThree.text = user["SkillThree"].string!
        
        } else {
        
            getUser(username: username, callback: { (success, json) in
                if(success) {
                    guard let skillOne = json["SkillOne"].string, let skillTwo = json["SkillTwo"].string, let skillThree = json["SkillThree"].string else {return}
                    
                    if let imageURL = json["photoPathURL"].string {
                        self.ProfilePhoto.af_setImage(withURL: URL(string: imageURL)!)
                    } else {
                        self.ProfilePhoto.image = UIImage(named: "Person")
                    }
                    
                    self.SkillOne.text = skillOne
                    self.SkillTwo.text = skillTwo
                    self.SkillThree.text = skillThree
                } else {
                
                    MAINQUEUE.async {
                        ProgressHUD.showError("Sorry, we were unable to load \(username)'s credentials")
                    }
                }
            })
        
        }
    
    }

}
