//
//  LoginViewController.swift
//  moonshot_test
//
//  Created by Miriam Hendler on 8/26/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import MapKit
import CoreLocation
import SwiftyJSON
import FirebaseMessaging

class LoginViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // UI Elements for selecting the User Type
    @IBOutlet weak var geekButton: UIButton!
    @IBOutlet weak var teacherButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var geekView: UIView!
    @IBOutlet weak var teacherView: UIView!
    @IBOutlet weak var powerButton: UIButton!
    @IBOutlet weak var classPowerImageView: UIImageView!
    
    // Textfield Containers
    @IBOutlet weak var classRoomView: UIView!
    @IBOutlet weak var schoolNameView: UIView!
    @IBOutlet weak var fullNameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    
    // Textfield Elements
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
//    @IBOutlet weak var schoolNameTextField: UITextField!
    @IBOutlet weak var schoolButton: UIButton!
    @IBOutlet weak var classroomTextField: UITextField!
    
    //Tableview Elements and Containers
    @IBOutlet weak var schoolContainerView: UIView!
    @IBOutlet weak var schoolTableView: UITableView!
    @IBOutlet weak var powerContainer: UIView!
    @IBOutlet weak var powerTableView: UITableView!
    
    @IBAction func unwindToLogin(segue:UIStoryboardSegue) { }
    
    
    // Custom variables
    var signin = false
    var userType: user = .teacher
    var userLocation: [String: Float] = [:]
    var newUser: User?
    var ref: FIRDatabaseReference?
    let locationManager = CLLocationManager()
    var schools: [String: [String: String]]?
    var json: [String: JSON]?
    var originalButtonHeight: CGFloat?
    var powers: [String] = ["algebra","tech","history","calculus", "design"]
    var chosenPower = ""
    
    @IBAction func closePowerButtonPressed(_ sender: Any) {
        
        dismissPowerContainer()
    }
    @IBAction func schoolButtonPressed(_ sender: Any) {
        schoolContainerView.isHidden = false
    }
    
    @IBAction func teacherButtonPressed(_ sender: Any) {
        userType = .teacher
        setSelectedUserTo(type: userType)
        userFormFor(type: userType, signIn: signin)
    }
    
    @IBAction func geekButtonPressed(_ sender: Any) {
        userType = .geek
        setSelectedUserTo(type: userType)
        userFormFor(type: userType, signIn: signin)
    }
    
    @IBAction func powerButtonPressed(_ sender: Any) {
        powerContainer.isHidden = false
    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        
        if signin {

            signin = false
            signInButton.setTitle("sign in", for: .normal)
            signUpButton.setTitle("sign up", for: .normal)
            
        } else {
            signin = true

            signUpButton.setTitle("sign in", for: .normal)
            signInButton.setTitle("sign up", for: .normal)
        }
        userFormFor(type: userType, signIn: signin)
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        if signin {
            signInUser()
        } else {
            signUp(userType: userType)
            
            //Initialize location manager
            getCurrentLocation()
        }
    }
    
    
    // View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting up delegates
        
        classroomTextField.delegate = self
        schoolTableView.delegate = self
        schoolTableView.dataSource = self
        powerTableView.delegate = self
        powerTableView.dataSource = self
        powerTableView.separatorStyle = .none
        
        //Setup firbase database
        ref = FIRDatabase.database().reference()
        
        //Initilize selected user
        setSelectedUserTo(type: userType)
        setUpUI()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)

//        ref!.database.reference().child("powers").observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let value = snapshot.value as? [String]
//            self.powers = value!
//            
//            
//            // ...
//        }) { (error) in
//            print(error.localizedDescription)
//        }
        
        originalButtonHeight = signUpButton.frame.origin.y
