
//
//  Downloads.swift
//  CohesiveU
//
//  Created by Administrator on 2016-11-04.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import Foundation
import FirebaseStorage

func uploadImage(_ image: UIImage, index:Character, ref:String, result: @escaping (_ imageLink: [Any]?) ->Void) {
    
    let imageData = UIImageJPEGRepresentation(image, 1.0)
    let dateString = dateFormatter().string(from: Date())
    let fileName = dateString + ".jpeg"
    let imageRef = STORAGE.child(ref).child("\(index)").child(fileName)
    
    _ = imageRef.put(imageData!, metadata: nil) { metadata, error in
        if (error != nil) {
            MAINQUEUE.async {
                ProgressHUD.showError("Sorry, the photo could not be uploaded. Please try again later \(error.debugDescription)")
            }
            return
        } else {
            result([fileName,metadata!.downloadURL()!])
        }
    }
    
}

func getImageFromURL(_ imageURL: String, index:Character, result: @escaping (_ image: UIImage?) ->Void) {
    
    let ref = STORAGE.child("ProfilePhotos").child("\(index)").child(imageURL)
    var docURL = getDocumentURL()
    docURL = docURL.appendingPathComponent(imageURL, isDirectory: false)
    let filePath = fileInDocumentsDirectory(fileName: imageURL)
    
    if fileExistsAtPath(path: imageURL) {
        let image = UIImage(contentsOfFile: filePath)
        result(image)
    } else {
        FIREBASEQUEUE.async {
            _ = ref.write(toFile: docURL, completion: { (url:URL?, error:Error?) in
                if error == nil {
                    MAINQUEUE.async {
                        let image = UIImage(contentsOfFile: filePath)
                        result(image)
                    }
                } else {
                    ProgressHUD.showError("Sorry, there was a problem downloading the image")
                }
            })
        }
    }
}

func uploadAudio (audioPath:String, result: @escaping (_ audioLink: String?) -> Void) {
    
    let dateString = dateFormatter().string(from: Date())
    let audio = NSData(contentsOfFile: audioPath)
    let audioFileName = dateString + ".m4a"
    
    ProgressHUD.show("Sending Audio...")
    
    // Create a reference to the file you want to upload
    let riversRef = STORAGE.child("Audio").child(audioFileName)
    
    _ = riversRef.put(audio as Data!, metadata: nil) { metadata, error in
        if (error != nil) {
            ProgressHUD.showError("Couldnt send audio...Please try again later")
        } else {
            result(audioFileName)
        }
    }

}

func downloadAudio (audioURL:String, result: @escaping (_ audioFileName:String)->Void) {

    let ref = STORAGE.child("Audio").child(audioURL)
    var docURL = getDocumentURL()
    docURL = docURL.appendingPathComponent(audioURL, isDirectory: false)
    //let audioFileName = audioURL.components(separatedBy: "/").last
    
    if fileExistsAtPath(path: audioURL) {
        print("YES THE FILE WAS ALREADY DOWNLOADED")
        result(audioURL)
    } else {
        FIREBASEQUEUE.async {
            _ = ref.write(toFile: docURL, completion: { (url:URL?, error:Error?) in
                if error == nil {
                    print("YES THE FILE WAS DOWNLOADED AND SAVED")
                    MAINQUEUE.async {
                        result(audioURL)
                    }
                } else {
                    ProgressHUD.showError("Sorry, there was a problem downloading the audio")
                }
            })
        }
    }
}

func deleteFile (_ path: String, index:Character, ref:String, result: @escaping (_ callback: Bool) ->Void) {

    let ref = STORAGE.child(ref).child("\(index)/\(path)")
    
    // Delete the file
    ref.delete { (error) -> Void in
        if (error != nil) {
            result(false)
        } else {
            result(true)
        }
    }
}

func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
    
    UTILITYQUEUE.async {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            completion(data, response, error)
        }).resume()
    }
    
}


func downloadImage(url: URL, callback:@escaping(_ callback:Data) -> Void ) {
    getDataFromUrl(url: url) { (data, response, error)  in
        UTILITYQUEUE.async {
            guard let data = data, error == nil else { return }
            callback(data)
        }
    }
}

func fileInDocumentsDirectory(fileName:String) -> String {

    let fileURL = getDocumentURL().appendingPathComponent(fileName)
    return fileURL.path

}

func getDocumentURL() -> URL {

    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    return documentURL!

}

func fileExistsAtPath(path: String) -> Bool {

    var doesExists = false
    
    let filePath = fileInDocumentsDirectory(fileName: path)
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: filePath) {
        doesExists = true
    }
    
    return doesExists

}


