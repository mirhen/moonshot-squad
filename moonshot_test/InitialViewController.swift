//
//  InitialViewController.swift
//  moonshot_test
//
//  Created by Miriam Hendler on 8/28/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
//            if let user = user {
//                // User is signed in.
//                
//                self.getUser(uid: user.uid, callback: { (currentUser) in
//                    
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    
//                    switch currentUser.userType {
//                    case .geek:
//                        
//                        let vc = storyboard.instantiateViewController(withIdentifier: "GeekHome") as! GeekViewController
//                        vc.newUser = currentUser
//                        self.present(vc, animated: true, completion: nil)
//                        
//                        
//                    case .teacher:
//                        let vc = storyboard.instantiateViewController(withIdentifier: "TeacherHome") as! TeacherViewController
//                        vc.newUser = currentUser
//                        self.present(vc, animated: true, completion: nil)
//                    }
//                })
//                
//                
//            } else {
//                // No user is signed in.
//                self.setInitialView(withIdentifier: "Launched")
//                
//        // Do any additional setup after loading the view.
//    }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
            func setInitialView(withIdentifier: String) {
                
                
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let initialViewController = storyboard.instantiateViewController(withIdentifier: withIdentifier) as UIViewController
                
                self.present(initialViewController, animated: true, completion: nil)
                
            }
            func getUser(uid: String, callback: @escaping (User)->()) {
                
                let currentUser: User = User(userType: .teacher, fullname: "")
                var ref: FIRDatabaseReference?
                ref = FIRDatabase.database().reference()
                
                var userType: user = .teacher
                
                ref!.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as? NSDictionary
                    
                    let type = value!["userType"] as! String
                    let fullname = value!["fullname"] as! String
                    let school = value!["school"] as! String
                    let classroom = value!["classroom"] as! String
                    let prof = value!["profile"] as? String ?? #imageLiteral(resourceName: "placeholder").encodeTo64()
                    let location = value!["location"] as? [String: Float] ?? ["longitude": -122.1566630, "latitude": 37.4366530]
                    let email = value!["email"] as! String
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
                    
                    callback(currentUser)
                    
                    // ...
                }) { (error) in
                    print(error.localizedDescription)
                }
                
                
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
