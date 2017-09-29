//
//  AppDelegate.swift
//  moonshot_test
//
//  Created by Miriam Hendler on 8/26/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import FirebaseInstanceID
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.sharedManager().enable = true
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            FIRMessaging.messaging().remoteMessageDelegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

        
        FIRApp.configure()
        
        
            let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
            let subscribed = UserDefaults.standard.bool(forKey: "subscribed")
        
            if launchedBefore  {
                print("Not first launch.")
                
                FIRAuth.auth()?.addStateDidChangeListener { auth, user in
                    if let user = user {
                        // User is signed in.
                        
                        self.getUser(uid: user.uid, callback: { (currentUser) in
                            
                            if subscribed {
                                print("User has subscribed to a topic")
                            } else {
                                let school_topic = currentUser.school.lowercased().replacingOccurrences(of: " ", with: "_")
                                FIRMessaging.messaging().subscribe(toTopic: "/topics/\(school_topic)")
                                UserDefaults.standard.set(true, forKey: "subscribed")
                            }
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            
                            switch currentUser.userType {
                            case .geek:
                                self.window = UIWindow(frame: UIScreen.main.bounds)
                                let vc = storyboard.instantiateViewController(withIdentifier: "GeekHome") as! GeekViewController
                                vc.newUser = currentUser
                                self.window?.rootViewController = vc
                                self.window?.makeKeyAndVisible()
                                
                            case .teacher:
                                self.window = UIWindow(frame: UIScreen.main.bounds)
                                let vc = storyboard.instantiateViewController(withIdentifier: "TeacherHome") as! TeacherViewController
                                vc.newUser = currentUser
                                self.window?.rootViewController = vc
                                self.window?.makeKeyAndVisible()
                            }
                        })
                        
                        
                    } else {
                        // No user is signed in.
                       self.setInitialView(withIdentifier: "Launched")
                        
                    }
                
            }
        }
        else {
                print("First launch, setting UserDefault.")
                UserDefaults.standard.set(true, forKey: "launchedBefore")
                
                self.setInitialView(withIdentifier: "FirstLaunch")
                
            }
        return true
    }

    func setInitialView(withIdentifier: String) {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let initialViewController = storyboard.instantiateViewController(withIdentifier: withIdentifier) as UIViewController
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func getUser(uid: String, callback: @escaping (User)->()) {
        
        let currentUser: User = User(userType: .teacher, fullname: "")
        var ref: FIRDatabaseReference?
        ref = FIRDatabase.database().reference()
        
        var userType: user = .teacher
        
        ref!.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            print(uid)
            
            let type = value!["userType"] as? String ?? "geek"
            let fullname = value!["fullname"] as! String
            let school = value!["school"] as! String
            let classroom = value!["classroom"] as! String
            let prof = value!["profile"] as? String ?? #imageLiteral(resourceName: "placeholder").encodeTo64()
            let location = value!["location"] as? [String: Float] ?? ["longitude": -122.1566630, "latitude": 37.4366530]
            let email = value!["email"] as! String
            let power = value!["power"] as? String ?? ""
            if type == "geek"{
                userType = .geek
            } else {
                userType = .teacher
            }
            
            currentUser.fullname = fullname
            currentUser.userType = userType
            currentUser.classroom = classroom
            currentUser.school = school
            currentUser.profile = prof
            currentUser.location = location
            currentUser.email = email
            currentUser.power = power
            
            callback(currentUser)
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    

}

extension UIImage {
    func encodeTo64() -> String {
        
        let imageData = UIImagePNGRepresentation(self)!
        let strBase64 = imageData.base64EncodedString(options:  NSData.Base64EncodingOptions.init(rawValue: 0))
        
        return strBase64
    }
    
    func resizeImageWith(newSize: CGSize) -> UIImage {
        
        let horizontalRatio = newSize.width / size.width
        let verticalRatio = newSize.height / size.height
        
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
extension UIImageView {
    func maskToCircle() {
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
}
extension UIButton {
    
    func maskToCircle() {
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
    
}

