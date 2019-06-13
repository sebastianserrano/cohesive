//
//  iPadRegistrationViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-08.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit

class iPadRegistrationViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var index = 0
    var identifiers: NSArray = ["iPadRegistrationOneViewController", "iPadRegistrationTwoViewController","iPadRegistrationThreeViewController"]
    
    override func viewDidLoad() {
        
        self.dataSource = self
        self.delegate = self
    
        let startingViewController = self.viewControllerAtIndex(self.index)
        let viewControllers: NSArray = [startingViewController]
        self.setViewControllers(viewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewControllerAtIndex(_ index:Int) -> UIViewController! {
        
        //first view controller = firstViewControllers navigation controller
        if index == 0 {
            
            return self.storyboard!.instantiateViewController(withIdentifier: "iPadRegistrationOneViewController")
            
        }
        
        //second view controller = secondViewController's navigation controller
        if index == 1 {
            
            return self.storyboard!.instantiateViewController(withIdentifier: "iPadRegistrationTwoViewController")

        }
        if index == 2 {
            
            return self.storyboard!.instantiateViewController(withIdentifier: "iPadRegistrationThreeViewController")
            
        }
        
        return nil
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let identifier = viewController.restorationIdentifier!
        let index = self.identifiers.index(of:identifier)
        
        //if the index is 0, return nil since we dont want a view controller before the first one
        if index == 0 {
            
            return nil
        }
        
        //decrement the index to get the viewController before the current one
        self.index = index - 1
        return self.viewControllerAtIndex(self.index)
    
        
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let identifier = viewController.restorationIdentifier!
        let index = self.identifiers.index(of:identifier)
        
        //if the index is the end of the array, return nil since we dont want a view controller after the last one
        if index == identifiers.count - 1 {
            
            return nil
        }
        
        //increment the index to get the viewController after the current index
        self.index = index + 1
        return self.viewControllerAtIndex(self.index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
       return self.identifiers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }


}
