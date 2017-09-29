//
//  User.swift
//  moonshot_test
//
//  Created by Miriam Hendler on 8/26/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseCore

enum user: String {
    case geek = "geek"
    case teacher = "teacher"
}

class User {
    var userType: user
    var fullname: String
    var school: String = ""
    var email: String = "mjammer18@gmail.com"
    var classroom: String = ""
    var profile = #imageLiteral(resourceName: "placeholder").encodeTo64()
    var location: [String: Float]?
    var power: String = ""
    
    init(userType: user, fullname: String) {
        self.userType = userType
        self.fullname = fullname
    }
    
    func decodeImage() -> UIImage? {
        if self.profile == "" {
            return #imageLiteral(resourceName: "placeholder")
        }
        let dataDecoded : Data = Data(base64Encoded:  self.profile, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        
        return decodedimage
    }
    
    
    
}
