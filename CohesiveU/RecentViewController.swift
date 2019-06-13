//
//  RecentViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-12.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON

var IndicatorSet = false

var chatRoomId:String!
var fromRecent = false

class RecentViewController: UITableViewController {

    fileprivate var recents: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard (REACHABLE.connectedToNetwork()) else {ProgressHUD.showError("Please connect to the network in order to view your matches");return}
        ProgressHUD.show("Loading...")
        loadRecents()
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        ProgressHUD.dismiss()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func MenuTap(_ sender: AnyObject) {
        toggleMenu()
    }
    
    //MARK: UITableviewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchesCell", for: indexPath) as! TableViewCellThree
        
        let recent = recents[(indexPath as NSIndexPath).row]
        cell.Indicator.startAnimating()
        cell.bindData(recent)
        
        return cell
    }
    
    //MARK: UITableviewDelegate functions
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let recentPassed = recents[(indexPath as NSIndexPath).row]
        withUser = JSON(recentPassed)
        chatRoomId = (recentPassed["chatRoomID"] as? String)
        
        //Subtract the number of unread messages
        guard let count = (recentPassed["counter"] as? Int) else {return}
        if count > 0 {
            FIREBASEQUEUE.async {
                ClearRecentCounter(chatRoomId!)
                retrievePushCounter((FIRAuth.auth()?.currentUser?.uid)! , callBack: { (counter) in
                    subtractCounter((FIRAuth.auth()?.currentUser?.uid)! ,currentCounter: counter,counter:count)
                })
            }
        }
        
        //create recent for user2 users
        FIREBASEQUEUE.async {
            RestartRecentChat(recentPassed)
        }
        fromRecent = true
        IndicatorSet = true
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "recentToChatSeg", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchesCell", for: indexPath) as! TableViewCellThree
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            cell.Counter.isHidden = true
            cell.Date.isHidden = true
            
            let recent = recents[(indexPath as NSIndexPath).row]
            
            //remove recent from the array
            recents.remove(at: (indexPath as NSIndexPath).row)
            
            //delete recent from firebase
            FIREBASEQUEUE.async {
                DeleteRecentItem(recent)
            }
            
            tableView.reloadData()
        }
        
    }
    
    //MARK: Load Recents from firebase
    
    fileprivate func loadRecents() {
        
        FIREBASEQUEUE.async {
            
            FIREBASE.child("Recent").queryOrdered(byChild: "userId").queryEqual(toValue: FIRAuth.auth()?.currentUser?.uid).observe(.value, with: {
                snapshot in
                
                self.recents.removeAll()
                if snapshot.exists() {
                    
                    let sorted = ((snapshot.value! as AnyObject).allValues as NSArray).sortedArray(using: [NSSortDescriptor(key: "date", ascending: false)])
                    
                    for recent in sorted {
                        
                        self.recents.append(recent as! NSDictionary)
                        if let recentDic = recent as? NSDictionary {
                            //add function to have offline access as well, this will download with user recent as well so that we will not create one again
                            FIREBASE.child("Recent").queryOrdered(byChild: "chatRoomID").queryEqual(toValue: recentDic["chatRoomID"]).observe(.value, with: {
                                snapshot in
                            })
                        }
                    }
                    
                } else {
                    MAINQUEUE.async {
                        alertController("Alert", message: "No matches", vc: self)
                    }
                }
                MAINQUEUE.async {
                    ProgressHUD.dismiss()
                    self.tableView.reloadData()
                }
            })
        }
    }
}
