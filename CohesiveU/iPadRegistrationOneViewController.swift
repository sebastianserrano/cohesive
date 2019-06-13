//
//  iPadRegistrationOneViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-08.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit
var photoHolder:UIImage?

class iPadRegistrationOneViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var Photo: UIImageView!
    @IBOutlet weak var selectPhoto: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        selectPhoto.layer.cornerRadius = 5
        //selectPhoto.clipsToBounds = true
        BackgroundiPad(self)
        if photoHolder != nil {
            Photo.image = photoHolder
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignIn(_ sender: AnyObject) {
        
        photoHolder = nil
        skillOneiPad = nil;skillTwoiPad = nil;skillThreeiPad = nil;EmailiPad = nil;UsernameiPad = nil;PasswordiPad = nil;PasswordResetiPad = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SelectPhoto(_ sender: AnyObject) {
        Camera(delegate_:self).presentPhotoLibrary(self, canEdit:true)
    }


    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = (info[UIImagePickerControllerOriginalImage] as! UIImage)
        self.Photo.image = image
        photoHolder = image
      
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}
