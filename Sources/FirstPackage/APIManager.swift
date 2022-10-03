//
//  FirebaseAuthManager.swift
//
//
//  Created by Dhruv Jariwala on 28/09/22.
//
import Alamofire
import Foundation
import UIKit
import SwiftyJSON
import JGProgressHUD

///THIS IS JSON Dictionary format
typealias JSONDictionary = Dictionary<String, AnyObject>
typealias JSONStringDictionary = Dictionary<String, String>

///THIS IS JSON array format
typealias JSONArray = Array<AnyObject>
typealias json = JSON

public class APIManager{
    
    public init() {}
    
    //MARK: - Call Services
    /// Commonfunction that is used to call all the APIs
    func CallService(serviceName : APIEndPoint, parameters : Parameters, method : HTTPMethod , isShowloader:Bool = true, withSuccess : @escaping ((_ responseObj : JSONDictionary?) -> Void), failure : @escaping ((_ error : String?) -> Void)) {
        
        let pageUrlStr =  Config().BaseUrl + serviceName.value
        
        let headers : HTTPHeaders = [
            "Accept" : "Application/json",
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization": Config().access_token,
            "language" : getLangCode()
        ]
        print("pageUrlStr :- ",pageUrlStr)
        print("Headers :- ",headers)
        print("parameters :- ",parameters)
        if isShowloader{
            showLoader()
        }
        AF.request(pageUrlStr, method : method, parameters : parameters, encoding : URLEncoding.queryString, headers : headers).responseJSON { response in
            switch response.result {
                
            case .success(let JSON):
                if var jsonDictionary = JSON as? JSONDictionary{
                    jsonDictionary["statusCode"] = (response.response?.statusCode as AnyObject)
                    withSuccess(jsonDictionary)
                    if jsonDictionary["statusCode"]?.intValue == 401 {
                        print("unauthenticated")
                    }
                } else {
                    failure("Request failed with error")
                }
                if isShowloader {
                    hideLoader()
                }
                break
                
            case .failure(let error):
                if error.responseCode == -1001 {
                    print("TIME OUR ERROR")
                }
                failure("Request failed with error: \(error)")
                if isShowloader{
                    hideLoader()
                }
                break
            }
        }
    }


    //MARK: - Call Services
    /// Common function that is used to call all the APIs
    func CallUploadService(serviceName : APIEndPoint, parameters : Parameters,files:[JSONDictionary], method : HTTPMethod , isShowloader:Bool = true, withSuccess : @escaping ((_ responseObj : JSONDictionary?) -> Void), failure : @escaping ((_ error : String?) -> Void)) {
        
        let pageUrlStr = Config().BaseUrl + serviceName.value
        
        let headers : HTTPHeaders = [
            "Accept" : "Application/json",
            "Content-type": "multipart/form-data",
            "Authorization": Config().access_token,
            "language" : getLangCode()
        ]
        print("pageUrlStr :- ",pageUrlStr)
        print("Headers :- ",headers)
        print("parameters :- ",parameters)
        if isShowloader{
            showLoader()
        }
     
        AF.upload(multipartFormData: {  (multipartFormData) in
            for (key, value) in parameters {
                 if let val = value as? [String] , let dataofarray = stringArrayToData(stringArray: val) {
                    multipartFormData.append(dataofarray, withName: key)
                } else  if let val = value as? [Int] , let dataofarray = intArrayToData(stringArray: val) {
                    multipartFormData.append(dataofarray, withName: key)
                }else if let val = value as? JSONDictionary , let dataofarray = stringDicToData(dic: val) {
                    multipartFormData.append(dataofarray, withName: key)
                }else{
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                }
            }
            for object in files{
                if let data = object["data"] as? Data{
                    multipartFormData.append(data, withName: object.valueForKeyString("key"), fileName: object.valueForKeyString("name"), mimeType: "*/*")
                }
             }
        }, to: pageUrlStr, usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON {   response in
     
            switch response.result {
            case .success(let JSON):
                print("Response with JSON : \(JSON)")
                if var jsonDictionary = JSON as? JSONDictionary{
                    jsonDictionary["statusCode"] = (response.response?.statusCode as AnyObject)
                    withSuccess(jsonDictionary)
                    print("JSON Dictionary :- ",jsonDictionary)
                    print("ResponseCode :- ",jsonDictionary["statusCode"] ?? "")
                    
                }else{
                    failure("Request failed with error")
                }
                if isShowloader{
                    hideLoader()
                }
                break
            case .failure(let error):
                if error.responseCode == -1001 {
                    print("TIME OUR ERROR")
                }
                failure("Request failed with error: \(error)")
                if isShowloader{
                    hideLoader()
                }
                break
            }
        }
    }
}

var hud = JGProgressHUD(style: .dark)
public func showLoader() {
    hud.textLabel.text = "please_wait"
    hud.show(in: UIApplication.shared.windows.first!)
}

public func hideLoader() {
    hud.dismiss(animated: true)
}

public func stringArrayToData(stringArray: [String]) -> Data? {
  return try? JSONSerialization.data(withJSONObject: stringArray, options: [])
}

public func intArrayToData(stringArray: [Int]) -> Data? {
  return try? JSONSerialization.data(withJSONObject: stringArray, options: [])
}

func stringDicToData(dic: JSONDictionary) -> Data? {
    return try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
}

public func jsonArrayToData(stringArray: [String]) -> Data? {
  return try? JSONSerialization.data(withJSONObject: stringArray, options: [])
}


//MARK: - Dictionary setup
extension Dictionary {
    
