//
//  Helper.swift
//  moonshot_test
//
//  Created by Miriam Hendler on 9/2/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class Helper {
    static func dumpJson(file: String) -> JSON {
        let path = Bundle.main.path(forResource: file, ofType: "json")
        let jsonData = NSData(contentsOfFile:path!)
        let json = JSON(data: jsonData! as Data)
        return json
        //        println(json["DDD"].string)
    }
    
    static func colorWithHexString (hex:String) -> UIColor
    {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cString = cString.lowercased()
        
        if (cString.hasPrefix("#"))
        {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.characters.count != 6)
        {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    static func sendToTopic(school_topic: String, title: String, message: String) {

        let key = "AIzaSyDQ76EQWhM7O5ExVUEtxTU9sHTJHUPop3Q"
        let headers = ["Authorization": "key=\(key)", "Content-Type": "application/json"]
        let contentURL = "https://fcm.googleapis.com/fcm/send"
        let params: [String: Any] = ["to": "/topics/\(school_topic)", "notification" : ["body" : message, "priority" : "high", "title" : title]]
        
        Alamofire.request(contentURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).response { (response) in
            print("Sent Notification")
        }
    }
    static func getCurrentTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        return "\(Int(month))-\(Int(day))-17-\(Int(hour))-\(Int(minutes))-\(second)"
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return self[Range(start ..< end)]
    }
}

extension UIView {
    func roundAndShadow(radius:CGFloat=5, opacity:Float=0.5) {
        self.layer.masksToBounds = false;
        self.layer.cornerRadius = radius;
        self.layer.shadowOffset = CGSize(width: -1,height: 1);
        self.layer.shadowOpacity = opacity;
    }
    
}

