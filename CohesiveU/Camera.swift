//
//  Camera.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-09.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import Foundation
import MobileCoreServices

class Camera {

    var delegate: UINavigationControllerDelegate & UIImagePickerControllerDelegate
    
    init(delegate_: UINavigationControllerDelegate & UIImagePickerControllerDelegate) {
        delegate = delegate_
    }

    func presentPhotoLibrary (_ target: UIViewController, canEdit: Bool) {
        
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) && !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
            return
        }
        
        let type = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            imagePicker.sourceType = .photoLibrary
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary){
            
                if(availableTypes as NSArray).contains(type) {
                    imagePicker.mediaTypes = [type]
                    if DEVICEMODEL == "iPhone" {
                        imagePicker.allowsEditing = true
                    } else if DEVICEMODEL == "iPad" {
                        imagePicker.allowsEditing = false
                    } else if DEVICEMODEL == "Simulator" {
                        imagePicker.allowsEditing = true
                    }
                }
            }
        } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            imagePicker.sourceType = .savedPhotosAlbum
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
                
                if(availableTypes as NSArray).contains(type) {
                    imagePicker.mediaTypes = [type]
                    if DEVICEMODEL == "iPhone" {
                        imagePicker.allowsEditing = true
                    } else if DEVICEMODEL == "iPad" {
                        imagePicker.allowsEditing = false
                    } else if DEVICEMODEL == "Simulator" {
                        imagePicker.allowsEditing = true
                    }
                }
            }
        }
        
        if DEVICEMODEL == "iPhone" {
            imagePicker.allowsEditing = true
        } else if DEVICEMODEL == "iPad" {
            imagePicker.allowsEditing = false
        } else if DEVICEMODEL == "Simulator" {
            imagePicker.allowsEditing = true
        }
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil)
    }
    
    func presentCamera (_ target: UIViewController, canEdit:Bool) {
    
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            return
        }
        
        let type1 = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                
                if (availableTypes as NSArray).contains(type1) {
                    
                    imagePicker.mediaTypes = [type1]
                    imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                }
            }
            
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.rear
            }
            else if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.front
            }
        } else {
            //show alert no camera
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil)
    }

}
