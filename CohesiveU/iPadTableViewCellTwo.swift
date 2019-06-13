//
//  iPadTableViewCellTwo.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-17.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit

class iPadTableViewCellTwo: UITableViewCell {
    
    @IBOutlet weak var ProfilePhoto: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var LastMessage: UILabel!
    @IBOutlet weak var Counter: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Indicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        Indicator.layer.zPosition = 0
        ProfilePhoto.layer.zPosition = 1
        ProfilePhoto.layer.cornerRadius = 5
        ProfilePhoto.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindData(_ recent: NSDictionary) {
        
        let userName = (recent.value(forKey: "withUserUsername") as? String)!
        
        getUser(username: userName,callback: {(success,json) in
            
            if(success) {
                if let downloadURL = json["photoPathURL"].string {
                    let downloadLink = URL(string: downloadURL)
                    self.ProfilePhoto.af_setImage(withURL: downloadLink!)
                } else {
                    self.ProfilePhoto.image = UIImage(named: "Person")
                }
            }
            
        })
        
        MAINQUEUE.async{
            self.Name.text = recent["withUserUsername"] as? String
            self.LastMessage.text = recent["lastMessage"] as? String
            self.Counter.text = ""
        }
        
        if (recent["counter"] as? Int)! != 0 {
            MAINQUEUE.async {
                self.Counter.text = "\(recent["counter"]!)"
            }
        }
        
        let date = dateFormatter().date(from: (recent["date"] as? String)!)
        let seconds = Foundation.Date().timeIntervalSince(date!)
        self.TimeElapsed(seconds, callback: { (timeElapsed:String) in
            MAINQUEUE.async {
                self.Date.text = timeElapsed
            }
        })

    }
    
    func TimeElapsed(_ seconds: TimeInterval, callback:@escaping(_ time:String)->Void) {
        
        var elapsed: String?
        
        UTILITYQUEUE.async {
            if (seconds < 60) {
                elapsed = "Just now"
            } else if (seconds < 60 * 60) {
                let minutes = Int(seconds / 60)
                
                var minText = "min"
                if minutes > 1 {
                    minText = "mins"
                }
                elapsed = "\(minutes) \(minText)"
                
            } else if (seconds < 24 * 60 * 60) {
                let hours = Int(seconds / (60 * 60))
                var hourText = "hour"
                if hours > 1 {
                    hourText = "hours"
                }
                elapsed = "\(hours) \(hourText)"
            } else {
                let days = Int(seconds / (24 * 60 * 60))
                var dayText = "day"
                if days > 1 {
                    dayText = "days"
                }
                elapsed = "\(days) \(dayText)"
            }
            MAINQUEUE.async {
                callback(elapsed!)
            }
        }
    }

}
