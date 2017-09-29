//
//  GeekViewController.swift
//  moonshot_test
//
//  Created by Miriam Hendler on 8/26/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import CoreLocation
import Foundation
import MessageUI
import UIKit

class GeekViewController: UIViewController {
    
    var newUser: User? {
        didSet {
            
        }
    }
    var teachersHelped = 0 {
        didSet {
            teachersHelpedLabel.text = "You've helped \(teachersHelped) teacher today"
        }
    }
    
    var imagePicker: UIImagePickerController?
    var ref: FIRDatabaseReference?
    var refHandle: FIRDataSnapshot?
    var requests = [Request]() {
        didSet {
            for i in 0..<requests.count {
                if requests[i].user.userType == .geek {
                if requests[i].power != chosenPower {
                    requests.remove(at: i)
                    break
                }
                }
            }
            
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var choosePowerView: UIView!
    //Request Outlets
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var powerButton: UIButton!
    @IBOutlet weak var requestView: UIView!
    var requestPower = ""
    var setMyPower = false
    @IBOutlet weak var requestTextField: UITextView!
    
    @IBAction func awesomeButtonPressed(_ sender: Any) {
        self.view.bringSubview(toFront: requestView)
        
        confirmView.isHidden = true
        
        self.view.sendSubview(toBack: confirmView)
        tableView.isHidden = false
        requestButton.isHidden = false
        
    }
    @IBAction func sendButtonPressed(_ sender: Any)
    {
        
        sendRequest()
        requestTextField.endEditing(true)
        self.view.bringSubview(toFront: confirmView)
        tableView.isHidden = false
        requestButton.isHidden = false
    }
    
    var powers: [String] = ["algebra","tech","history","calculus", "design"]
    
    var chosenPower: String = "" {
        didSet {
            
            let school_topic = newUser!.school.lowercased().replacingOccurrences(of: " ", with: "_")
            for power in powers {
                if chosenPower == power {
                    print(chosenPower)
                    
                    for i in 0..<requests.count {
                        if requests[i].power != chosenPower {
                            requests.remove(at: i)
                            break
                        }
                    }
                    tableView.reloadData()
                    
                    let postRef = ref!.child("posts").child(newUser!.school).child(chosenPower).child("not_accepted")
                    
                    postRef.observe(.childAdded, with: { (snapshot) in
                        let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                        
                        let wizardName = postDict["fullname"] as! String
                        let locationCoord = postDict["location"] as? [String: Float] ?? ["longitude": -122.1566630, "latitude": 37.4366530]
                        let school = postDict["school"] as! String
                        let prof = postDict["profile"] as? String ?? #imageLiteral(resourceName: "placeholder").encodeTo64()
                        let text = postDict["text"] as! String
                        let email = postDict["email"] as? String ?? "miriamthendler@gmail.com"
                        let power = postDict["power"] as? String ?? ""
                        let wizard = User(userType: .geek, fullname: wizardName)
                        wizard.location = locationCoord
                        wizard.school = school
                        wizard.profile = prof
                        wizard.email = email
                        wizard.power = power
                        
                        let request = Request(user: wizard, text: text, date: snapshot.key)
                        request.power = power
                        if request.user.email != self.newUser!.email {
                            self.requests.append(request)
                        }
                        
                    })
                    FIRMessaging.messaging().subscribe(toTopic: school_topic + "_" + power)
                } else {
                    FIRMessaging.messaging().unsubscribe(fromTopic: school_topic + "_"+power)
                    let postRef = ref!.child("posts").child(newUser!.school).child(power).child("not_accepted")
                    postRef.removeAllObservers()
                }
            }
            
        }
    }
    
    @IBOutlet weak var geekNameLabel: UILabel!
    @IBOutlet weak var teachersHelpedLabel: UILabel!
    
    @IBAction func unwindToGeek(segue:UIStoryboardSegue) { }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var powerTableView: UITableView!
    
    @IBOutlet weak var powerContainer: UIView!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var myPowersButton: UIButton!
    @IBOutlet weak var requestButton: UIButton!
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        setPower()
        
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        logout()
    }
    @IBAction func profileButtonPressed(_ sender: Any) {
        presentPhotoOptions()
    }
    @IBAction func requestButtonPressed(_ sender: Any) {
        setMyPower = false
        requestView.isHidden = false
        tableView.isHidden = true
        requestButton.isHidden = true
        requestTextField.endEditing(true)
    }
    @IBAction func requestPowerButtonPressed(_ sender: Any) {
        setMyPower = false
        powerContainer.isHidden = false
        self.view.bringSubview(toFront: powerContainer)
        
    }
    
    @IBAction func closeRequestButtonPressed(_ sender: Any) {
        requestView.isHidden = true
        confirmView.isHidden = true
        tableView.isHidden = false
        requestButton.isHidden = false
    }
    @IBAction func myPowersButtonPressed(_ sender: Any) {
        setMyPower = true
        powerContainer.isHidden = false
        self.view.bringSubview(toFront: powerContainer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up textfield delegate
        requestTextField.delegate = self
        powerContainer.isHidden = true
        powerContainer.roundAndShadow()
        powerTableView.delegate = self
        powerTableView.dataSource = self
        powerTableView.separatorStyle = .none
        requestView.roundAndShadow()
        confirmView.roundAndShadow()
        requestView.isHidden = true
        confirmView.isHidden = true
        choosePowerView.roundAndShadow(opacity: 0.1)
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker =  UIImagePickerController()
        imagePicker!.delegate = self
        
        requests = []
        
        // Do any additional setup after loading the view.
        ref = FIRDatabase.database().reference()
        
        if let user = newUser {
            geekNameLabel.text = user.fullname
            let image = user.decodeImage() ?? #imageLiteral(resourceName: "placeholder")
            profileButton.setImage(image, for: .normal)
            self.chosenPower = user.power
            myPowersButton.setTitle("Power: " + user.power.capitalized, for: .normal)
            
        }
        
        
        let postRef = ref!.child("posts").child(newUser!.school).child("not_accepted")
        
        postRef.observe(.childAdded, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            
            let teacherName = postDict["fullname"] as! String
            let locationCoord = postDict["location"] as? [String: Float] ?? ["longitude": -122.1566630, "latitude": 37.4366530]
            let classroom = postDict["classroom"] as! String
            let school = postDict["school"] as! String
            let prof = postDict["profile"] as? String ?? #imageLiteral(resourceName: "placeholder").encodeTo64()
            let text = postDict["text"] as! String
            let email = postDict["email"] as? String ?? "miriamthendler@gmail.com"
            let teacher = User(userType: .teacher, fullname: teacherName)
            teacher.location = locationCoord
            teacher.school = school
            teacher.classroom = classroom
            teacher.profile = prof
            teacher.email = email
            
            
            let request = Request(user: teacher, text: text, date: snapshot.key)
            self.requests.append(request)
        })
        
        
        
        
        
        //        ref?.database.reference().child("powers").observeSingleEvent(of: .value, with: { (snapshot) in
        //            // Get user value
        //            let value = snapshot.value as? [String]
        //            self.powers = value!
        //
        //
        //            // ...
        //        }) { (error) in
        //            print(error.localizedDescription)
        //        }
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        profileButton.maskToCircle()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func teacherSelectedFor(request: Request) {
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        
        
        let requestDict = request.toDict()
        
        if request.user.userType == .teacher {
            ref!.child("posts").child(request.user.school).child("not_accepted").child(request.date).removeValue()
            ref!.child("posts").child(request.user.school).child("accepted").child(request.date).setValue(requestDict)
        } else {
            ref!.child("posts").child(request.user.school).child(request.power).child("not_accepted").child(request.date).removeValue()
            ref!.child("posts").child(request.user.school).child(request.power).child("accepted").child(request.date).setValue(requestDict)
        }
        
        for i in 0..<requests.count {
            print(requests.count)
            print(i)
            if requests[i].date == request.date  {
                requests.remove(at: i)
                break
            }
        }
        teachersHelped += 1
        sendEmail(request: request)
        tableView.reloadData()
        
    }
    
    func logout() {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Launched")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}

extension GeekViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func uploadPic(){
        if let user = FIRAuth.auth()?.currentUser {
            self.ref!.child("users").child(user.uid).updateChildValues(["profile": self.newUser!.profile])
        }
    }
    
    func getProfilePic(fromSource: UIImagePickerControllerSourceType) {
        
        imagePicker = UIImagePickerController()
        imagePicker!.delegate = self
        
        switch fromSource {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker!.sourceType = .camera;
                imagePicker!.allowsEditing = false
                self.present(imagePicker!, animated: true, completion: nil)
            }
        case .photoLibrary:
            imagePicker!.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker!.allowsEditing = true
            present(imagePicker!, animated: true, completion: nil)
        default:
            break
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        profileButton.setImage(image, for: .normal)
        
        profileButton.setImage(image.withRenderingMode(.automatic), for: .normal)
        profileButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .highlighted)
        profileButton.imageView?.contentMode = .scaleAspectFit
        
        let lowResImage = image.resizeImageWith(newSize: CGSize(width: 30, height: 30))
        newUser!.profile = lowResImage.encodeTo64()
        
        uploadPic()
        
        dismiss(animated:true, completion: nil)
        
    }
    func presentPhotoOptions() {
        
        let optionMenu = UIAlertController(title: nil, message: "Choose A Photo", preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
            self.getProfilePic(fromSource: .camera)
            
            print("taking a photo")
        })
        let choosePhotoAction = UIAlertAction(title: "Choose From Library", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
            {
                self.getProfilePic(fromSource: .photoLibrary)
            }
            
            print("choosing a photo from the library")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(choosePhotoAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    func getAddress(location : [String: Float], callback:@escaping (String) -> ()) {
        let longitude = location["longitude"]
        let latitude = location["latitude"]
        
        let location = CLLocation(latitude: CLLocationDegrees(latitude!), longitude: CLLocationDegrees(longitude!)) //changed!!!
        print(location)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if let placemark = placemarks {
                let pm = placemark[0] as! CLPlacemark
                print(pm.locality)
                
                callback("hi")
            }
            else {
                print("Problem with the data received from geocoder")
            }
            
        })
        
    }
}

extension GeekViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == powerTableView {
            return 1
        }
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == powerTableView {
            return powers.count
        }
        return 1
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == powerTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SliderTableViewCell
            
            let power = powers[indexPath.row]
            
            cell.backgroundColor = .clear
            cell.powerButton.setTitle(power, for: .normal)
            cell.geekViewController = self

        
            
            cell.powerView.roundAndShadow(radius: cell.powerView.frame.height/2, opacity: 0.3)
            
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TeacherTableViewCell
        
        let request = requests[indexPath.section]
        
        cell.currentRequest = request
        cell.geekViewController = self
        
        // add border and color
        cell.backgroundColor = UIColor.white
        cell.layer.masksToBounds = false;
        cell.layer.cornerRadius = 3.0;
        cell.layer.shadowOffset = CGSize(width: -1, height: 2)
        cell.layer.shadowOpacity = 0.5;
        cell.clipsToBounds = true
        
        
        
        return cell
    }
    
