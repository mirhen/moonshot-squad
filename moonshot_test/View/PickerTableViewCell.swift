//
//  PickerTableViewCell.swift
//  moonshot_test
//
//  Created by Miriam Hendler on 9/2/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell {

//    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var button: UIButton!

    
    var loginViewController : LoginViewController? = nil
    var currentSchool: String? {
        didSet {
            setUpUI()
        }
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        loginViewController!.setSchool(currentSchool!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI() {
        
            self.button.setTitle(currentSchool, for: .normal)
        
    }

}
