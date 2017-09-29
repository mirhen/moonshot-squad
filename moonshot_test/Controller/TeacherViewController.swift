//
//  TeacherViewController.swift
//  moonshot_test
//
//  Created by Miriam Hendler on 8/26/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class TeacherViewController: UIViewController {
    
    var newUser: User?
    var imagePicker: UIImagePickerController?
    var ref: FIRDatabaseReference?
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var confirmView: UIView!
    
    @IBOutlet weak var powerButton: UIButton!
    @IBOutlet weak var teacherNameLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var classroomLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var powerTableView: UITableView!
    @IBOutlet weak var powerView: UIView!
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var requestTextField: UITextView!
    
    //Request Outlets
    
    
    var chosenPower: String = ""
    var powers: [String] = ["algebra","tech","history","calculus", "design"]
    
    @IBOutlet weak var powerContainer: UIView!
    
    @IBAction func closePowersButtonPressed(_ sender: Any) {
        setPower()
    }
    @IBAction func powerButtonPressed(_ sender: Any)
    {
        self.view.bringSubview(toFront: powerContainer)
        powerContainer.isHidden = false
    }
    @IBAction func awesomeButtonPressed(_ sender: Any) {
        self.view.bringSubview(toFront: requestView)
        
        confirmView.isHidden = true
        requestView.isHidden = false
        
        self.view.sendSubview(toBack: confirmView)
        
    }
    @IBAction func unwindToTeacher(segue:UIStoryboardSegue) { }
    
    @IBAction func profileButtonPressed(_ sender: Any) {
        presentPhotoOptions()
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        logout()
    }
    @IBAction func sendButtonPressed(_ sender: Any) {
        sendRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up textfield delegate
        requestTextField.delegate = self
        
        imagePicker =  UIImagePickerController()
        imagePicker!.delegate = self
        powerTableView.delegate = self
        powerTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        ref = FIRDatabase.database().reference()
        
        if let user = newUser {
            teacherNameLabel.text = user.fullname
            schoolNameLabel.text = user.school
            classroomLabel.text = user.classroom
            profileButton.setImage(user.decodeImage(), for: .normal)
        }
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        setUpUI()
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func uploadPic(){
        if let user = FIRAuth.auth()?.currentUser {
            self.ref!.child("users").child(user.uid).updateChildValues(["profile": self.newUser!.profile])
        }
    }
    
    func uploadRequest() {
        
        let date = Helper.getCurrentTime()
        let request = Request(user: newUser!, text: requestTextField.text, date: date)
        
        self.ref!.child("posts").child(request.user.school).child("not_accepted").child(date).setValue(["fullname": request.user.fullname,
                                                                                                        "school": request.user.school,
                                                                                                        "classroom":request.user.classroom,
                                                                                                        "location": request.user.location!,
                                                                                                        "profile": request.user.profile,
                                                                                                        "text": request.text,
                                                                                                        "email": request.user.email
                                                                                                    ])
        let school_topic = request.user.school.lowercased().replacingOccurrences(of: " ", with: "_")
        Helper.sendToTopic(school_topic: school_topic, title: "\(request.user.fullname) needs a wizard in Room \(request.user.classroom)", message: request.text)
    }
    
    func sendRequest() {
        
        let holder = "Write what you need help with in 1 to 2 sentences here."
        
        if requestTextField.text != holder || powerButton.titleLabel!.text! == "Choose a Power" {
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
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func setUpUI() {
        confirmView.isHidden = true
        profileButton.maskToCircle()
        requestView.layer.cornerRadius = 5
        titleView.layer.cornerRadius = 5
        requestView.layer.masksToBounds = false;
        requestView.layer.cornerRadius = 5.0;
        requestView.layer.shadowOffset = CGSize(width: -1,height: 1);
        requestView.layer.shadowOpacity = 0.5;
        confirmView.layer.masksToBounds = false;
        confirmView.layer.cornerRadius = 5.0;
        confirmView.layer.shadowOffset = CGSize(width: -1,height: 1);
        confirmView.layer.shadowOpacity = 0.5;
        confirmView.layer.cornerRadius = 5
        sendButton.layer.cornerRadius = 5
        powerContainer.isHidden = true
        powerContainer.roundAndShadow()
        powerTableView.separatorStyle = .none
        powerView.roundAndShadow(radius: powerView.frame.height/2, opacity: 0.1)
        
    }
    
}

extension TeacherViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
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
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePicker!.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                imagePicker!.allowsEditing = true
                present(imagePicker!, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        profileButton.setImage(image, for: .normal)
        
        profileButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        profileButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .highlighted)
        
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
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
            {
                self.getProfilePic(fromSource: .camera)
            }
            
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
    
    
    
}

extension TeacherViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write what you need help with in 1 to 2 sentences here."
        {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Write what you need help with in 1 to 2 sentences here."
        }
    }
    
    
}

extension TeacherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return powers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SliderTableViewCell
        
        let power = powers[indexPath.row]
        
        cell.backgroundColor = .clear
        cell.powerButton.setTitle(power, for: .normal)
        cell.teacherViewController = self
        cell.powerView.roundAndShadow(radius: cell.powerView.frame.height/2, opacity: 0.3)
        
        
        return cell
    }
    
    func setPower() {
        
        if chosenPower != "" {
        powerButton.setTitle("Power: " + chosenPower.capitalized, for: .normal)
        } else {
        powerButton.setTitle("Choose a Power", for: .normal)
        }
        self.view.bringSubview(toFront: powerContainer)
        powerContainer.isHidden = true
    }
    
}