    /// convert dictionary to json string
    ///
    /// - Returns: return value description
    public func convertToJSonString() -> String {
        do {
            let dataJSon = try JSONSerialization.data(withJSONObject: self as AnyObject, options: JSONSerialization.WritingOptions.prettyPrinted)
            let st: NSString = NSString.init(data: dataJSon, encoding: String.Encoding.utf8.rawValue)!
            return st as String
        } catch let error as NSError { print(error) }
        return ""
    }
    
    
    /// check given key have value or not
    ///
    /// - Parameter stKey: pass key what you want check
    /// - Returns: true if exist
    public func isKeyNull(_ stKey: String) -> Bool {
        let dict: JSONDictionary = (self as AnyObject) as! JSONDictionary
        if let val = dict[stKey] { return val is NSNull ? true : false }
        return true
    }
    
    
    
    /// handal carsh when null valu or key not found
    ///
    /// - Parameter stKey: pass the key of object
    /// - Returns: blank string or value if exist
    public func valueForKeyString(_ stKey: String) -> String {
        let dict: JSONDictionary = (self as AnyObject) as! JSONDictionary
        if let val = dict[stKey] {
            if val is NSNull{
                return ""
            }else if (val as? NSNumber) != nil {
                return  val.stringValue
                
            }else if (val as? String) != nil {
                return val as! String
            }else{
                return ""
            }
        }
        return ""
    }
    
    ///expaned function of null value
    public func valueForKeyString(_ stKey: String,nullvalue:String) -> String {
        return  self.valueForKeyWithNullString(Key: stKey, NullReplaceValue: nullvalue)
    }
    
    /// Update dic with other Dictionary
    ///
    /// - Parameter other: add second Dictionary which one you want to add
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
    
    
    /// USE TO GET VALUE FOR KEY if key not found or null then replace with the string
    ///
    /// - Parameters:
    ///   - stKey: pass key of dic
    ///   - NullReplaceValue: set value what you want retun if that key is nill
    /// - Returns: retun key value if exist or return null replace value
    public func valueForKeyWithNullString(Key stKey: String,NullReplaceValue:String) -> String {
        let dict: JSONDictionary = (self as AnyObject) as! JSONDictionary
        if let val = dict[stKey] {
            if val is NSNull{
                return NullReplaceValue
            } else{
                if (val as? NSNumber) != nil {
                    return  val.stringValue
                }else{
                    return val as! String == "" ? NullReplaceValue : val as! String
                }
            }
        }
        return NullReplaceValue
    }
    
