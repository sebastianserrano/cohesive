//
//  WelcomeiPadViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-10.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit
import Firebase
import Batch

class WelcomeiPadViewController: UIViewController {
    
    
    @IBOutlet weak var Logo: UIImageView!
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password: UITextField!
    
    var usernameUser: String?
    var passwordUser: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        BackgroundiPad(self)
        self.hideKeyboardWhenTappedAround()
        Password.addTarget(self, action: #selector(signIn), for: .editingDidEndOnExit)
        Logo.layer.cornerRadius = 5
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Login(_ sender: AnyObject) {
        
        if !(firstConnection) {
            FIRDatabase.database().persistenceEnabled = true
            firstConnection = true
        }
        signIn()
        
    }
    
    fileprivate func loginUser(_ email: String, password: String) {
        
        let trimmedEmail = trimString(email)
        let trimmedPassword = trimString(password)
        
        FIRAuth.auth()?.signIn(withEmail: trimmedEmail, password: trimmedPassword) { (user, error) in
            
            self.Password.text = ""
            
            if user != nil {
                BACKGROUNDQUEUE.async{
                    if getDefault("user_name") == nil {
                        saveDefaults(FIRAuth.auth()?.currentUser!.displayName as AnyObject, forKey: "user_name")
                    }
                    
                    if (pushEnabled) {
                        let editor = BatchUser.editor()
                        editor.setIdentifier(FIRAuth.auth()?.currentUser!.uid)
                        editor.save()
                    }
                    MAINQUEUE.async {
                        ProgressHUD.dismiss()
                        // Navigate to Protected Page
                        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.buildUserInterface()
                    }
                }
            } else {
                ProgressHUD.showError("Sorry, Couldnt login user...Please try again")
                
            }
        }
    }
    
    @objc fileprivate func signIn () {
        
        guard (REACHABLE.connectedToNetwork()) else {ProgressHUD.showError("You appear to be offline, please connect your device in order to Log in");return}
        
        if Username.text != "" && Password.text != "" {
            
            self.usernameUser = Username.text
            self.passwordUser = Password.text
            
            ProgressHUD.show("Logging in...")
            
            //login user
            loginUser(usernameUser!, password: passwordUser!)
            
        } else {
            //show an error to user
            ProgressHUD.showError("Username and password are required")
            
        }
        
    }
    
}
