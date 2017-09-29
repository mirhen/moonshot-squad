//
//  Request.swift
//  moonshot_test
//
//  Created by Miriam Hendler on 8/26/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import Foundation

class Request {
    
    var date: String
    var user: User
    var text: String
    var power: String = ""
    
    init(user: User, text: String, date: String) {
        self.user = user
        self.text = text
        self.date = date
    }
    
    func toDict() -> [String: Any] {
        
        let dict: [String: Any] = [ "fullname": self.user.fullname,
        "school": self.user.school,
        "classroom":self.user.classroom,
        "location": self.user.location!,
        "profile": self.user.profile,
        "text": self.text,
        "power": self.power]
        
        return dict
        
    }
}