//        enableNotifications()
        
        // Do any additional setup after loading the view.
        
        let jsonData = Helper.dumpJson(file: "school")
        json = jsonData.dictionary!
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Keyboard Functions
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if signin {
                print("hey")
                //                if passwordTextField.text == "" && emailTextField.text == ""  {
                //                if (self.signUpButton.frame.origin.y + 96) == (self.view.frame.height) {
                print("ho")
                self.signUpButton.frame.origin.y -= keyboardSize.height - 20
                //                    self.emailView.frame.origin.y -= 50
                //                    self.passwordView.frame.origin.y -= 50
                //                }
                //                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if signin {
                print("bye")
                if (self.signUpButton.frame.origin.y + 96) != (self.view.frame.height) {
                    print("bo")
                    self.signUpButton.frame.origin.y += keyboardSize.height + 20
                    //                    self.emailView.frame.origin.y += 50
                    //                    self.passwordView.frame.origin.y += 50
                }
            }
        }
    }
    
    
    func enableNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func disableNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func dismissPowerContainer() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        setPower()
    }
    
    // MARK: - Firebase Functions
    
    func signUp(userType: user) {
        
        
        if formCompletedFor(userType: userType) != true {
            let alertController = UIAlertController(title: "Error", message: "Please fill in the missing fields", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            
            self.newUser = User(userType: userType, fullname: self.fullNameTextField.text!)
            self.newUser!.classroom = self.classroomTextField.text ?? "none"
            self.newUser!.school = self.schoolButton.titleLabel!.text ?? "none"
            self.newUser!.location = self.userLocation
            self.newUser!.email = self.emailTextField.text!
            self.newUser!.power = self.chosenPower
            
            switch userType {
            case .geek:
                FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                    
                    if error == nil {
                        print("You have successfully signed up")
                        //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                        
                        self.ref!.child("users").child(user!.uid).setValue(["userType": self.newUser!.userType.rawValue,
                                                                            "fullname": self.newUser!.fullname,
                                                                            "school": self.newUser!.school,
                                                                            "classroom": self.newUser!.classroom,
                                                                            "location": self.newUser!.location ?? ["longitude": -122.1566630, "latitude": 37.4366530],
                                                                            "profile": "",
                                                                            "email": self.emailTextField.text!,
                                                                            "power": self.newUser!.power])
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GeekHome") as! GeekViewController
                        vc.newUser = self.newUser!
                        
                        //Subscribe new user to that schools posts
                        let school_topic = self.newUser!.school.lowercased().replacingOccurrences(of: " ", with: "_")
                        FIRMessaging.messaging().subscribe(toTopic: "/topics/\(school_topic)")
                        UserDefaults.standard.set(true, forKey: "subscribed")
                        print(school_topic)
                        
                        self.present(vc, animated: true, completion: nil)
                        
                    } else {
                        
                        let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            case .teacher:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Pin") as! PinViewController
                vc.pwd = passwordTextField.text!
                vc.newUser = self.newUser!
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func signInUser() {
        signUpButton.setTitle("sign in", for: .normal)
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    
                    var currentUser: User?
                    
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    var userType: user = .teacher
                    
                    self.ref!.child("users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        // Get user value
                        let value = snapshot.value as? NSDictionary
                        
                        
                        let type = value!["userType"] as! String
                        let fullname = value!["fullname"] as! String
                        let school = value!["school"] as! String
                        let classroom = value!["classroom"] as! String
                        let prof = value!["profile"] as? String ?? #imageLiteral(resourceName: "placeholder").encodeTo64()
                        let location = value!["location"] as? [String: Float] ?? ["longitude": -122.1566630, "latitude": 37.4366530]
                        let email = value!["email"] as? String ?? "miriamthendler@gmail.com"
                        let power = value!["power"] as? String ?? ""
                        
                        if type == "geek"{
                            userType = .geek
                        } else {
                            userType = .teacher
                        }
                        
                        
                        currentUser = User(userType: userType, fullname: fullname)
                        currentUser!.classroom = classroom
                        currentUser!.school = school
                        currentUser!.profile = prof
                        currentUser!.location = location
                        currentUser!.email = email
                        currentUser!.power = power
                        
                        switch userType {
                        case .geek:
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GeekHome") as! GeekViewController
                            vc.newUser = currentUser!
                            self.present(vc, animated: true, completion: nil)
                        case .teacher: 
                                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TeacherHome") as! TeacherViewController
                                                        vc.newUser = currentUser!
                                                        self.present(vc, animated: true, completion: nil)
                        }
                        
                        
                        // ...
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    // MARK: Helper Functions
    
    func getCurrentLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func setSelectedUserTo(type: user) {
        switch type {
        case .geek:
            geekView.isHidden = false
            teacherView.isHidden = true
            setPower()
            geekButton.alpha = 1
            teacherButton.alpha = 0.5
            
            geekButton.titleLabel!.font = UIFont(name: "Avenir-Heavy", size: 19)
            teacherButton.titleLabel!.font = UIFont(name: "Avenir-Book", size: 19)
            
        case .teacher:
            geekView.isHidden = true
            teacherView.isHidden = false
            
            geekButton.alpha = 0.5
            teacherButton.alpha = 1
            
            geekButton.titleLabel!.font = UIFont(name: "Avenir-Book", size: 19)
            teacherButton.titleLabel!.font = UIFont(name: "Avenir-Heavy", size: 19)
            
            
        }
    }
    func setUpUI() {
        
        fullNameView.layer.cornerRadius = 5
        emailView.layer.cornerRadius = 5
        passwordView.layer.cornerRadius = 5
        schoolNameView.layer.cornerRadius = 5
        classRoomView.layer.cornerRadius = 5
        signUpButton.layer.cornerRadius = 5
        schoolContainerView.layer.cornerRadius = 5
        schoolContainerView.layer.masksToBounds = false
        schoolContainerView.layer.shadowOffset = CGSize(width: -1, height: 1)
        schoolContainerView.layer.shadowOpacity = 0.5;
        schoolContainerView.clipsToBounds = true
        schoolContainerView.isHidden = true
        powerButton.isHidden = true
        powerContainer.isHidden = true
        
    }
    
    func userFormFor(type: user, signIn:Bool=false) {
        if signIn {
            fullNameView.isHidden = true
            classRoomView.isHidden = true
            schoolNameView.isHidden = true
            self.signin = true
            return
        }
        self.signin = false
        fullNameView.isHidden = false
        schoolNameView.isHidden = false
        
        switch type {
        case .geek:
            powerButton.isHidden = false
            classPowerImageView.image = #imageLiteral(resourceName: "magic-wand")
        case .teacher:
            powerButton.isHidden = true
            classPowerImageView.image = #imageLiteral(resourceName: "blackboard")
            classRoomView.isHidden = false
        }
    }
    
    func formCompletedFor(userType: user) -> Bool {
        
        if emailTextField.text == "" || passwordTextField.text == "" || fullNameTextField.text == "" || schoolButton.titleLabel!.text == "School" {
            return false
        }
        switch userType {
        case .teacher:
            if classroomTextField.text == "" {
                return false
            }
        default: break
            
        }
        return true
    }
    
    
    // MARK: Map Functions
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found user's location: \(location)")
            userLocation = ["longitude" : Float(location.coordinate.longitude), "latitude": Float(location.coordinate.latitude) ]
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if signin {
        if textField == passwordTextField || textField == emailTextField {
//            self.signUpButton.frame.origin.y = self.view.frame.height - 150
//            self.emailView.frame.origin.y -= 50
//            self.passwordView.frame.origin.y -= 50
        }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if signin {
            if textField == passwordTextField || textField == emailTextField {
//                self.signUpButton.frame.origin.y = self.view.frame.height + 150
//                self.emailView.frame.origin.y += 50
//                self.passwordView.frame.origin.y += 50
            }
        }
    }
    
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == schoolTableView {
            return Array(json!.keys).count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == schoolTableView {
            return 1
        }
        return powers.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == schoolTableView {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PickerTableViewCell
        
        let schoolNames  = Array(json!.keys)
        
        let school = schoolNames[indexPath.section]
        
        cell.currentSchool = school
        cell.loginViewController = self
        
        // add border and color
        cell.backgroundColor = Helper.colorWithHexString(hex: "#AAD3EA")
        cell.layer.masksToBounds = false;
        cell.layer.cornerRadius = 5.0;
        cell.layer.shadowOffset = CGSize(width: -1, height: 2)
        cell.layer.shadowOpacity = 0.5;
        cell.clipsToBounds = true
        return cell
        
        }
        else  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SliderTableViewCell
            
            let power = powers[indexPath.row]
            cell.backgroundColor = .clear
            cell.powerButton.setTitle(power, for: .normal)
            cell.loginViewController = self
            cell.powerView.roundAndShadow(radius: cell.powerView.frame.height/2, opacity: 0.3)
            
        return cell
        }
       
        
    }
    
    func setSchool(_ school: String) {
        schoolContainerView.isHidden = true
        schoolButton.setTitle(school, for: .normal)
    }
    
    func setPower() {
        
        if chosenPower != "" {
            powerButton.setTitle("Powers: " + chosenPower.capitalized, for: .normal)
        } else {
            powerButton.setTitle("Powers:", for: .normal)
        }
        self.view.bringSubview(toFront: powerContainer)
        powerContainer.isHidden = true
    }
}
