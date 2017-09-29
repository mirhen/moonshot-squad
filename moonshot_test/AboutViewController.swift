//
//  AboutViewController.swift
//  moonshot_test
//
//  Created by Miriam Hendler on 9/5/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController {

    @IBAction func emailButtonPressed(_ sender: Any) {
        sendEmail()
    }
    
    @IBAction func designershipButtonPressed(_ sender: Any) {
        goToWebsite("designership.stanford.edu")
    }
    @IBAction func websiteButtonPressed(_ sender: Any) {
        goToWebsite("miriamhendler.com")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToWebsite(_ name: String) {
        
        let name_url = "http://\(name)"
        if let url = NSURL(string: name_url) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
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

extension AboutViewController: MFMailComposeViewControllerDelegate {
    
    func sendEmail() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["miriamthendler@gmail.com"])
        composeVC.setSubject("Moonshot Feedback")
        composeVC.setMessageBody("", isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
}
