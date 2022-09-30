//
//  File.swift
//  
//
//  Created by Dhruv Jariwala on 30/09/22.
//

import Foundation
import SwiftyJSON

public class Config : NSObject{
    let BaseUrl : String = ""
    var access_token = "Bearer \(UserDefaults.standard.value(forKey: "access_tokens") ?? "")"
    static var fcmToken : String = "\(UserDefaults.standard.value(forKey: "FcmToken") ?? "")"
   
    func profile() -> json  {
        let decoded  = UserDefaults.standard.object(forKey: "profile")

        let Object = JSON(decoded as Any)
        return Object
    }
}
