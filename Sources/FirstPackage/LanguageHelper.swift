//
//  File.swift
//  
//
//  Created by Dhruv Jariwala on 30/09/22.
//

import Foundation
import UIKit

let english = "en"
let arabic = "ar"
let APPLE_LANGUAGE = "AppleLanguages"

public func setLanguage(lng: String) {
    UserDefaults.standard.setValue(lng, forKey: APPLE_LANGUAGE)
    UserDefaults.standard.synchronize()
}


/// Get currunt lang code for localization
/// - Returns: retun short code `en` or `ar`
public func getLanguage() -> String {
    if let arr = (UserDefaults.standard.object(forKey: APPLE_LANGUAGE) as? [String]) {
        return arr[0]
    }
    return "en"
}

//MARK: - lang functions
/// Get currunt lang code
/// - Returns: retun lang code
public func getLangCode () -> String{
    if let arr = (UserDefaults.standard.object(forKey: APPLE_LANGUAGE) as? [String]) {
        if arr[0].hasPrefix("ar"){
            return "ar"
        }
    }
    return "en"
}
