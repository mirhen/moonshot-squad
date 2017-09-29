//
//  ForgotPasswordViewController.swift
//  moonshot_test
//
//  Created by Miriam Hendler on 9/5/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import UIKit
import FirebaseAuth
class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        guard let email = emailTextField.text else {
            showAlert(title: "Error", message: "Please fill in your email", cancel: "OK")
            return
        }
        sendLoginLinkTo(email)
        showAlert(title: "Wohoo", message: "Login Link Sent!", cancel: "Awesome")
    }

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailView.roundAndShadow()
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendLoginLinkTo(_ email: String){
        FIRAuth.auth()?.sendPasswordReset(withEmail: email) { error in
            // Your code here
            print("login link sent")
        }
    }
    
    func showAlert(title: String, message: String, cancel: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: cancel, style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
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
