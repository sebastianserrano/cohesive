//
//  LeftMenuiPadViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-16.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit
import MMDrawerController
import Firebase

class LeftMenuiPadViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var ProfilePhoto: UIImageView!
    @IBOutlet weak var Username: UILabel!
    @IBOutlet weak var Menu: UITableView!
    @IBOutlet weak var Indicator: UIActivityIndicatorView!
    
    var menuItems:[String?] = ["Home","Matches","Settings","Instructions","About","Logout"]
    var IconPhotos:[String] = ["Home","Match-1","Settings","Instructions-1","About","Logout"]
    
    override func viewWillAppear(_ animated: Bool) {
        if let row = self.Menu.indexPathForSelectedRow {
            self.Menu.deselectRow(at: row, animated: false)
            self.Menu.cellForRow(at: row)?.backgroundColor = UIColor.black
        }
        Indicator.layer.zPosition = 0
        ProfilePhoto.layer.zPosition = 1
        ProfilePhoto.layer.cornerRadius = 5
        Indicator.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let row = self.Menu.indexPathForSelectedRow {
            self.Menu.cellForRow(at: row)?.backgroundColor = UIColor.black
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if pictureChange == true {
            loadUserDetails()
            pictureChange = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserDetails()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return menuItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "iPadTableViewCellThree", for: indexPath) as! iPadTableViewCellThree
        cell.Icon.image = UIImage(named: IconPhotos[(indexPath).row])
        cell.Label.text = menuItems[(indexPath).row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        switch((indexPath as NSIndexPath).row)
            
        {
            
        case 0:
            
            let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeiPadViewController") as! HomeiPadViewController
            
            let mainPageNav = UINavigationController(rootViewController: mainViewController)
            
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.drawerContainer!.centerViewController = mainPageNav
            
            appDelegate.drawerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)
            break
            
        case 1:
            
            let matchesViewController = self.storyboard?.instantiateViewController(withIdentifier: "RecentsiPadViewController") as! RecentsiPadViewController
            
            let matchesPageNav = UINavigationController(rootViewController: matchesViewController)
            
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.drawerContainer!.centerViewController = matchesPageNav
            
            appDelegate.drawerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)
            
            
            break
            
        case 2:
            
            let settingsViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingsiPadViewController") as! SettingsiPadViewController
            
            let settingsPageNav = UINavigationController(rootViewController: settingsViewController)
            
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.drawerContainer!.centerViewController = settingsPageNav
            
            appDelegate.drawerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)
            
            break
            
        case 3:
            
            let instructionsViewController = self.storyboard?.instantiateViewController(withIdentifier: "InstructionsiPadViewController") as! InstructionsiPadViewController
            
            let instructionsPageNav = UINavigationController(rootViewController: instructionsViewController)
            
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.drawerContainer!.centerViewController = instructionsPageNav
            
            appDelegate.drawerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)
            
            
            break
            
        case 4:
            
            let aboutViewController = self.storyboard?.instantiateViewController(withIdentifier: "AboutiPadViewController") as! AboutiPadViewController
            
            let aboutPageNav = UINavigationController(rootViewController: aboutViewController)
            
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.drawerContainer!.centerViewController = aboutPageNav
            
            appDelegate.drawerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)
            
            break
            
        case 5:
            
            ProgressHUD.show("Logging out...")
            
            logOut()
            
            ProgressHUD.dismiss()
            
            // Navigate to protected page
            
            let welcomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeiPadViewController") as! WelcomeiPadViewController
            
            let welcomePageNav = UINavigationController(rootViewController: welcomeViewController)
            
            self.present(welcomePageNav, animated: true, completion: nil)
            
            break
            
        default:
            print("option is not handled", terminator: "")
            
        }
        
        
    }
    
    func loadUserDetails()
        
    {
        if let currentUser = FIRAuth.auth()?.currentUser {
            
            guard let displayName = currentUser.displayName else {return}
            let index = displayName.substringStart()
            Username.text = displayName
            
            getUser(username: displayName,callback: { (success,json) in
                if(success) {
                    print(json)
                    if let path = json["photoPath"].string {
                        getImageFromURL(path, index: index, result: { (image) in
                            if image != nil {
                                ProgressHUD.dismiss()
                                self.ProfilePhoto.image = image!
                            }
                        })
                    } else {
                        ProgressHUD.dismiss()
                        self.ProfilePhoto.image = UIImage(named: "Person")
                    }
                } else {
                    ProgressHUD.showError("Sorry, there was a problem setting up your profile picture")
                }
            })
        }
        
    }
    
    func logOut() {
        
        do {
            try signOut()
            deleteDefault("user_name")
            tokenCheck = false
        } catch {
            ProgressHUD.showError("Sorry, couldnt log you out...Please try again")
        }
        
    }

}
