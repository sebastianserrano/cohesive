//
//  iPadRegistrationTwoViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-08.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit

class iPadRegistrationTwoViewController: UIViewController {

    
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var RepeatPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        BackgroundiPad(self)
        self.hideKeyboardWhenTappedAround()
        
        Email.addTarget(self, action: #selector(setEmailForDic), for: .editingDidEnd)
        Username.addTarget(self, action: #selector(setUsernameForDic), for: .editingDidEnd)
        Password.addTarget(self, action: #selector(setPasswordForDic), for: .editingDidEnd)
        RepeatPassword.addTarget(self, action: #selector(setPasswordResetForDic), for: .editingDidEnd)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func setEmailForDic () {
        EmailiPad = Email.text
    }
    
    @objc func setUsernameForDic () {
        UsernameiPad = Username.text
    }
    
    @objc func setPasswordForDic () {
        PasswordiPad = Password.text
    }
    
    @objc func setPasswordResetForDic () {
        PasswordResetiPad = RepeatPassword.text
    }

}
