//
//  ChatViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-06.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit
import AVKit
import JSQMessagesViewController
import IDMPhotoBrowser
import Firebase

class ChatiPadViewController: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, IQAudioRecorderViewControllerDelegate {
    
    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    fileprivate let ref = FIREBASE.child("Message")
    
    fileprivate var messages: [JSQMessage] = []
    fileprivate var objects: [NSDictionary] = []
    fileprivate var loaded: [NSDictionary] = []
    fileprivate var delete = [Int]()
    fileprivate var deleteExists = false
    
    fileprivate var firstLoad: Bool?
    fileprivate var connected = false
    fileprivate var blockedByUser = false
    fileprivate var startedSelection = false
    fileprivate var deletedMessage = false
    fileprivate var deletedArray:[String]?
    fileprivate var withUserID:String?
    fileprivate var withUserName:String?
    
    fileprivate var Indicator = UIActivityIndicatorView()
    
    fileprivate let tapPress = UITapGestureRecognizer()
    
    fileprivate var initialLoadComplete = false
    
    fileprivate let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor(red: 0/255.0, green: 113/255.0, blue: 188/255.0, alpha: 1.0))
    fileprivate let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    override func viewWillDisappear(_ animated: Bool) {
        
        ProgressHUD.dismiss()
        defaultTopBar()
        FIREBASEQUEUE.async {
            //Subtract the number of unread messages
            CurrentRecentCounter(chatRoomId) { (recentCounter) in
                if recentCounter > 0 {
                    ClearRecentCounter(chatRoomId)
                    retrievePushCounter((FIRAuth.auth()?.currentUser?.uid)!, callBack: { (counter) in
                        subtractCounter((FIRAuth.auth()?.currentUser?.uid)!,currentCounter: counter,counter:recentCounter)
                    })
                }
            }
            self.ref.removeAllObservers()
            if (self.deletedMessage) {
                guard (self.messages.last != nil) else {return}
                if (self.messages.last?.isMediaMessage)! {
                    UpdateRecentDeletedMessage(chatRoomId, lastMessage: "Media")
                } else {
                    UpdateRecentDeletedMessage(chatRoomId, lastMessage: (self.messages.last?.text)!)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (fromRecent) {
            defaultTopButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton(self)
        
        tapPress.addTarget(self, action: #selector(tappress))
        tapPress.numberOfTapsRequired = 2
        tapPress.delegate = self
        self.collectionView.addGestureRecognizer(tapPress)
        
        withUserID = withUser["firId"].string ?? withUser["withUserUserId"].string
        withUserName = withUser["username"].string ?? withUser["withUserUsername"].string
        
        self.senderId = FIRAuth.auth()?.currentUser?.uid
        self.senderDisplayName = (FIRAuth.auth()?.currentUser?.displayName!)!
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        if (REACHABLE.connectedToNetwork()) {
            connected = true
            QueryBlockedFieldOther(chatRoomId, callBack: {(blocked) in
                if (blocked) {
                    self.blockedByUser = true
                }
            })
            self.title = withUserName
            
        } else {
            ProgressHUD.showError("You appear to be disconnected, please go back to your matches and reconnect to the network in order to view messages")
            connected = false
        }
        
        if (checkForDefault("\(chatRoomId)")) {
            deletedArray = getDefaultArray("\(chatRoomId)")
            self.deleteExists = true
            self.loadmessages()
        } else {
            self.loadmessages()
        }
        self.inputToolbar?.contentView?.textView?.placeHolder = "New Message"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: JSQMessages dataSource functions
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[(indexPath as NSIndexPath).row]
        let flaggedMessage = objects[(indexPath as NSIndexPath).row]
        
        if let flagged = flaggedMessage["flagged"] as? NSNumber {
            if flagged == 1 {
                cell.backgroundColor = UIColor(red: 140/255.0, green: 68/255.0, blue: 85/255.0, alpha: 1.0)
            }
        }
        
        if data.senderId == FIRAuth.auth()?.currentUser?.uid {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        let data = messages[indexPath.row]
        
        return data
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        if data.senderId == FIRAuth.auth()?.currentUser?.uid {
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        if indexPath.item % 3 == 0 {
            
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = objects[indexPath.row]
        
        let status = message["status"] as! String
        
        if indexPath.row == (messages.count - 1) {
            return NSAttributedString(string: status)
        } else {
            return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let object = objects[indexPath.row]
        
        if object["type"] as! String == "picture" {
            
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQPhotoMediaItem
            
            let photos = IDMPhoto.photos(withImages: [mediaItem.image])
            let browser = IDMPhotoBrowser(photos: photos)
            
            self.present(browser!, animated: true, completion: nil)
        }
        
        if object["type"] as! String == "location" {
            
            guard (fromRecent) else {
                ProgressHUD.showError("In order to view map locations, please go to your matches from the side menu options")
                return}
            self.performSegue(withIdentifier: "chatToMapSeg", sender: indexPath)
        }
        
        if object["type"] as! String == "audio" {
            
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! AudioMessage
            
            let player = AVPlayer(url: mediaItem.fileURL! as URL)
            let moviePlayer = AVPlayerViewController()
            
            moviePlayer.player = player
            
            self.present(moviePlayer, animated:true, completion:{moviePlayer.player!.play()})
            
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        super.collectionView(collectionView, shouldShowMenuForItemAt: indexPath)
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: AnyObject?) -> Bool {
        super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
        return false
    }
    
    //MARK: JSQMessages Delegate function
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        guard connected else {
            if (REACHABLE.connectedToNetwork()) {
                ProgressHUD.showError("Please go back to your matches table and select a user in order to send messages again")
            } else {
                ProgressHUD.showError("You appear to be offline, please re-connect in order to send messages")
            }
            return}
        if text != "" {
            self.sendMessage(text, date: date, picture: nil, audioPath:nil, location: nil)
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let camera = Camera(delegate_: self)
        let audioVC = Audio(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert: UIAlertAction) -> Void in
            camera.presentCamera(self, canEdit: true)
            IndicatorSet = false
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert: UIAlertAction) -> Void in
            camera.presentPhotoLibrary(self, canEdit: true)
            IndicatorSet = false
        }
        
        let audio = UIAlertAction(title: "Share Audio", style: .default) {(alert: UIAlertAction) -> Void in
            
            audioVC.presentAudioRecorder(target: self)
            
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (alert: UIAlertAction) -> Void in
            
            if self.haveAccessToLocation() {
                self.sendMessage(nil, date: Date(), picture: nil, audioPath:nil, location: "location")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert : UIAlertAction) -> Void in
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(audio)
        optionMenu.addAction(cancelAction)
        
        guard connected else {
            if (REACHABLE.connectedToNetwork()) {
                ProgressHUD.showError("Please go back to your matches table and select a user in order to send messages again")
            } else {
                ProgressHUD.showError("You appear to be offline, please re-connect in order to send messages")
            }
            return}
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    //MARK: Send Message
    
    fileprivate func sendMessage(_ text: String?, date: Date, picture: UIImage?, audioPath:String?, location: String?) {
        
        var outgoingMessage:OutgoingMessage?
        
        //if text message
        if let text = text {
            outgoingMessage = OutgoingMessage(message: text, senderId: (FIRAuth.auth()?.currentUser?.uid)!, senderName: (FIRAuth.auth()?.currentUser?.displayName!)!, date: date, status: "Delivered", type: "text")
        }
        
        //send picture message
        if let pic = picture {
            
            let imageData = UIImageJPEGRepresentation(pic, 1.0)
            
            outgoingMessage = OutgoingMessage(message: "Picture", pictureData: imageData!, senderId: (FIRAuth.auth()?.currentUser?.uid)!, senderName: (FIRAuth.auth()?.currentUser?.displayName!)!, date: date, status: "Delivered", type: "picture")
        }
        
        if let audio = audioPath {
            
            outgoingMessage = OutgoingMessage(message:"Audio",audio:audio, senderId: (FIRAuth.auth()?.currentUser?.uid)!, senderName:(FIRAuth.auth()?.currentUser?.displayName!)!,date:date,status:"Delivered",type:"audio")
        }
        
        if location != nil {
            
            let lat: NSNumber = NSNumber(value: (appDelegate.coordinate?.latitude)! as Double)
            let lng: NSNumber = NSNumber(value: (appDelegate.coordinate?.longitude)! as Double)
            
            outgoingMessage = OutgoingMessage(message: "Location", latitude: lat, longitude: lng, senderId: (FIRAuth.auth()?.currentUser?.uid)!, senderName: (FIRAuth.auth()?.currentUser?.displayName!)!, date: date, status: "Delivered", type: "location")
        }
        
        if !(getDefaultBool(chatRoomId)) {
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            self.finishSendingMessage()
            outgoingMessage!.sendMessage(chatRoomId, item: outgoingMessage!.messageDictionary, withUser: withUser)
            saveDefaults(true as AnyObject, forKey: chatRoomId)
            return
        } else {
            QueryBlockedFieldOther(chatRoomId, callBack: {(blocked) in
                if (blocked) {
                    ProgressHUD.showError("You have been blocked by this user")
                } else {
                    //play message sent sound
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    outgoingMessage!.sendMessage(chatRoomId, item: outgoingMessage!.messageDictionary, withUser: withUser)
                    return
                }
            })
        }
        
    }
    
    
    //MARK: Load Messages
    
    fileprivate func loadmessages() {
        
        ProgressHUD.dismiss()
        
        ref.child(chatRoomId).observe(.childAdded, with: {
            snapshot in
            
            if snapshot.exists() {
                let item = (snapshot.value as? NSDictionary)!
                
                if self.initialLoadComplete {
                    let incoming = self.insertMessage(item)
                    
                    if incoming {
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    }
                    
                    self.finishReceivingMessage(animated: false)
                    
                } else {
                    self.loaded.append(item)
                }
            }
        })
        
        
        ref.child(chatRoomId).observe(.childChanged, with: {
            snapshot in
            
            //updated message
        })
        
        
        ref.child(chatRoomId).observe(.childRemoved, with: {
            snapshot in
            
            //Deleted message
        })
        
        ref.child(chatRoomId).observeSingleEvent(of: .value, with:{
            snapshot in
            
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            self.initialLoadComplete = true
            
        })
        
    }
    
    fileprivate func insertMessages() {
        
        for item in loaded {
            //create message
            _ = insertMessage(item)
        }
    }
    
    fileprivate func insertMessage(_ item: NSDictionary) -> Bool {
        
        var incomingDummy = Bool()
        
        if (deleteExists) {
            if !(self.deletedArray!.contains(item["messageId"] as! String)) {
                let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
                let message = incomingMessage.createMessage(item)
                
                objects.append(item)
                messages.append(message!)
                
                incomingDummy = incoming(item)
            }
        } else {
            
            let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
            let message = incomingMessage.createMessage(item)
            
            objects.append(item)
            messages.append(message!)
            
            incomingDummy = incoming(item)
            
        }
        
        return incomingDummy
    }
    
    fileprivate func incoming(_ item: NSDictionary) -> Bool {
        
        if FIRAuth.auth()?.currentUser?.uid == item["senderId"] as? String {
            return false
        } else {
            return true
        }
    }
    
    fileprivate func outgoing(_ item: NSDictionary) -> Bool {
        
        if FIRAuth.auth()?.currentUser?.uid == item["senderId"] as? String {
            return true
        } else {
            return false
        }
        
    }
    
    
    //MARK: Helper functions
    
    fileprivate func haveAccessToLocation() -> Bool {
        if let _ = appDelegate.locationManager?.location {
            return true
        } else {
            openSettings()
            return false
        }
    }
    
    //MARK: UIIMagePickerController functions
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let picture = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.sendMessage(nil, date: Date(), picture: picture, audioPath:nil, location: nil)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "chatToMapSeg" {
            
            let indexPath = sender as! IndexPath
            let message = messages[(indexPath as NSIndexPath).row]
            
            let mediaItem = message.media as! JSQLocationMediaItem
            
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            let navController = UINavigationController(rootViewController: VC)
            VC.location = mediaItem.location
            self.present(navController, animated: true, completion: nil)
            
            
        }
        
    }
    
    @objc fileprivate func tap (_ sender: UIButton){
        performSegue(withIdentifier: "toMatchedUser", sender: self)
    }
    
    @objc fileprivate func Block (_ sender:UIButton){
        print("just tapped blocked")
    }
    
    fileprivate func instructionsView () {
        
        let instructions = InstructionsView(frame: CGRect(origin: CGPoint(x: 0,y: 0), size: UIScreen.main.bounds.size))
        instructions.pictureHolder.image = UIImage(named: "InstructionsTapTwo")
        instructions.layer.zPosition = 2
        instructions.exit.addTarget(self, action: #selector(removeInstructionsTwo), for: .touchUpInside)
        instructions.tag = 2
        self.view.addSubview(instructions)
        
    }
    
    fileprivate func instructionsViewThree () {
        
        let instructions = InstructionsView(frame: CGRect(origin: CGPoint(x: 0,y: 0), size: UIScreen.main.bounds.size))
        instructions.pictureHolder.image = UIImage(named: "InstructionsTapThree")
        instructions.layer.zPosition = 3
        instructions.exit.addTarget(self, action: #selector(removeInstructionsThree), for: .touchUpInside)
        instructions.tag = 3
        self.view.addSubview(instructions)
        
    }
    
    @objc fileprivate func removeInstructionsTwo () {
        instructionsViewThree()
    }
    
    @objc fileprivate func removeInstructionsThree () {
        
        let subviews = self.view.subviews
        let tags = [2,3]
        
        for subview in subviews {
            for tag in tags {
                if subview.tag == tag {
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    fileprivate func openSettings () {
        
        let alertController = UIAlertController(title: "Background Location Access Disabled", message: "In order to share your location, please open this app's settings and enable the location status", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        
        let settings = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                OperationQueue.main.addOperation({if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                    }})
            }
        }
        alertController.addAction(settings)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc fileprivate func tappress(_ gesture: UITapGestureRecognizer) {
        
        if !(startedSelection) {
            defaultDeleteNav()
        }
        
        let path = gesture.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: path)
        
        if let index = indexPath {
            let cell = collectionView.cellForItem(at: index)
            if delete.contains((index as NSIndexPath).row) {
                let cellMessage = objects[(index as NSIndexPath).row]
                if cellMessage["flagged"] as! NSNumber != 1 {
                    cell!.layer.backgroundColor = UIColor.clear.cgColor
                } else {
                    cell!.layer.backgroundColor = UIColor(red: 140/255.0, green: 68/255.0, blue: 85/255.0, alpha: 1.0).cgColor
                }
                removeFromDelete((index as NSIndexPath).row)
            } else {
                startedSelection = true
                cell!.layer.backgroundColor = UIColor(red: 225/255.0, green: 212/255.0, blue: 212/255.0, alpha: 1.0).cgColor
                addToDelete((index as NSIndexPath).row)
            }
        }
        
    }
    
    @objc fileprivate func Flag () {
        
        if delete.count != 0 {
            let controller  = UIAlertController(title: "Flag", message: "The selected message(s) will be flagged due of objectionable content. Are you sure you want to flag the selected message(s)?", preferredStyle: UIAlertControllerStyle.alert)
            let send = UIAlertAction(title: "Flag", style: UIAlertActionStyle.default, handler: ({(action:UIAlertAction) in
                self.flagMessages() }))
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: ({(action:UIAlertAction)
                in }))
            controller.addAction(cancel)
            controller.addAction(send)
            
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    @objc fileprivate func deleteMessage() {
        
        if delete.count != 0 {
            
            let controller  = UIAlertController(title: "Delete", message: "Are you sure you want to delete the selected message(s)?", preferredStyle: UIAlertControllerStyle.alert)
            let send = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: ({(action:UIAlertAction) in
                self.deleteMessages() }))
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: ({(action:UIAlertAction)
                in }))
            controller.addAction(cancel)
            controller.addAction(send)
            
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    fileprivate func removeFromDelete(_ num:Int) {
        if delete.contains(num) {
            let index = delete.index(of: num)
            delete.remove(at: index!)
            if delete.count == 0 {
                startedSelection = false
                defaultNav()
            }
        }
    }
    
    fileprivate func addToDelete (_ num:Int) {
        if !delete.contains(num) {
            delete.append(num)
        }
    }
    
    fileprivate func deleteMessages () {
        
        var deletedMessagesIds = [String]()
        
        UTILITYQUEUE.async {
            for value in self.delete {
                guard self.objects.count > value else {return}
                let message = self.objects[value]
                if let messageId = message["messageId"] as? String {
                    if !(deletedMessagesIds.contains(messageId)) {
                        deletedMessagesIds.append(messageId)
                    }
                }
                
                
                self.messages.remove(at: value)
                self.objects.remove(at: value)
                
                BACKGROUNDQUEUE.async {
                    if (self.deleteExists) {
                        for value in deletedMessagesIds {
                            self.deletedArray!.append(value)
                        }
                        saveDefaults(self.deletedArray! as AnyObject, forKey: "\(chatRoomId)")
                    } else {
                        saveDefaults(deletedMessagesIds as AnyObject, forKey: "\(chatRoomId)")
                    }
                }
                
                self.deletedMessage = true
                self.startedSelection = false
                self.delete.removeAll()
                
                MAINQUEUE.async {
                    ProgressHUD.showSuccess("Deleted messages succesfully")
                    self.defaultNav()
                    self.collectionView?.reloadData()
                }
                
            }
            
        }
        
    }
    
    fileprivate func flagMessages () {
        
        UTILITYQUEUE.async {
            for value in self.delete {
                guard self.objects.count > value else {return}
                let message = self.objects[value]
                message.setValue(1, forKeyPath: "flagged")
                UpdateFlaggedMessage(chatRoomId, messageID: message["messageId"] as! String)
                
                self.startedSelection = false
                self.delete.removeAll()
                
                MAINQUEUE.async {
                    ProgressHUD.showSuccess("Flagged messages succesfully")
                    self.defaultNav()
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    @objc fileprivate func info() {
    
        let controller = UIAlertController(title: "", message: "In order to select a message, double tap beside it", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (alert : UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
        
    }
    
    fileprivate func defaultTopBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255.0, green: 169/255.0, blue: 157/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColorDidChange()
    }
    
    fileprivate func defaultTopButton () {
        let buttonUser  = UIBarButtonItem(image: UIImage(named: "User"), style: UIBarButtonItemStyle.plain,target: self, action: #selector(tap))
        let buttonInfo  = UIBarButtonItem(image: UIImage(named: "Info"), style: UIBarButtonItemStyle.plain,target: self, action: #selector(info))
        self.navigationItem.setRightBarButtonItems([buttonUser,buttonInfo], animated: true)
    }
    
    fileprivate func defaultNav () {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255.0, green: 169/255.0, blue: 157/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColorDidChange()
        let buttonUser  = UIBarButtonItem(image: UIImage(named: "User"), style: UIBarButtonItemStyle.plain,target: self, action: #selector(tap))
        self.navigationItem.setRightBarButtonItems([buttonUser], animated: true)
    }
    
    fileprivate func defaultDeleteNav () {
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 168/255.0, green: 12/255.0, blue: 12/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColorDidChange()
        let buttonUser  = UIBarButtonItem(image: UIImage(named: "DeleteBin"), style: UIBarButtonItemStyle.plain,target: self, action: #selector(deleteMessage))
        let buttonFlag  = UIBarButtonItem(image: UIImage(named: "Flag"), style: UIBarButtonItemStyle.plain,target: self, action: #selector(Flag))
        self.navigationItem.setRightBarButtonItems([buttonUser,buttonFlag], animated: true)
        
    }
    
    //MARK: AudioRecorder
    
    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        controller.dismiss(animated: true, completion: nil)
        uploadAudio(audioPath: filePath, result: { (audioLink) in
            self.sendMessage(nil, date: Date(), picture: nil, audioPath: audioLink!, location: nil)
        })
        
    }
    
}
