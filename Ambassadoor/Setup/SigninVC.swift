//
//  SigninVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/7/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

enum LoginProblem {
    case noEmail //no email.
    case noPassword //no password.
    case noConnection //no connection.
    case userDoesNotExist //the email entered doesn't exist
    case passwordInvalid //password invalid, but account with email DOES exist.
    case badEmailFormat //email wasn't valid.
}

class SigninVC: UIViewController {
    
    var delegate: AutoDimiss?
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var signinButton: BoldButton!
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var ForgotPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func SignInNow() {
        //LoginFailed(reason: .passwordInvalid) //[RAM] THIS IS FOR TESTING PURPOSES, REMOVE THIS.
        
        //if false {
        //[RAM]
        
        
        //LoginSuccessful() //If the login is valid, use this function to go to HomeVC.
        //LoginFailed(reason: .badEmailFormat) //If login failed, use this function which will tell the user why their login failed
        //Please program cases for all possible problems found in "LoginProblem"
        //For example, if the user didn't have an email use:
        //LoginFailed(reason: .noEmail)
        //}
        
        if emailText.text?.count != 0 {
            
            if isValidEmail(emailStr: emailText.text!){
                
                if passwordText.text?.count != 0 {
                    
                    filterQueryByField(email: emailText.text!) { (success, data) in
                        if success{
                            
                            var password = ""
                            var userID = ""
                            for (key,value) in data! {
                                userID = key
                                password = value["password"] as! String
                            }
                            
                            if self.passwordText.text!.md5() == password {
                                
                                if AccessToken.current != nil {
                                    
                                    fetchSingleUserDetails(userID: userID) { (status, user) in
                                        Yourself = user
                                        self.LoginSuccessful()
                                        
                                    }
                                }else{
//                                    fetchSingleUserDetails(userID: userID) { (status, user) in
//                                        Yourself = user
//                                        self.LoginSuccessful()
//
//                                    }
                                    self.callIfAccessTokenExpired(userID: userID)
                                }
                                
                            }else{
                                self.LoginFailed(reason: .passwordInvalid)
                            }
                            
                        }else{
                            self.LoginFailed(reason: .userDoesNotExist)
                        }
                    }
                    
                }else{
                    LoginFailed(reason: .noPassword)
                }
                
            }else{
                LoginFailed(reason: .badEmailFormat)
            }
        }else{
            LoginFailed(reason: .noEmail)
        }
        
    }
    
    func callIfAccessTokenExpired(userID: String) {
        
        API.facebookLoginAct(userIDBusiness: userID, owner: self) { (userDetail,longliveToken, error) in
            if error == nil {
                
                if let userDetailDict = userDetail as? [String: AnyObject]{
                    
                    if let id = userDetailDict["id"] as? String {
                        NewAccount.id = id
                    }
                    if let followerCount = userDetailDict["followers_count"] as? Int {
                        NewAccount.followerCount = Int64(followerCount)
                    }
                    if let name = userDetailDict["name"] as? String {
                        NewAccount.instagramName = name
                    }
                    if let pic = userDetailDict["profile_picture_url"] as? String {
                        NewAccount.profilePicture = pic
                    }
                    if let username = userDetailDict["username"] as? String {
                        NewAccount.instagramUsername = username
                    }
                    //AccessToken.current!.tokenString
                    NewAccount.authenticationToken = longliveToken!
                    
                    API.calculateAverageLikes(userID: userID, longLiveToken: NewAccount.authenticationToken) { (recentMedia, error) in
                        
                        if error == nil{
                            
                            self.averageLikes(recentMedia: recentMedia, userID: userID)
                            
                        }else{
                            
                        }
                        
                    }
                    
                    //                    Yourself = updateUserDetails(userID: userID)
                    //                    self.LoginSuccessful()
                    
                }else{
                    self.showStandardAlertDialog(title: "Alert", msg: "Something is wrong! Please try again later")
                }
                
            }else{
                self.showStandardAlertDialog(title: "Alert", msg: "Something is wrong! Please try again later")
            }
        }
        
    }
    
