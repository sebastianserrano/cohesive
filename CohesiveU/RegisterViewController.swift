//
//  RegisterViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-06.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Alamofire
import SwiftyJSON
import Batch

class RegisterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var PasswordText: UITextField!
    @IBOutlet weak var RepeatPasswordText: UITextField!
    
    @IBOutlet weak var SkillOne: UITextField!
    @IBOutlet weak var SkillTwo: UITextField!
    @IBOutlet weak var SkillThree: UITextField!
    
    @IBOutlet weak var PhotoHolder: UIImageView!
    @IBOutlet weak var RegisterButton: UIButton!
    
    fileprivate var email,usernameField,password,skillOneText,skillTwoText,skillThreeText: String?
    fileprivate var avatarImage: UIImage?
    fileprivate var profilePhoto = false
    
    fileprivate let ref = FIREBASE.child("Users")
    fileprivate var agree = false
    
    override func viewWillAppear(_ animated: Bool) {
        fromRecent = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ProgressHUD.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Background(self)
        self.hideKeyboardWhenTappedAround()
        
        RegisterButton.backgroundColor = UIColor(red: 0/255.0, green: 169/255.0, blue: 157/255.0, alpha: 1.0)
        RegisterButton.layer.cornerRadius = 5
        PhotoHolder.layer.cornerRadius = 5
        PhotoHolder.clipsToBounds = true
        
        let uploadPhotoButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.camera, target: self, action: #selector(openPhotoLibrary))
        navigationItem.rightBarButtonItem = uploadPhotoButton
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func RegisterTap(_ sender: AnyObject) {
        
        guard (REACHABLE.connectedToNetwork()) else {ProgressHUD.showError("You appear to be offline, please connect your device in order to register");return}
        
        if !(firstConnection) {
            FIRDatabase.database().persistenceEnabled = true
            firstConnection = true
        }
        
        if Username.text != "" && PasswordText.text != "" && Email.text != "" && RepeatPasswordText.text != "" && (SkillOne.text != "" || SkillTwo.text != "" || SkillThree.text != "") {
            
            guard isValidEmail(self.Email.text!) else {
                ProgressHUD.showError("Please enter a valid email")
                return
            }
            
            guard self.PasswordText.text!.characters.count > 6 else {
                ProgressHUD.showError("Password has to be longer than 6 characters")
                return
            }
            
            guard passwordCheck(self.PasswordText.text!) else {
                ProgressHUD.showError("Password must contain one Capital letter, a number, and a special character")
                return
            }
            
            guard self.PasswordText.text == self.RepeatPasswordText.text else {ProgressHUD.showError("Passwords dont match");return}
            
            let UELA = UIAlertController(title: "End User License Agreement", message: "License \n\n Under this End User License Agreement (the \("Agreement")), Serranos Fund (the \("Vendor")) grants to the user (the \("Licensee")) a non-exclusive and non-transferable license (the \("License")) to use Cohesive (the \("Software")).\("Software") includes the executable Application and any related printed, electronic and online documentation and any other files that may accompany the product. Title, copyright, intellectual property rights and distribution rights of the Software remain exclusively with the Vendor. Intellectual property rights include the look and feel of the Software. This Agreement constitutes a license for use only and is not in any way a transfer of ownership rights to the Software. The rights and obligations of this Agreement are personal rights granted to the Licensee only. The Licensee may not transfer or assign any of the rights or obligations granted under this Agreement to any other person or legal entity. The Licensee may not make available the Software for use by one or more third parties. Failure to comply with any of the terms under the License section will be considered a material breach of this Agreement.\n\n Restrictions on use \n\n You shall use the Software strictly in accordance with the terms of the Related Agreements and shall not: (a) decompile, reverse engineer, disassemble, attempt to derive the source code of, or decrypt the Software; (b) violate any applicable laws, rules or regulations in connection with your access or use of the Software; (c) remove, alter or obscure any proprietary notice (including any notice of copyright or trademark) of Vendor or its affiliates, partners, suppliers or the licensors of the Software; (d) use the Software for any revenue generating endeavor, commercial enterprise, or other purpose for which it is not designed or intended; (e) [install, use or permit the Software to exist on more than one Mobile Device at a time or on any other mobile device or computer]; (f) [distribute the Software to multiple Mobile Devices];(g) use the Software to send automated queries to any website or to send any unsolicited commercial e-mail; or (h) use any proprietary information or interfaces of Vendor or other intellectual property of Vendor in the design, development, manufacture, licensing or distribution of any applications, accessories or devices for use with the Software. By using the Software, you represent and warrant that (a) you are 17 years of age or older and you agree to be bound by this Agreement; (b) if you are under 17 years of age, you have obtained verifiable consent from a parent or legal guardian; and (c) your use of the Software does not violate any applicable law or regulation. Your access to the Software may be terminated without warning if Vendor believes, in its sole discretion, that you are under the age of 17 years and have not obtained verifiable consent from a parent or legal guardian. If you are a parent or legal guardian and you provide your consent to your child’s use of the Software, you agree to be bound by this Agreement in respect to your child’s use of the Software. Any material that is deemed to be objectionable or abusive to any user will cause the termination of the license provided by the Vendor for the user who published such content. A report submitted by a user with the minimum requirements for such, will be reviewed within 24 hours and upon acceptance, such content will be removed as well as the user who published it.\n\n Limitation of Liability \n\n The Software is provided by the Vendor and accepted by the Licensee \("as is"). The Vendor will not be liable for any general, special, incidental or consequential damages including, but not limited to, loss of production, loss of profits, loss of revenue, loss of data, or any other business or economic disadvantage suffered by the Licensee arising out of the use or failure to use the Software. The Vendor makes no warranty expressed or implied regarding the fitness of the Software for a particular purpose or that the Software will be suitable or appropriate for the specific requirements of the Licensee. The Vendor does not warrant that use of the Software will be uninterrupted or error-free. The Licensee accepts that Software in general is prone to bugs and flaws within an acceptable level as determined in the industry. The Vendor may remedy any non-conforming Software by providing a refund of the purchase price or, at the Vendor's option, repair or replace any or all of the Software.\n\n Acceptance \n\n All terms, conditions and obligations of this Agreement will be deemed to be accepted by the Licensee \(("Acceptance")) on registration of the Software with the Vendor.\n\n  Miscellaneous \n\n This Agreement can only be modified in writing signed by both the Vendor and the Licensee. This Agreement does not create or imply any relationship in agency or partnership between the Vendor and the Licensee. Headings are inserted for the convenience of the parties only and are not to be considered when interpreting this Agreement. Words in the singular mean and include the plural and vice versa. Words in the masculine gender include the feminine gender and vice versa. Words in the neuter gender include the masculine gender and the feminine gender and vice versa. If any term, covenant, condition or provision of this Agreement is held by a court of competent jurisdiction to be invalid, void or unenforceable, it is the parties' intent that such provision be reduced in scope by the court only to the extent deemed necessary by that court to render the provision reasonable and enforceable and the remainder of the provisions of this Agreement will in no way be affected, impaired or invalidated as a result. This Agreement contains the entire agreement between the parties. All understandings have been included in this Agreement. Representations which may have been made by any party to this Agreement may in some way be inconsistent with this final written Agreement. All such statements are declared to be of no value in this Agreement. Only the written terms of this Agreement will bind the parties. This Agreement and the terms and conditions contained in this Agreement apply to and are binding upon the Vendor's successors and assigns.\n\n Termination \n\n This Agreement will be terminated and the License forfeited where the Licensee has failed to comply with any of the terms of this Agreement or is in breach of this Agreement. On termination of this Agreement for any reason, the Licensee will promptly destroy the Software or return the Software to the Vendor.", preferredStyle: UIAlertControllerStyle.alert)
            let Agree = UIAlertAction(title: "Agree", style: UIAlertActionStyle.default, handler: ({(action:UIAlertAction)  in  self.agree = true; self.registerPreliminary()}))
            let Disagree = UIAlertAction(title: "Disagree", style: .default, handler: ({(action:UIAlertAction) in return}))
            UELA.addAction(Disagree)
            UELA.addAction(Agree)
            self.present(UELA, animated: true, completion: nil)
            
        } else {ProgressHUD.showError("Username, Email, Password, Password Repeat, and at least one skill are required")}
        
        
    }
    
    
    
    @IBAction func SignIn(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
 
    @objc func openPhotoLibrary () {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = Camera(delegate_: self)
        
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert: UIAlertAction) -> Void in
            camera.presentCamera(self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert : UIAlertAction) -> Void in
            camera.presentPhotoLibrary(self, canEdit: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (aler : UIAlertAction) -> Void in
            print("Cancelled", terminator: "")
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    
    }
    
    //MARK: UIImagepickercontroller delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.avatarImage = (info[UIImagePickerControllerEditedImage] as! UIImage)
        PhotoHolder.image = self.avatarImage
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Backendless user registration
    
    fileprivate func registerPreliminary() {
        
        if self.avatarImage != nil {profilePhoto = true}
    
        ProgressHUD.show("Registering...")
        
        let username = trimString(self.Username.text!)
        let email = trimString(self.Email.text!)
        let skillOne = trimString(self.SkillOne.text!)
        let skillTwo = trimString(self.SkillTwo.text!)
        let skillThree = trimString(self.SkillThree.text!)
        
        self.register(username, emailUser: email, passwordUser: self.RepeatPasswordText.text!, skill1: skillOne, skill2: skillTwo, skill3: skillThree, profilePhoto: profilePhoto)
        
    }
    
    fileprivate func register(_ username: String, emailUser: String, passwordUser: String, skill1: String, skill2: String, skill3: String, profilePhoto:Bool) {
        
        let lowerCaseEmail = emailUser.lowercased()
        var body:Parameters = [
            "SkillOne": skill1,
            "SkillTwo": skill2,
            "SkillThree": skill3,
            "username": username,
            "email": lowerCaseEmail
        ]
        
        FIREBASEQUEUE.async {
            switch profilePhoto {
            case false:
                FIRAuth.auth()?.createUser(withEmail: lowerCaseEmail, password: passwordUser, completion: { (user, error) in
                    if user != nil {
                        body["firId"] = FIRAuth.auth()?.currentUser?.uid
                        registerAbroad(body: body, callback: { (success,json) in
                            if(success) {
                                self.loginUser(email: lowerCaseEmail, password: passwordUser, displayName:username)
                            } else {
                                registrationCallbackError(json["Failure"].string!, callback: { (test) in
                                    if test == "username" {
                                        MAINQUEUE.async {
                                            ProgressHUD.showError("Sorry, username already exists...Please choose a different one")
                                        }
                                    } else {
                                        MAINQUEUE.async {
                                            ProgressHUD.showError("Sorry, email already exists...Please choose a different one")
                                        }
                                    }
                                })
                            }
                        })
                    } else {
                        MAINQUEUE.async {
                            ProgressHUD.showError("Sorry, Couldnt register user...Please try again later")
                        }
                    }
                })
                break;
            case true:
                let index = username.substringStart()
                uploadImage(self.PhotoHolder.image!, index:index, ref: "ProfilePhotos", result: { (path) in
                    if path != nil {
                        FIRAuth.auth()?.createUser(withEmail: lowerCaseEmail, password: passwordUser, completion: { (user, error) in
                            if user != nil {
                                body["photoPath"] = path![0]
                                body["photoPathURL"] = "\(path![1])"
                                body["firId"] = FIRAuth.auth()?.currentUser?.uid
                                registerAbroad(body: body, callback: { (success,json) in
                                    if(success) {
                                        self.loginUser(email: lowerCaseEmail, password: passwordUser, displayName:username)
                                    } else {
                                        let json = JSON(json)
                                        registrationCallbackError(json["Failure"].string!, callback: { (test) in
                                            if test == "username" {
                                                MAINQUEUE.async {
                                                    ProgressHUD.showError("Sorry, username already exists...Please choose a different one")
                                                }
                                            } else {
                                                MAINQUEUE.async {
                                                    ProgressHUD.showError("Sorry, email already exists...Please choose a different one")
                                                }
                                            }
                                        })
                                        deleteFile("\(path![0])", index: index, ref: "ProfilePhotos", result: { (sucess) in
                                            if(sucess){
                                                print("Sucessfully deleted photo uploaded")
                                            }
                                        })
                                    }
                                })
                            } else {
                                MAINQUEUE.async {
                                    ProgressHUD.showError("Sorry, Couldnt register user...Please try again later")
                                }
                                deleteFile("\(path![0])", index: index, ref: "ProfilePhotos", result: { (sucess) in
                                    if(sucess){
                                        print("Sucessfully deleted photo uploaded")
                                    }
                                })
                            }
                        })
                    }
                })
                break;
            }
        }
    }
    
    fileprivate func loginUser(email:String, password: String, displayName:String) {
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            
            if user != nil {
                let changeRequest = user?.profileChangeRequest()
                changeRequest?.displayName = displayName
                changeRequest?.commitChanges { error in
                    if error != nil {
                        ProgressHUD.showError("Sorry, Account was created but couldnt log in user automatically...Please try to log in manually from our welcome page")
                        return
                    } else {
                        self.loginToMain()
                    }
                }
            } else {
                ProgressHUD.showError("Sorry, Account was created but couldnt log in user automatically...Please try to log in manually from our welcome page")
                return
            }
            
        }
        
    }
    
    @objc fileprivate func loginToMain () {
        
        BACKGROUNDQUEUE.async{
            saveDefaults(FIRAuth.auth()?.currentUser?.displayName as AnyObject, forKey: "user_name")
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
    }
}
