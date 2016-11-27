//
//  AppDelegate.swift
//  icome
//
//  Created by Tuo Zhang on 2015-09-30.
//  Copyright © 2015 iCome. All rights reserved.
//

import UIKit
import CoreData
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        // Initialize Parse.
        Parse.enableLocalDatastore()
        Parse.setApplicationId("<App ID>",
            clientKey: "<Client Key>")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        /*Initialize RongCloud*/
        RCIM.shared().initWithAppKey("Rong Cloud App Key")
        messageConnect = false
        
        /*Set up Navigation bar*/
        UINavigationBar.appearance().barTintColor = UIColor(red: 248.0/255.0, green: 134.0/255.0, blue: 5.0/255.0, alpha:1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        UIApplication.shared.isStatusBarHidden = false
        self.window?.makeKeyAndVisible()
        
        /*Set up click font*/
        let tabBar = UITabBarItem.appearance()
        tabBar.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.darkGray], for: UIControlState())
        
        tabBar.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.darkGray], for: UIControlState.highlighted)
        
        /*Initalize the welcome page*/
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor.lightGray
        pageController.currentPageIndicatorTintColor = UIColor.black
        pageController.backgroundColor = UIColor.clear
    
        //得到当前应用的版本号
        let infoDictionary = Bundle.main.infoDictionary
        let currentAppVersion = infoDictionary!["CFBundleShortVersionString"] as! String
        
        //取出之前保存的版本号
        let userDefaults = UserDefaults.standard
        let appVersion = userDefaults.string(forKey: "appVersion")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //如果 appVersion 为 nil 说明是第一次启动；如果 appVersion 不等于 currentAppVersion 说明是更新了
        if appVersion == nil || appVersion != currentAppVersion {
            // 保存最新的版本号
            userDefaults.setValue(currentAppVersion, forKey: "appVersion")
            let start = storyboard.instantiateViewController(withIdentifier: "slide") as! SlideViewController
            self.window?.rootViewController = start
            
        }else{
            if(PFUser.current() != nil){
                print("start conecting")
                get_token()
                let rootController  = HomeTabViewController()
                if let window = self.window {
                    window.rootViewController = rootController
                }
            }
        }
        return true
    }
    
    /*Resgister remote push notification*/
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .trimmingCharacters( in: characterSet )
            .replacingOccurrences( of: " ", with: "" ) as String
        
        RCIMClient.shared().setDeviceToken(deviceTokenString)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.icome" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "icome", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    /*Request Token for RongCloud*/
    func get_token () {
        let username = (PFUser.current()?.username)! as String
        let nick_name = PFUser.current()!.object(forKey: "nick_name") as! String
        let userImageFile = PFUser.current()!.object(forKey: "featured_image")  as! PFFile
        
        let parameters = [
            "userId": "\(username)",
            "name": "\(nick_name)",
            "portraitUri": "\(userImageFile.url)"
        ]
        let Timestamp = String(format: "%.0f",Date().timeIntervalSince1970)
        let Nonce: String = String(arc4random())
        let appSec = "udeJt1XKi3"
        
        let manage = AFHTTPRequestOperationManager()
        var sha1 = appSec + Nonce + Timestamp
        sha1 = (sha1 as NSString).sha1()
        let url = "https://api.cn.ronghub.com/user/getToken.json"
        let request = NSMutableURLRequest()
        request.timeoutInterval = 6
        request.httpMethod = "POST"
        manage.requestSerializer.setValue("<app key>", forHTTPHeaderField: "App-Key")
        manage.requestSerializer.setValue(Nonce, forHTTPHeaderField: "Nonce")
        manage.requestSerializer.setValue(Timestamp, forHTTPHeaderField: "Timestamp")
        manage.requestSerializer.setValue(sha1, forHTTPHeaderField: "Signature")
        manage.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        manage.post(url, parameters: parameters, success: { (operation, data) -> Void in
            token = (data as AnyObject).object(forKey: "token") as! String
            /*Set up RongCloud connection*/
            RCIM.shared().connect(withToken: token, success: { (str:String!) -> Void in
                DispatchQueue.main.async(execute: {
                    messageConnect = true
                    SVProgressHUD.dismiss()
                });
            }, error: { (code:RCConnectErrorCode) -> Void in
                NSLog("无法连接！\(code)")
            }) { () -> Void in
                NSLog("无效token！")
            }
        }) { (operation, error) -> Void in
            NSLog(error.description)
            self.get_token()
        }
    }//get_token
}

