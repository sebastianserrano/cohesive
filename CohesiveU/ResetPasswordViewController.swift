//
//  ResetPasswordViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-11.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var TextView: UITextView!
    @IBOutlet weak var EmailText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Background(self)
        TextView.layer.cornerRadius = 5
        TextView.clipsToBounds = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Send(_ sender: AnyObject) {
        
        guard EmailText.text != "" else {ProgressHUD.showError("Please enter your email");return}
        
        ProgressHUD.show("Sending...")
        userPasswordRecoveryAsync()
        
    }
    
    
    func userPasswordRecoveryAsync() {
    
        FIRAuth.auth()?.sendPasswordReset(withEmail: EmailText.text!) { error in
            if error != nil {
                ProgressHUD.showError("Sorry, couldnt send email...Please try again later")
            } else {
                ProgressHUD.showSuccess("Check your email address!")
                self.EmailText.text = ""
            }
        }
        
    }
    
    
    @IBAction func SignIn(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}
