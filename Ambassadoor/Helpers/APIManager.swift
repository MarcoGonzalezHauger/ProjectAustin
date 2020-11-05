//
//  APIManager.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 11/09/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class APIManager {
    
    
    static let shared = APIManager()
    
    // this function currently not using
    func createCustomerDwolla(params: [String: AnyObject],accessToken: String,completion: @escaping ( _ status: String, _ error: String?, _ dataValue: Data?,  _ response: URLResponse?) -> Void) {
        
        let urlString = API.kCreateCustomer
        
        let url = URL(string: urlString)
        
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        request.httpMethod = "Post"
        request.setValue("application/vnd.dwolla.v1.hal+json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.dwolla.v1.hal+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        //NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        
        let task = session.dataTask(with: request) {
            (
            data, response, error) in
            if (error != nil && data != nil) {
                
                completion("failure", error?.localizedDescription ?? "error", data, nil)
            }
            else if (error != nil || data == nil){
                completion("failure", error?.localizedDescription ?? "error", nil, nil)
            }
            else{
                //                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                completion("success",nil,data!, response)
            }
            
        }
        
        task.resume()
        
    }
    
    
    
    // this function currently not using
    func createFundingSourceForCustomer(params: [String: AnyObject],accessToken: String,customerURL: String,completion: @escaping (_ status: String,  _ error: String?,  _ dataValue: Data?, _ response: URLResponse?) -> Void) {
        
        let urlString = customerURL + "/funding-sources"
        
        let url = URL(string: urlString)
        
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        request.httpMethod = "Post"
        request.setValue("application/vnd.dwolla.v1.hal+json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.dwolla.v1.hal+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        //NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        let task = session.dataTask(with: request) {
            (
            data, response, error) in
            if (error != nil && data != nil) {
                
                completion("failure", error?.localizedDescription ?? "error", data,nil)
            }
            else if (error != nil || data == nil){
                completion("failure", error?.localizedDescription ?? "error", nil,nil)
            }
            else{
                //                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                completion("success",nil,data!,response)
            }
            
        }
        
        task.resume()
        
    }
    
    
    //get account id from strip account
    func getAccountID(authorization_code: String,completion: @escaping (_ status: String,  _ error: String?, _ dataValue: Data?) -> Void) {
        
        let stripeurl = "https://connect.stripe.com/oauth/token"
//        let urlString = "https://api-sandbox.dwolla.com/token"
        
        let url = URL(string: stripeurl)
        
		let para = "client_secret=\(API.Stripeclient_secret)/code=\(authorization_code)/grant_type=authorization_code"

        
//        let para = "grant_type=client_credentials"
        
        let postData = NSMutableData(data: para.data(using: String.Encoding.utf8)!)
        
        
//        let credentials = API.kDwollaClient_id + ":" + API.kDwollaClient_secret
        
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        request.httpMethod = "Post"
        request.httpBody = postData as Data
//        let credentialData = credentials.data(using: String.Encoding.utf8)
//        let base64 = credentialData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.setValue("Basic " + base64, forHTTPHeaderField: "Authorization")
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request) {
            (
            data, response, error) in
            if (error != nil && data != nil) {
                
                completion("failure", error?.localizedDescription ?? "error", data)
            }
            else if (error != nil || data == nil){
                completion("failure", error?.localizedDescription ?? "error", nil)
            }
            else{
                
                completion("success",nil,data!)
            }
            
        }
        
        task.resume()
        
    }
    
    func getAccountID(params: [String: AnyObject],completion: @escaping ( _ status: String,  _ error: String?, _ dataValue: Data?) -> Void) {
            
            let urlString = "https://connect.stripe.com/oauth/token"
            
            let url = URL(string: urlString)
            
            let session = URLSession.shared
            var request = URLRequest(url: url!)
            request.httpMethod = "Post"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            //NSURLRequest.CachePolicy.reloadIgnoringCacheData
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                
            } catch let error {
                print(error.localizedDescription)
            }
            
            let task = session.dataTask(with: request) {
                (
                data, response, error) in
                if (error != nil && data != nil) {
                    
                    completion("failure", error?.localizedDescription ?? "error", data)
                }
                else if (error != nil || data == nil){
                    completion("failure", error?.localizedDescription ?? "error", nil)
                }
                else{
    //                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    completion("success",nil,data!)
                }
                
            }
            
            task.resume()
            
        }
    
    
    func withdrawThroughStripe(params: [String: AnyObject],completion: @escaping ( _ status: String,  _ error: String?, _ dataValue: Data?) -> Void) {
            
            let urlString = "https://us-central1-amassadoor.cloudfunctions.net/" + "sendAmountTobankaccount"
            
            let url = URL(string: urlString)
            
            let session = URLSession.shared
            var request = URLRequest(url: url!)
            request.httpMethod = "Post"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            //NSURLRequest.CachePolicy.reloadIgnoringCacheData
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                
            } catch let error {
                print(error.localizedDescription)
            }
            
            let task = session.dataTask(with: request) {
                (
                data, response, error) in
                if (error != nil && data != nil) {
                    
                    completion("failure", error?.localizedDescription ?? "error", data)
                }
                else if (error != nil || data == nil){
                    completion("failure", error?.localizedDescription ?? "error", nil)
                }
                else{
    //                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    completion("success",nil,data!)
                }
                
            }
            
            task.resume()
            
        }
    
    
    func sendOTPtoUserService(params: [String: AnyObject],completion: @escaping ( _ status: String,  _ error: String?, _ dataValue: Data?) -> Void) {
            
            let urlString = "https://us-central1-amassadoor.cloudfunctions.net/" + "sendOTPtousermail"
            
            let url = URL(string: urlString)
            
            let session = URLSession.shared
            var request = URLRequest(url: url!)
            request.httpMethod = "Post"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            //NSURLRequest.CachePolicy.reloadIgnoringCacheData
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                
            } catch let error {
                print(error.localizedDescription)
            }
            
            let task = session.dataTask(with: request) {
                (
                data, response, error) in
                if (error != nil && data != nil) {
                    
                    completion("failure", error?.localizedDescription ?? "error", data)
                }
                else if (error != nil || data == nil){
                    completion("failure", error?.localizedDescription ?? "error", nil)
                }
                else{
    //                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    completion("success",nil,data!)
                }
                
            }
            
            task.resume()
            
        }
    
    func sendOTPtoUserServiceForConfirmEmail(params: [String: AnyObject],completion: @escaping ( _ status: String,  _ error: String?, _ dataValue: Data?) -> Void) {
            
            let urlString = "https://us-central1-amassadoor.cloudfunctions.net/" + "confirmEmailByOTP"
            
            let url = URL(string: urlString)
            
            let session = URLSession.shared
            var request = URLRequest(url: url!)
            request.httpMethod = "Post"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            //NSURLRequest.CachePolicy.reloadIgnoringCacheData
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                
            } catch let error {
                print(error.localizedDescription)
            }
            
            let task = session.dataTask(with: request) {
                (
                data, response, error) in
                if (error != nil && data != nil) {
                    
                    completion("failure", error?.localizedDescription ?? "error", data)
                }
                else if (error != nil || data == nil){
                    completion("failure", error?.localizedDescription ?? "error", nil)
                }
                else{
    //                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    completion("success",nil,data!)
                }
                
            }
            
            task.resume()
            
        }

}


    


