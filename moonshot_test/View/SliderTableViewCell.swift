//
//  SliderTableViewCell.swift
//  moonshot_test
//
//  Created by Miriam Hendler on 9/10/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import UIKit

class SliderTableViewCell: UITableViewCell {

    
    @IBOutlet weak var powerButton: UIButton!
    @IBOutlet weak var powerView: UIView!
    @IBOutlet weak var pImageView: UIImageView!
    var loginViewController: LoginViewController? = nil
    var geekViewController: GeekViewController? = nil {
        didSet {
//            if geekViewController!.setMyPower {
//            if let index = geekViewController!.chosenPowers.index(of: powerButton.titleLabel!.text!) {
//                let yellow = Helper.colorWithHexString(hex: "#FFE09B")
//                let blue = Helper.colorWithHexString(hex: "#7EBBDC")
//                
//                setBackgroundColor(view: self.powerView, color: yellow, textColor: blue)
//                }
//            }
        }
    }
    var teacherViewController: TeacherViewController? = nil
    var didSelect = false
    
    
    @IBAction func powerButtonPressed(_ sender: Any) {
//        let yellow = Helper.colorWithHexString(hex: "#FFE09B")
//        let blue = Helper.colorWithHexString(hex: "#7EBBDC")
        if let loginVC = loginViewController {

            loginVC.chosenPower = powerButton.titleLabel!.text!
            loginVC.setPower()

        }
        
        if let geekVC = geekViewController {
            didSelect = !didSelect
            if !geekVC.setMyPower {
                geekVC.requestPower = self.powerButton.titleLabel!.text!
                geekVC.setRequestPower()
                return
            }
            if geekVC.chosenPower != powerButton.titleLabel!.text! {
            geekVC.chosenPower = powerButton.titleLabel!.text!
            }
            geekVC.setPower()
        

        }
        
        if let teachVC = teacherViewController {
            didSelect = !didSelect
//            if didSelect {
//                teachVC.chosenPowers.append(powerButton.titleLabel!.text!)
//                setBackgroundColor(view: self.powerView, color: yellow, textColor: blue)
//            } else {
//                setBackgroundColor(view: self.powerView, color: blue, textColor: .white)
//                for i in 0..<teachVC.chosenPowers.count {
//                    if self.powerButton.titleLabel!.text == teachVC.chosenPowers[i] {
//                        teachVC.chosenPowers.remove(at: i)
//                        break
//                    }
//                }
            teachVC.chosenPower = powerButton.titleLabel!.text!
            teachVC.setPower()
//            }
        }
    }
    
    func setBackgroundColor(view: UIView, color: UIColor, textColor: UIColor) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options:[.curveEaseIn, .curveLinear], animations: {
//            self.powerButton.titleLabel?.textColor = textColor
            self.powerButton.setTitleColor(textColor, for: .normal)
            view.backgroundColor = color
        }, completion:nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
