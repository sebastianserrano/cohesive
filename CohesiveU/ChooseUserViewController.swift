//
//  ChooseUserViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-12.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import AlamofireImage
import SwiftyJSON

class ChooseUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    fileprivate var fromInstructions = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton(self)
        defaultTopButton()
        fromRecent = false
    
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toProfile" {
            if let button = sender as? UIButton {
                
                let indexPath = button.tag
                guard let users = matches else {return}
                withUser = users[indexPath]
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ProgressHUD.dismiss()
    }
    
    
    //MARK: UITableviewDataSorce
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let users = matches else {return 0}
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellTwo", for: indexPath) as! TableViewCellTwo
        
        guard let users = matches else {return cell}
        
        let user = users[(indexPath).row]
        cell.Indicator.startAnimating()
        
        guard let username = user["username"].string else {return cell}
        
        if let downloadURL = user["photoPathURL"].string {
            let downloadLink = URL(string: downloadURL)
            cell.ProfilePhoto.af_setImage(withURL: downloadLink!)
        } else {
            cell.ProfilePhoto.image = UIImage(named: "Person")
        }
        
        cell.UserName.text = username
        returnString(user) { (callback:String) in
            cell.Offers.text = callback
        }
        cell.userTap.tag = (indexPath as NSIndexPath).row
        
        return cell
    }
    
    //MARK: UITableviewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let users = matches else {return}
        let user = users[(indexPath as NSIndexPath).row]
        let chatVC = ChatViewController()
        withUser = user
        chatRoomId = startChat((FIRAuth.auth()?.currentUser?.uid)!,user2: user)
        navigationController?.pushViewController(chatVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func createView(_ text:String,zPosition:CGFloat,tag:Int) {
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black
        backgroundView.frame = self.view.bounds
        backgroundView.tag = tag
        backgroundView.layer.zPosition = zPosition
        self.view.addSubview(backgroundView)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.text = text
        backgroundView.addSubview(label)
        
    }
    
    fileprivate func instructionsView () {
        
        let instructions = InstructionsView(frame: CGRect(origin: CGPoint(x: 0,y: 0), size: UIScreen.main.bounds.size))
        instructions.pictureHolder.image = UIImage(named: "InstructionsTap")
        instructions.layer.zPosition = 2
        instructions.exit.addTarget(self, action: #selector(removeInstructions), for: .touchUpInside)
        instructions.tag = 3
        self.view.addSubview(instructions)
        
    }
    
    fileprivate func removeSubviews(_ tags:[Int]) {
        
        let subviews = self.view.subviews
        
        for subview in subviews {
            for tag in tags {
                if subview.tag == tag {
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    @objc fileprivate func removeInstructions () {
        
        let subviews = self.view.subviews
        
        for subview in subviews {
            if subview.tag == 3 {
                subview.removeFromSuperview()
            }
        }

    }
    
    fileprivate func defaultTopButton () {
        let buttonInfo  = UIBarButtonItem(image: UIImage(named: "Info"), style: UIBarButtonItemStyle.plain,target: self, action: #selector(info))
        self.navigationItem.setRightBarButtonItems([buttonInfo], animated: true)
    }
    
    @objc fileprivate func info() {
        
        let controller = UIAlertController(title: "", message: "You can view a users full profile by tapping on their photo", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (alert : UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
        
    }
    
}
