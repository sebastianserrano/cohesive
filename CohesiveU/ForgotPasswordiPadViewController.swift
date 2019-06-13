//
//  ForgotPasswordiPadViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-11.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit

class ForgotPasswordiPadViewController: UIViewController {

    @IBOutlet weak var Username: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        BackgroundiPad(self)
        self.hideKeyboardWhenTappedAround()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignIn(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Send(_ sender: AnyObject) {
        
        guard Username.text != "" else {ProgressHUD.showError("Please enter your username");return}
        
        ProgressHUD.show("Sending...")
        userPasswordRecoveryAsync()
        
    }
    
    func userPasswordRecoveryAsync() {
        
        /*Backendless.sharedInstance().userService.restorePassword(Username.text, response: { (result:Any?) in
            ProgressHUD.showSuccess("Check your email address!")
            self.Username.text = ""
        }) { (fault:Fault?) in
            ProgressHUD.showError("\(checkForFault((fault?.faultCode)!))")
        }*/
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
