//
//  ReportiPadViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-17.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON

class ReportiPadViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var Photo: UIImageView!
    @IBOutlet weak var Description: UITextView!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Send: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Report"
        backButton(self)
        self.hideKeyboardWhenTappedAround()
        BackgroundiPad(self)
        
        let uploadPhoto = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.camera, target: self, action: #selector(openLibrary))
        navigationItem.rightBarButtonItem = uploadPhoto
        
        Description.layer.cornerRadius = 3
        Description.layer.masksToBounds = true
        Photo.layer.cornerRadius = 3
        Photo.layer.masksToBounds = true
        Send.layer.cornerRadius = 3
        
        // Do any additional setup after loading the view.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.Photo.image = (info[UIImagePickerControllerOriginalImage] as! UIImage)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func openLibrary () {
        Camera(delegate_: self).presentPhotoLibrary(self,canEdit: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Send(_ sender: AnyObject) {
        
        let defaultText = "Please attach a photo describing the incident and the team will get back to you as soon as possible. Thank you"
        
        if (self.Photo.image != nil  && Description.text != nil) {
            
            guard isValidEmail(Email.text!) == true else {ProgressHUD.showError("Please enter a valid email");return}
            
            if (self.Description.text != defaultText) {
                
                let controller  = UIAlertController(title: "Report", message: "Are you sure of the content of this report? If so, press send to submit for review", preferredStyle: UIAlertControllerStyle.alert)
                let send = UIAlertAction(title: "Send", style: UIAlertActionStyle.default, handler: ({(action:UIAlertAction) in
                    self.sendReport() }))
                let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: ({(action:UIAlertAction) in}))
                controller.addAction(cancel)
                controller.addAction(send)
                
                self.present(controller, animated: true, completion: nil)
                
            }
            
        } else {
            ProgressHUD.showError("Photo and Text are needed")
        }
        
    }
    
    func sendReport() {
        
        ProgressHUD.show("Sending...")
        
        if let reportedUser = withUser {
            
            let displayName = reportedUser["username"].string ?? reportedUser["withUserUsername"].string
            let index = displayName!.substringStart()
            
            var body:Parameters = [
                "userReportingEmail": self.Email.text!,
                "userReporting": (FIRAuth.auth()?.currentUser?.displayName)!,
                "reportedUser": displayName!,
                "description": self.Description.text
            ]
            
            uploadImage(Photo.image!, index: index, ref: "Reporting", result: { (path) in
                if path != nil {
                    body["reportImagePath"] = "\(path![1])"
                    sendUserReport(body: body, callback: {(success) in
                        
                        if(success) {
                            MAINQUEUE.async {
                                ProgressHUD.showSuccess("Report Sent")
                                self.Photo.image = nil
                                self.Description.text = "Report has been sent, the team will update you with the status via email. Thank You"
                            }
                        } else {
                            MAINQUEUE.async {
                                ProgressHUD.showError("Sorry, there was a problem while uploading your report...Please try again later")
                            }
                            BACKGROUNDQUEUE.async {
                                deleteFile("\(path![0])", index: index, ref: "Reporting", result: {(success) in
                                    print("Sucessfully deleted photo uploaded")
                                })
                                
                            }
                            
                        }
                        
                    })
                    
                }
                
            })
            
        }
        
    }

}