    public func valuForKeyWithNullWithPlaseString(Key stKey: String,NullReplaceValue:String) -> String {
        let dict: JSONDictionary = (self as AnyObject) as! JSONDictionary
        if let val = dict[stKey] {
            if val is NSNull{
                return NullReplaceValue
            } else{
                if (val as? NSNumber) != nil {
                    if Int(truncating: val as! NSNumber) > 0{
                        return  "+" + val.stringValue
                    }
                }else{
                    if Int(val as! String) ?? 0 > 0{
                        return val as! String == "" ? NullReplaceValue : "+" + (val as! String)
                    }else{
                        return val as! String == "" ? NullReplaceValue : val as! String
                    }
                }
            }
        }
        return NullReplaceValue
    }
    
    public func valuForKeyArray(_ stKey: String) -> Array<Any> {
        let dict: JSONDictionary = (self as AnyObject) as! JSONDictionary
        if let val = dict[stKey] {
            if val is NSNull{
                return []
            } else if val is NSArray{
                return val as! Array<Any>
            } else if val is String{
                return [val] as Array<Any>
            }else {
                return val as! Array<Any>
            }
        }
        return []
    }
    
    /// dic
    /// - Parameter stKey: <#stKey description#>
    func valuForKeyDic(_ stKey: String) -> JSONDictionary {
        let dict: JSONDictionary = (self as AnyObject) as! JSONDictionary
        if let val = dict[stKey] {
            if val is NSNull{
                return JSONDictionary()
            } else if ((val as? JSONDictionary) != nil){
                return val as! JSONDictionary
            }
        }
        return JSONDictionary()
    }
    
    
    
    /// This is function for convert dicticonery to xml string also check log for other type of string i only handal 2 or 3 type of stct
    ///
    /// - Returns: return xml string
    public func createXML()-> String{
        
        var xml = ""
        for k in self.keys {
            
            if let str = self[k] as? String{
                xml.append("<\(k as! String)>")
                xml.append(str)
                xml.append("</\(k as! String)>")
                
            }else if let dic =  self[k] as? Dictionary{
                xml.append("<\(k as! String)>")
                xml.append(dic.createXML())
                xml.append("</\(k as! String)>")
                
            }else if let array : NSArray =  self[k] as? NSArray{
                for i in 0..<array.count {
                    xml.append("<\(k as! String)>")
                    if let dic =  array[i] as? Dictionary{
                        xml.append(dic.createXML())
                    }else if let str = array[i]  as? String{
                        xml.append(str)
                    }else{
                        fatalError("[XML]  associated with \(self[k] as Any) not any type!")
                    }
                    xml.append("</\(k as! String)>")
                    
                }
            }else if let dic =  self[k] as? NSDictionary{
                xml.append("<\(k as! String)>")
                
                let newdic = dic as! Dictionary<String,Any>
                xml.append(newdic.createXML())
                xml.append("</\(k as! String)>")
                
            }
            else{
                fatalError("[XML]  associated with \(self[k] as Any) not any type!")
            }
        }
        
        return xml
    }
    
    public func valueForKeyInt( _ any:String) -> Int {
        return valueForKeyInt(any,nullValue: 0)
    }
    
    public func valueForKeyInt( _ any:String,nullValue :Int) -> Int {
        var iValue: Int = 0
        let dict: JSONDictionary = self as! JSONDictionary
        if let val = dict[any] {
            if val is NSNull {
                return 0
            }
            else {
                if val is Int {
                    iValue = val as! Int
                }
                else if val is Double {
                    iValue = Int(val as! Double)
                }
                else if val is String {
                    let stValue: String = val as! String
                    iValue = (stValue as NSString).integerValue
                }
                else if val is Float {
                    iValue = Int(val as! Float)
                }else{
                    let error = NSError(domain:any,
                                        code: 100,
                                        userInfo:dict)
                }
            }
        }
        return iValue
    }
}
