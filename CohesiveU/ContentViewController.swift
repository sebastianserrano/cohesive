//
//  ContentViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-13.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

    
    @IBOutlet weak var Image: UIImageView!
    
    var pageIndex: Int!
    var imageFile: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.Image.image = UIImage(named: self.imageFile)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
