//
//  InstructionsiPadViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-16.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit

class InstructionsiPadViewController: UIViewController, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController!
    var pageImages: NSArray!
    
    override func viewWillAppear(_ animated: Bool) {
        
        tokenCheck = true

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if getDefault("instructionsViewed") != "true" {
            saveDefaults("true" as AnyObject, forKey: "instructionsViewed")
        }
        
        self.pageImages = NSArray(objects: "pageOne", "Match", "Exchange")
        
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageiPadViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        var startVC = self.viewControllerAtIndex(index: 0) as ContentViewController
        var viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewControllerAtIndex(index: Int) -> ContentViewController
    {
        if ((self.pageImages.count == 0) || (index >= self.pageImages.count)) {
            return ContentViewController()
        }
        
        let vc: ContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
        
        vc.imageFile = self.pageImages[index] as! String
        vc.pageIndex = index
        
        return vc
        
        
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        
        if (index == 0 || index == NSNotFound)
        {
            return nil
            
        }
        
        index -= 1
        return self.viewControllerAtIndex(index: index)
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound)
        {
            return nil
        }
        
        index += 1
        
        if (index == self.pageImages.count)
        {
            return nil
        }
        
        return self.viewControllerAtIndex(index: index)
        
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pageImages.count
        
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    @IBAction func Menu(_ sender: AnyObject) {
        toggleMenu()
    }
    
}
