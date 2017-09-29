//
//  TeacherTableViewCell.swift
//  moonshot_test
//
//  Created by Miriam Hendler on 8/26/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import UIKit

class TeacherTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var requestLabel: UILabel!
    
    var geekViewController : GeekViewController? = nil
    var currentRequest: Request? {
        didSet {
            setUpUI()
        }
    }
    
    @IBAction func acceptButtonPressed(_ sender: Any) {
        geekViewController!.teacherSelectedFor(request: currentRequest!)
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
        if let request = currentRequest {
            if request.user.userType == .teacher {
            self.descriptionLabel.text = "Please meet \(request.user.fullname) at \(request.user.school) in room \(request.user.classroom))"
            
            } else {
            self.descriptionLabel.text = "Please meet \(request.user.fullname) at \(request.user.school)"
            }
            self.nameLabel.text = request.user.fullname
            self.requestLabel.text = request.text
            self.profileImageView.image = request.user.decodeImage()
            self.profileImageView.maskToCircle()
        }
    }
}
