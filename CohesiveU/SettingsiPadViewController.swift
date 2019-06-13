//
//  SettingsiPadViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-16.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON

class SettingsiPadViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var ProfilePhoto: UIImageView!
    @IBOutlet weak var SkillOne: UITextField!
    @IBOutlet weak var SkillTwo: UITextField!
    @IBOutlet weak var SkillThree: UITextField!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var Indicator: UIActivityIndicatorView!
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var updatePasswords: UIButton!
    
    
    fileprivate var changedPicture = false
    fileprivate var SkillOneText,SkillTwoText,SkillThreeText:String?
    
    override func viewWillAppear(_ animated: Bool) {
        Indicator.startAnimating()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        BackgroundiPad(self)
        
        Indicator.layer.zPosition = 0
        ProfilePhoto.layer.zPosition = 1
        ProfilePhoto.layer.cornerRadius = 5
        ProfilePhoto.clipsToBounds = true
        
        SkillOne.layer.cornerRadius = 5
        SkillTwo.layer.cornerRadius = 5
        SkillThree.layer.cornerRadius = 5
        SaveButton.layer.cornerRadius = 5
        SaveButton.backgroundColor = UIColor(red: 0/255.0, green: 169/255.0, blue: 157/255.0, alpha: 1.0)
        updatePasswords.layer.cornerRadius = 5
        updatePasswords.backgroundColor = UIColor(red: 0/255.0, green: 169/255.0, blue: 157/255.0, alpha: 1.0)
        
        let uploadPhoto = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.camera, target: self, action: #selector(updatePhoto))
        navigationItem.rightBarButtonItem = uploadPhoto
        
        if REACHABLE.connectedToNetwork() == true {
            loadUserDetails()
            reset()
        } else {
            ProgressHUD.showError("You appear to be offline, please connect your device")
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func Menu(_ sender: AnyObject) {
        toggleMenu()
    }
    
    @IBAction func Update(_ sender: AnyObject) {
        
        if (REACHABLE.connectedToNetwork()) {
            
            guard let skillOne = self.SkillOneText else {return}
            guard let skillTwo = self.SkillTwoText else {return}
            guard let skillThree = self.SkillThreeText else {return}
            
            if ((skillTwo == self.SkillTwo.text! && skillOne == self.SkillOne.text! && skillThree == self.SkillThree.text!) && !(self.changedPicture)) {
                MAINQUEUE.async {
                    ProgressHUD.showError("No changes have been made")
                }
            } else if ((skillTwo != self.SkillTwo.text! || skillOne != self.SkillOne.text! || skillThree != self.SkillThree.text!) && !(self.changedPicture)) {
                self.reset()
                self.updateSkills(callback: { (success, message) in
                    if (success) {
                        MAINQUEUE.async {
                            ProgressHUD.showSuccess(message)
                        }
                    } else {
                        MAINQUEUE.async {
                            ProgressHUD.showError(message)
                        }
                    }
                })
            } else if ((skillTwo == self.SkillTwo.text! && skillOne == self.SkillOne.text! && skillThree == self.SkillThree.text!) && (self.changedPicture)) {
                self.updatePicture(callback: { (success, message) in
                    if (success) {
                        pictureChange = true
                        MAINQUEUE.async {
                            ProgressHUD.showSuccess(message)
                        }
                    } else {
                        MAINQUEUE.async {
                            ProgressHUD.showError(message)
                        }
                    }
                })
                self.changedPicture = false
            } else if ((skillTwo != self.SkillTwo.text! || skillOne != self.SkillOne.text! || skillThree != self.SkillThree.text!) && (self.changedPicture)) {
                self.updateSkills(callback: { (success, message) in
                    if (success) {
                        self.reset()
                        self.updatePicture(callback: { (success, message) in
                            if (success) {
                                pictureChange = true
                                self.changedPicture = false
                                MAINQUEUE.async {
                                    ProgressHUD.showSuccess("Updated skills and profile photo succesfully")
                                }
                            } else {
                                MAINQUEUE.async {
                                    ProgressHUD.showError(message)
                                }
                            }
                        })
                    } else {
                        MAINQUEUE.async {
                            ProgressHUD.showError(message)
                        }
                    }
                })
                
            }
            
        } else {
            MAINQUEUE.async {
                ProgressHUD.showError("You appear to be offline, please connect your device")
            }
        }

    }
    
    @IBAction func UpdatePassword(_ sender: Any) {
        
        if (trimString(self.oldPassword.text!) != trimString(self.newPassword.text!)) {
            ProgressHUD.showError("Passwords dont match")
        } else if ((trimString(self.oldPassword.text!) == trimString(self.newPassword.text!)) && (self.oldPassword.text != "") && (self.newPassword.text != "")) {
            ProgressHUD.show("Updating...")
            FIRAuth.auth()?.currentUser?.updatePassword(self.newPassword.text!) { (errorFirebase) in
                if (errorFirebase == nil) {
                    ProgressHUD.showSuccess("Password has succesfully been updated")
                } else {
                    retrieveErrorFirebase(error: "\(errorFirebase)", callback: { (error) in
                        if (error) {
                            ProgressHUD.showError("This operation is sensitive and requires recent authentication. Log in again before try again to update your password")
                        } else {
                            ProgressHUD.showError("Something went wrong...Please try again later \(error)")
                        }
                    })
                    
                }
            }
        } else {
            ProgressHUD.showError("Passwords cannot be blank")
        }
        
    }
    
    
    
    func updatePhoto(_ sender: AnyObject) {
        
        let camera = Camera(delegate_:self)
        camera.presentPhotoLibrary(self, canEdit: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.ProfilePhoto.image = (info[UIImagePickerControllerOriginalImage] as! UIImage)
        picker.dismiss(animated: true, completion: {self.changedPicture = true})
    }
    
    func reset() {
        SkillTwoText = SkillTwo.text!
        SkillOneText = SkillOne.text!
        SkillThreeText = SkillThree.text!
    }
    
    fileprivate func loadUserDetails () {
        
        UTILITYQUEUE.async {
            if let currentUser = FIRAuth.auth()?.currentUser {
                
                guard let displayName = currentUser.displayName else {return}
                let index = displayName.substringStart()
                
                getUser(username: displayName,callback: { (success,json) in
                    if(success) {
                        print(json)
                        if let path = json["photoPath"].string {
                            getImageFromURL(path, index: index, result: { (image) in
                                if image != nil {
                                    MAINQUEUE.async {
                                        self.Indicator.stopAnimating()
                                        self.ProfilePhoto.image = image!
                                    }
                                } else {
                                    MAINQUEUE.async{
                                        ProgressHUD.showError("Sorry, there was a problem setting up your profile picture")
                                    }
                                }
                            })
                        } else {
                            MAINQUEUE.async {
                                self.Indicator.stopAnimating()
                                self.ProfilePhoto.image = UIImage(named: "Person")
                            }
                        }
                        MAINQUEUE.async {
                            self.SkillOne.text = json["SkillOne"].string!
                            self.SkillTwo.text = json["SkillTwo"].string!
                            self.SkillThree.text = json["SkillThree"].string!
                            self.reset()
                        }
                        
                    } else {
                        MAINQUEUE.async{
                            ProgressHUD.showError("Sorry, there was a problem setting up your profile picture")
                        }
                    }
                })
            }
        }
        
    }
    
    func updateSkills(callback: @escaping (_ success: Bool, _ message:String) -> Void) {
        
        MAINQUEUE.async{
            ProgressHUD.show("Updating...")
        }
        
        UTILITYQUEUE.async {
            
            let skillOne = self.SkillOne.text!.trimmingCharacters(in: CharacterSet.whitespaces)
            let skillTwo = self.SkillTwo.text!.trimmingCharacters(in: CharacterSet.whitespaces)
            let skillThree = self.SkillThree.text!.trimmingCharacters(in: CharacterSet.whitespaces)
            
            if let currentUser = FIRAuth.auth()?.currentUser {
                
                guard let displayName = currentUser.displayName else {return}
                
                let body:Parameters = [
                    "SkillOne": skillOne,
                    "SkillTwo": skillTwo,
                    "SkillThree": skillThree,
                    "username": displayName
                ]
                
                updateUser(body:body, callback: {(success) in
                    if(success) {
                        callback(true, "Updated succesfully")
                    } else {
                        callback(false, "Something went wrong, please try again")
                    }
                })
            }
        }
        
        
    }
    
    func updatePicture(callback: @escaping (_ success: Bool, _ message: String) -> Void) {
        
        MAINQUEUE.async{
            ProgressHUD.show("Updating...")
        }
        
        UTILITYQUEUE.async {
            if let currentUser = FIRAuth.auth()?.currentUser {
                
                guard let displayName = currentUser.displayName else {return}
                let index = displayName.substringStart()
                
                getUser(username: displayName,callback: { (success,json) in
                    if(success) {
                        if let path = json["photoPath"].string {
                            let filePath = fileInDocumentsDirectory(fileName: path)
                            do {
                                try FileManager.default.removeItem(atPath: filePath)
                                uploadImage(self.ProfilePhoto.image!, index: index, ref: "ProfilePhotos", result: { (pathImage) in
                                    if (pathImage != nil) {
                                        let body:Parameters = [
                                            "photoPath": pathImage![0],
                                            "photoPathURL": "\(pathImage![1])",
                                            "username": displayName
                                        ]
                                        updateUserPhoto(body:body, callback: {(success) in
                                            if(success) {
                                                BACKGROUNDQUEUE.async {
                                                    deleteFile(path, index: index, ref: "ProfilePhotos", result: { (success) in
                                                        if (success) {
                                                            print("Updated image succesfully and also deleted the old one")
                                                        }
                                                    })
                                                }
                                                callback(true, "Picture updated")
                                            } else {
                                                callback(false, "Something went wrong, please try again")
                                            }
                                        })
                                    }
                                })
                                
                            } catch {
                                callback(false, "Could not update photo, please try again")
                            }
                            
                        } else {
                            uploadImage(self.ProfilePhoto.image!, index: index, ref: "ProfilePhotos", result: { (pathImage) in
                                if (pathImage != nil) {
                                    let body:Parameters = [
                                        "photoPath": pathImage![0],
                                        "photoPathURL": "\(pathImage![1])",
                                        "username": displayName
                                    ]
                                    updateUserPhoto(body:body, callback: {(success) in
                                        if(success) {
                                            callback(true, "New profile picture updated")
                                        } else {
                                            callback(false, "Something went wrong, please try again")
                                        }
                                    })
                                }
                            })
                        }
                        
                    } else {
                        callback(false, "Something went wrong, please try again")
                    }
                })
            } else {
                callback(false, "You appear to be logged out...Please log back in to gain access to your account")
            }
        }
    }

}
