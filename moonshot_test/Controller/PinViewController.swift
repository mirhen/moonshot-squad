//
//  PinViewController.swift
//  moonshot_test
//
//  Created by Miriam Hendler on 9/2/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase
import FirebaseAuth
import FirebaseDatabase

class PinViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var viewOne: UIView!
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var viewThree: UIView!
    @IBOutlet weak var viewFour: UIView!
    
    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var labelTwo: UILabel!
    @IBOutlet weak var labelThree: UILabel!
    @IBOutlet weak var labelFour: UILabel!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var keyTextField: UITextField!
    
    var count = 0
    var newUser: User?
    var pins : [Int] = []
    var pin: Int?
    var pwd: String?
    var ref: FIRDatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if let user = newUser {
            
            pin = getPinCode(user: user) ?? 0
            
        }
        
        //Setup firbase database
        ref = FIRDatabase.database().reference()
        
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        keyTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setupUI() {
        keyTextField.delegate = self
        let views: [UIView] = [viewOne, viewTwo, viewThree, viewFour]
        
        for i in 0..<views.count {
            let view = views[i]
            view.layer.cornerRadius = 5
            view.layer.masksToBounds = false;
            view.layer.shadowOffset = CGSize(width: -1,height: 1);
        }
        
    }
    
    func getPinCode(user: User) -> Int? {
        
        let jsonData = Helper.dumpJson(file: "school")
        let json = jsonData.dictionary!
        let school = user.school
        let teachers = json[school]!.arrayValue
        
        for i in 0..<teachers.count {
            
            let name = teachers[i]["name"].string!
            let email = teachers[i]["email"].string!
            let teacherPin = teachers[i]["pin"].int!
            
            if user.fullname == name || user.email == email {
                return teacherPin
            }
            pins.append(teacherPin)
        }
        return nil
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if isBackSpace != -92 {
            
            if count == 0 {
                labelOne.text! = string
                print(textField.text! + string)
            }
            if count == 1 {
                labelTwo.text! = string
                print(textField.text! + string)
            }
            if count == 2 {
                labelThree.text! = string
                print(textField.text! + string)
            }
            if count == 3 {
                labelFour.text! = string
                print(textField.text! + string)
                
                let pinAttempt = textField.text! + string
                
                if pin == 0  {
                    for i in 0..<pins.count {
                        if pinAttempt == String(pins[i]) {
                            print("Pin is in Pinssss")
                            signUp(user: newUser!)
                        } else {
                            label.text = "Incorrect Pin Please Try Again"
                        }
                    }
                }
                else {
                    if pinAttempt == "\(pin!)" {
                        print("LOGIN SUCCESFUL")
                        signUp(user: newUser!)
                        
                    }
                    else{
                        label.text = "Incorrect Pin Please Try Again"
                    }
                }
                
            }
            if count < 4 {
            count += 1
            }
        }
        
        
        if (isBackSpace == -92) {
            count -= 1
            print("Backspace was pressed")
            if count == 0 {
                
                labelOne.text! = ""
                print(textField.text! + string)
                
            }
            if count == 1 {
                labelTwo.text! = ""
                print(textField.text! + string)
            }
            if count == 2 {
                labelThree.text! = ""
                print(textField.text! + string)

            }
            if count == 3 {
                labelFour.text! = ""
                print(textField.text! + string)
                label.text = "Enter 4 Digit Pin"
            }
            }
            
            let textstring = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let length = textstring.characters.count
            if length > 4 {
                return false
            }
            return true
        }
    
    func signUp(user: User) {
        FIRAuth.auth()?.createUser(withEmail: user.email, password: pwd!) { (fbUser, error) in
            
            if error == nil {
                print("You have successfully signed up")
                //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                
                self.ref!.child("users").child(fbUser!.uid).setValue( ["userType": "teacher",
                                                                       "fullname": user.fullname,
                                                                       "school": user.school,
                                                                       "classroom": user.classroom,
                                                                       "location": user.location ?? ["longitude": -122.1566630, "latitude": 37.4366530],
                                                                       "profile": "",
                                                                       "email": user.email] )
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TeacherHome") as! TeacherViewController
                vc.newUser = self.newUser!
                self.present(vc, animated: true, completion: nil)

            }
        }
    }
}