    func setPower() {

        myPowersButton.setTitle("Powers: " + chosenPower.capitalized, for: .normal)
        powerContainer.isHidden = true
        
        if let user = FIRAuth.auth()?.currentUser {
            
            self.ref!.child("users").child(user.uid).updateChildValues(["power": chosenPower])
            
            
        }
    }
    
    func setRequestPower() {
        
        if requestPower != "" {
            powerButton.setTitle("Power: " + requestPower.capitalized, for: .normal)
        } else {
            powerButton.setTitle("Choose a Power", for: .normal)
        }
        self.view.bringSubview(toFront: powerContainer)
        powerContainer.isHidden = true
    }
    
}

extension GeekViewController: MFMailComposeViewControllerDelegate {
    
    func sendEmail(request: Request) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients([request.user.email])
        composeVC.setSubject("Moonshot Wizard - \(newUser!.fullname)")
        composeVC.setMessageBody("Hi \(request.user.fullname), \nI saw your request for tech help at \(request.user.school) in class \(request.user.classroom) on the Moonshot Squad app! I would love to help you out! \n\nI am avaliable today at:  \n\nBest, \n \(newUser!.fullname) ", isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
}
extension GeekViewController {
    func uploadRequest() {
        
        let date = Helper.getCurrentTime()
        let request = Request(user: newUser!, text: requestTextField.text, date: date)
        request.power = requestPower
        
        self.ref!.child("posts").child(request.user.school).child(requestPower).child("not_accepted").child(date).setValue(["fullname": request.user.fullname,
                                                                                                                            "school": request.user.school,
                                                                                                                            "location": request.user.location ?? ["longitude": -122.1566630, "latitude": 37.4366530],
                                                                                                                            "profile": request.user.profile,
                                                                                                                            "text": request.text,
                                                                                                                            "email": request.user.email,
                                                                                                                            "power": request.power])
        let school_topic = request.user.school.lowercased().replacingOccurrences(of: " ", with: "_")
        Helper.sendToTopic(school_topic: school_topic + "_" + requestPower, title: "\(request.user.fullname) needs a \(request.power) wizard)", message: request.text)
    }
    
    func sendRequest() {
        
        let holder = "Write what you need help with in 1 to 2 sentences here."
        
        if requestTextField.text != holder || requestPower != "" {
            uploadRequest()
            confirmView.isHidden = false
            requestView.isHidden = true
            requestTextField.text = holder
        } else {
            
            let alertController = UIAlertController(title: "Error", message: "Please fill out the request form before pressing send :)", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension GeekViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write what you need help with in 1 to 2 sentences here."
        {
            textView.text = ""
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == "Write what you need help with in 1 to 2 sentences here."
        {
            textView.text = ""
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Write what you need help with in 1 to 2 sentences here."
        }
    }
    
    
}
