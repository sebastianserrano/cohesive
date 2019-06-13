//
//  AppDelegate.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-06.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import UserNotifications
import MMDrawerController
import Batch

let APP_ID = "7F4C6427-C93A-06AC-FF52-452A67020900"
let SECRET_KEY = "76EE310A-4767-C502-FF09-4651ECB9DD00"
let VERSION_NUM = "v1"
let FIREBASE = FIRDatabase.database().reference()
let STORAGE = FIRStorage.storage().reference(forURL: "gs://cohesive-79cd9.appspot.com")
let REACHABLE = Reachability()
let ref = FIREBASE.child("PushNotifications")
var DEVICEMODEL = ""
var firstConnection = false
var fromOtherAccount = false
var tokenCheck = true
var deviceID:String?
var pushEnabled = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,CLLocationManagerDelegate {
    
    let notificationDelegate = NotificationDelegate()
    var window: UIWindow?
    var locationManager: CLLocationManager?
    var coordinate: CLLocationCoordinate2D?
    var drawerContainer: MMDrawerController?
    var currentUserNotificationSettings: UIUserNotificationSettings?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 0/255.0, green: 169/255.0, blue: 157/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor.white
        pageController.currentPageIndicatorTintColor = UIColor.red
        pageController.backgroundColor = UIColor.lightGray

        FIRApp.configure()
        FIRAuth.auth()
        
        if (REACHABLE.connectedToNetwork()) {
                FIRDatabase.database().persistenceEnabled = true
                firstConnection = true
        } else {
                ProgressHUD.showError("In order to use the app, please connect to the Internet")
        }
        
        //Register for push notification
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = notificationDelegate
            center.requestAuthorization(options: [.sound,.alert,.badge]) { (success, error) in
                if (success) {
                    application.registerForRemoteNotifications()
                    pushEnabled = true
                }
            }
        }// iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        Batch.start(withAPIKey: "5845FC45C831E88CCB7C9CB0346655")
        
        if (FIRAuth.auth()?.currentUser) != nil {
        
            switch UIDevice().modelName {
            case "iPhone","Simulator":
                DEVICEMODEL = "iPhone"
                self.initialView("LoginViewController")
                self.buildUserInterface()
                break;
            case "iPad":
                DEVICEMODEL = "iPad"
                self.initialView("WelcomeiPadViewController")
                self.buildUserInterface()
                break;
            default:
                break;
                
            }
        
        } else {
            self.defaultView()
            BACKGROUNDQUEUE.async {
                deleteDefault("user_name")
            }
        }
        
        locationManagerStart()
        ref.keepSynced(true)
    
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        if getDefault("user_name") != nil {
            guard (REACHABLE.connectedToNetwork()) else {return}
            BACKGROUNDQUEUE.async {
                retrievePushCounter((FIRAuth.auth()?.currentUser?.uid)!, callBack: { (counter) in
                    application.applicationIconBadgeNumber = counter
                })
            }
        }
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        BACKGROUNDQUEUE.async {
            if REACHABLE.connectedToNetwork() {
                /*if (FIRAuth.auth()?.currentUser) == nil {
                    MAINQUEUE.async {
                        self.defaultView()
                    }
                }*/
                FIRAuth.auth()?.addStateDidChangeListener { auth, user in
                    if getDefault("user_name") != nil {
                        if user == nil {
                            self.defaultView()
                        }
                    }
                }
                if (application.isRegisteredForRemoteNotifications) {
                    print("NOTIFICATIONS ARE ENABLED")
                    if (FIRAuth.auth()?.currentUser) != nil {
                        let editor = BatchUser.editor()
                        editor.setIdentifier(FIRAuth.auth()?.currentUser!.uid)
                        editor.save()
                        print("JUST SAVED MY SHIT TO BATCH")
                        
                    }
                } else {
                    print("NOTIFICATIONS ARE DISABLED")
                }
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        FIREBASE.cancelDisconnectOperations()
        locationManagerStop()
    }
    
    func application(_ application: UIApplication,
                     didRegister notificationSettings: UIUserNotificationSettings) {
        
        pushEnabled = true
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("couldnt register for notifications : \(error.localizedDescription)", terminator: "")
    }

    
    //MARK:  LocationManager fuctions
    func locationManagerStart() {
        
        print("init locationManager")
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func locationManagerStop() {
        UTILITYQUEUE.async {
            self.locationManager!.stopUpdatingLocation()
        }
    }
    
    //MARK: CLLocationManager Delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
                break
            case .authorizedWhenInUse:
                manager.startUpdatingLocation()
                break
            case .authorizedAlways:
                manager.startUpdatingLocation()
                break
            case .restricted:
                // restricted by e.g. parental controls. User can't enable Location Services
                break
            case .denied:
                manager.stopUpdatingLocation()
                print("denied location")
                // user denied your app access to Location Services, but can grant access from Settings.app
                break
            }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinate = locations.last?.coordinate
    }
    
    func buildUserInterface()
    {
        
        switch DEVICEMODEL {
            
            case "Simulator","iPhone":
                let userName:String? = UserDefaults.standard.string(forKey: "user_name")
                let instructionsViewed: String? = UserDefaults.standard.string(forKey: "instructionsViewed")
                
                if(userName != nil) && (instructionsViewed != nil)
                    
                {
                    // Navigate to Protected Page
                    
                    let mainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    
                    let mainPage:MainViewController = mainStoryBoard.instantiateViewController(
                        withIdentifier: "MainViewController") as! MainViewController
                    
                    let leftSideMenu:LeftSideViewController = mainStoryBoard.instantiateViewController(
                        withIdentifier: "LeftSideViewController") as! LeftSideViewController
                    
                    let mainPageNav = UINavigationController(rootViewController: mainPage)
                    
                    let leftSideMenuNav = UINavigationController(rootViewController: leftSideMenu)
                    
                    drawerContainer = MMDrawerController(center: mainPageNav, leftDrawerViewController: leftSideMenuNav)
                    
                    drawerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.panningCenterView
                    drawerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.panningCenterView
                    
                    window?.rootViewController = drawerContainer
                    
                } else if (userName != nil) && (instructionsViewed == nil) {
                    
                    // Navigate to Protected Page
                    
                    let mainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    
                    let mainPage:InstructionsViewController = mainStoryBoard.instantiateViewController(
                        withIdentifier: "InstructionsViewController") as! InstructionsViewController
                    
                    let leftSideMenu:LeftSideViewController = mainStoryBoard.instantiateViewController(
                        withIdentifier: "LeftSideViewController") as! LeftSideViewController
                    
                    let mainPageNav = UINavigationController(rootViewController: mainPage)
                    
                    let leftSideMenuNav = UINavigationController(rootViewController: leftSideMenu)
                    
                    drawerContainer = MMDrawerController(center: mainPageNav, leftDrawerViewController: leftSideMenuNav)
                    
                    drawerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.panningCenterView
                    drawerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.panningCenterView
                    
                    window?.rootViewController = drawerContainer
                    
                }
                break;
            case "iPad":
                let userName:String? = UserDefaults.standard.string(forKey: "user_name")
                let instructionsViewed: String? = UserDefaults.standard.string(forKey: "instructionsViewed")

                if(userName != nil) && (instructionsViewed != nil)
                    
                {
                    // Navigate to Protected Page
                    
                    let mainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    
                    let mainPage:HomeiPadViewController = mainStoryBoard.instantiateViewController(
                        withIdentifier: "HomeiPadViewController") as! HomeiPadViewController
                    
                    let leftSideMenu:LeftMenuiPadViewController = mainStoryBoard.instantiateViewController(
                        withIdentifier: "LeftMenuiPadViewController") as! LeftMenuiPadViewController
                    
                    let mainPageNav = UINavigationController(rootViewController: mainPage)
                    
                    let leftSideMenuNav = UINavigationController(rootViewController: leftSideMenu)
                    
                    drawerContainer = MMDrawerController(center: mainPageNav, leftDrawerViewController: leftSideMenuNav)
                    
                    drawerContainer!.maximumLeftDrawerWidth = CGFloat(400.0)
                    drawerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.panningCenterView
                    drawerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.panningCenterView
                    
                    window?.rootViewController = drawerContainer
                    
                } else if (userName != nil) && (instructionsViewed == nil) {
                    
                    // Navigate to Protected Page
                    
                    let mainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    
                    let mainPage:InstructionsiPadViewController = mainStoryBoard.instantiateViewController(
                        withIdentifier: "InstructionsiPadViewController") as! InstructionsiPadViewController
                    
                    let leftSideMenu:LeftMenuiPadViewController = mainStoryBoard.instantiateViewController(
                        withIdentifier: "LeftMenuiPadViewController") as! LeftMenuiPadViewController
                    
                    let mainPageNav = UINavigationController(rootViewController: mainPage)
                    
                    let leftSideMenuNav = UINavigationController(rootViewController: leftSideMenu)
                    
                    drawerContainer = MMDrawerController(center: mainPageNav, leftDrawerViewController: leftSideMenuNav)
                    
                    drawerContainer!.maximumLeftDrawerWidth = CGFloat(400.0)
                    drawerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.panningCenterView
                    drawerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.panningCenterView
                    
                    window?.rootViewController = drawerContainer
                    
                }
                break;
            default:
                break;
        
        }

    }
    
    func initialView (_ ident:String) {
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: ident)
        let defaultNav = UINavigationController(rootViewController: initialViewController)
        self.window = UIWindow(frame:UIScreen.main.bounds)
        self.window?.rootViewController = defaultNav
        self.window?.makeKeyAndVisible()

    }
    
    func defaultView() {
    
        switch UIDevice().modelName {
        case "iPhone","Simulator":
            DEVICEMODEL = "iPhone"
            self.initialView("LoginViewController")
            break;
        case "iPad":
            DEVICEMODEL = "iPad"
            self.initialView("WelcomeiPadViewController")
            break;
        default:
            break;
            
        }
    
    }
    
}

@objc class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        BatchPush.handle(userNotificationCenter: center, didReceive: response)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        BatchPush.handle(userNotificationCenter: center, willPresent: notification, willShowSystemForegroundAlert: true)
        // Tell iOS that we want the notification to behave just like a backgrounded app
        completionHandler([.alert, .badge, .sound])
        
        // Since you set willShowSystemForegroundAlert to true, you should call completionHandler([.alert, .sound, .badge])
        // If set to false, you'd call completionHandler([])
    }
}