    func averageLikes(recentMedia: Any, userID: String) {
        
        if let recentMediaDict = recentMedia as? [String: AnyObject] {
            
            if let mediaData = recentMediaDict["data"] as? [[String: AnyObject]]{
                
                var numberOfPost = 0
                var numberOfLikes = 0
                
                for (index,mediaObject) in mediaData.enumerated() {
                    
                    if let mediaID = mediaObject["id"] as? String {
                        
                        GraphRequest(graphPath: mediaID, parameters: ["fields":"like_count,timestamp","access_token":NewAccount.authenticationToken]).start(completionHandler: { (connection, recentMediaDetails, error) -> Void in
                            
                            if let mediaDict = recentMediaDetails as? [String: AnyObject] {
                                
                                if let timeStamp = mediaDict["timestamp"] as? String{
                                    print(Date.getDateFromISO8601DateString(ISO8601String: timeStamp))
                                    print(Date().deductMonths(month: -3))
                                    
                                    if Date.getDateFromISO8601DateString(ISO8601String: timeStamp) > Date().deductMonths(month: -3){
                                        
                                        if let likeCount = mediaDict["like_count"] as? Int{
                                            numberOfPost += 1
                                            numberOfLikes += likeCount
                                        }
                                    }
                                    
                                }
                                
                            }
                            
                            
                            
                            if index == mediaObject.count - 1{
                                if Double(numberOfLikes/numberOfPost) != nil{
                                    NewAccount.averageLikes = Double(numberOfLikes/numberOfPost)
                                }
                                
                                let userData: [String: Any] = [
                                    "id": NewAccount.id,
                                    "name": NewAccount.instagramName,
                                    "username": NewAccount.instagramUsername,
                                    "followerCount": NewAccount.followerCount,
                                    "profilePicture": NewAccount.profilePicture,
                                    "averageLikes": NewAccount.averageLikes,
                                    "authenticationToken": NewAccount.authenticationToken,
                                    "tokenFIR":global.deviceFIRToken
                                ]
                                
                                updateUserDetails(userID: userID, userData: userData)
                                fetchSingleUserDetails(userID: userID) { (status, user) in
                                    Yourself = user
                                    self.LoginSuccessful()
                                    
                                }
                            }
                            
                        })
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    //OTHER CODE BELOW
    
    
    
    
    @IBAction func closeSignUp(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextField(_ sender: Any) {
        passwordText.becomeFirstResponder()
    }
    
    @IBAction func tappedOut(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func SignInFromKeyboard(_ sender: Any) {
        passwordText.resignFirstResponder()
        if signinButton.isEnabled {
            DisableSignIn()
            SignInNow()
        }
    }
    
    @IBAction func SignInFrombutton(_ sender: Any) {
        DisableSignIn()
        SignInNow()
    }
    
    func DisableSignIn() {
        signinButton.isEnabled = false
        signinButton.Text = "Signing In..."
    }
    
    func LoginSuccessful() {
        signinButton.Text = "Signed In"
        self.authLabel.text = "Welcome Back"
        self.authLabel.textColor = .systemGreen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.delegate?.DismissNow()
        }
    }
    
    @IBAction func textChanged(_ sender: Any) {
        if let sender = sender as? UITextField {
            if sender.text!.contains(" ") {
                sender.text = sender.text?.replacingOccurrences(of: " ", with: "")
            }
        }
    }
    
    func LoginFailed(reason: LoginProblem) {
        signinButton.Text = "Sign In"
        MakeShake(viewToShake: signinButton)
        
        if reason == .passwordInvalid {
            ForgotPasswordButton.isHidden = false
        }
        
        SetLabelText(text: GetLabelTextFromIssue(reason: reason), animated: false)
        authLabel.textColor = .red
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.transition(with: self.authLabel, duration: 2, options: .transitionCrossDissolve, animations: {
                self.authLabel.textColor = GetForeColor()
            }, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.SetLabelText(text: "Authentication Required", animated: true)
                self.signinButton.isEnabled = true
            }
        }
    }
    
    func SetLabelText(text textstring: String, animated: Bool) {
        if animated {
            let animation: CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.push
            animation.subtype = CATransitionSubtype.fromTop
            self.authLabel.text = textstring
            animation.duration = 0.25
            self.authLabel.layer.add(animation, forKey: CATransitionType.push.rawValue)
        } else {
            authLabel.text = textstring
        }
    }
    
    func GetLabelTextFromIssue(reason: LoginProblem?) -> String {
        switch reason {
        case .noEmail:
            return "Failed: No Email"
        case .noPassword:
            return "Failed: No Password"
        case .noConnection:
            return "No Internet Connection"
        case .userDoesNotExist:
            return "No Account For Email"
        case .passwordInvalid:
            return "Password Incorrect"
        case .badEmailFormat:
            return "Invalid Email"
        default:
            return "Authentication Failed"
        }
    }
}
