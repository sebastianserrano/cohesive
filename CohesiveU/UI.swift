//
//  UI.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-06.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import Foundation

func backButton (_ vc: UIViewController){
    
    let backButton = UIBarButtonItem(
        title: "",
        style: UIBarButtonItemStyle.plain,
        target: nil,
        action: nil
    )
    vc.navigationController!.navigationBar.topItem!.backBarButtonItem = backButton
    
}

func Background (_ view: UIViewController) {
    
    let background = CAGradientLayer().tourquoiseColor()
    background.frame = view.view.bounds
    view.view.layer.insertSublayer(background, at: 0)
    
}

func BackgroundiPad (_ view: UIViewController) {
    
    let background = CAGradientLayer().tourquoiseColor()
    background.frame = CGRect(x:0,y:0,width:1300,height:1300)
    view.view.layer.insertSublayer(background, at: 0)
    
}

func BackgroundResetPassword (_ view: UIViewController) {

    view.view.layer.backgroundColor = UIColor(red: 140/255.0, green: 68/255.0, blue: 85/255.0, alpha: 1.0).cgColor
}

extension CAGradientLayer {
    
    func tourquoiseColor() -> CAGradientLayer {
        
        let topColor = UIColor(red: 100/255, green: 145/255, blue: 183/255, alpha: 1.0)
        let bottomColor = UIColor(red: 111/255, green: 111/255, blue: 119/255, alpha: 1.0)
        
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        
        return gradientLayer
        
    }
    
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

/*func setUpBackground (_ view:UIViewController) {
    
    switch UIDevice().modelName {
        
        case "iPodTouch":
            Background(view, width: 0, height: 0)
            break;
        case "iPhone4":
            Background(view, width: 0, height: 0)
            break;
        case "iPhone5":
            Background(view, width: 0, height: 0)
            break;
        case "iPhone6":
            Background(view, width: 0, height: 0)
            break;
        case "iPhone6s":
            Background(view, width: 0, height: 0)
            break;
        case "iPhone6Plus":
            Background(view, width: 0, height: 0)
            break;
        case "iPad2":
            Background(view, width: 0, height: 0)
            break;
        case "iPad3":
            Background(view, width: 0, height: 0)
            break;
        case "iPad4":
            Background(view, width: 0, height: 0)
            break;
        case "iPadAir":
            Background(view, width: 0, height: 0)
            break;
        case "iPadPro":
            Background(view, width: 0, height: 0)
            break;
        default:
            break;
        
    }
    
}*/
