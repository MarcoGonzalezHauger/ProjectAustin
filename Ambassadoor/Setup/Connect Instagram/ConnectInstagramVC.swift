//
//  ConnectInstagramVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/12/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

protocol VerificationReturned {
	func DonePressed()
	func ThatsNotMe()
}

import UIKit
import WebKit
import FBSDKCoreKit
import FBSDKLoginKit

class ConnectInstagramVC: UIViewController, WKNavigationDelegate, VerificationReturned {
	
	
	func DonePressed() { //Proceeded
		
		
		//[RAM] The account entered should be loaded onto the NewAccount strucutre
		NewAccount.instagramKey = "" //The instagram key gotten from the WKWebView
		NewAccount.instagramUsername = igName //The instagram user's username.
		accInfoUpdate()
		self.navigationController?.popViewController(animated: true)
	}
	
	func ThatsNotMe() {
		//[RAM] WKWebView needs to be reset so that the influencer could login again.
	}
	

	@IBAction func testIt(_ sender: Any) {
		//This button will be removed later of course
		//AccountAlreadyInUse(emailOfExistingUser: "marco@amb.co")
		AccountLoggedIn(instagramUsername: "marcogonzalezhauger")
	}
	
	@IBOutlet weak var webView: WKWebView!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	//[RAM] These are the three different possibilties when a user logs in. The functoins are done, you just need to call them.
	
	
	func AccountLoggedIn(instagramUsername: String) {
		igName = instagramUsername
		performSegue(withIdentifier: "toConnected", sender: self)
	}
	
	func AccountAlreadyInUse(emailOfExistingUser email: String) {
		alreadyUsedEmail = email
		performSegue(withIdentifier: "toInUse", sender: self)
	}
	
	func NotBusinessAccount() {
		performSegue(withIdentifier: "toNotBusiness", sender: self)
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
		//[RAM] make this wkWebView go to the login page on Instagram, just like the one before.
        //self.NotBusinessAccount()
        //self.loginAct()
        self.loadLogin()
    }
    
    // Loads the Instagram login page
        func loadLogin() {
            if attemptedLogOut {
                API.instaLogout()
            }
            
            let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&scope=user_profile,user_media&response_type=code", arguments: [API.INSTAGRAM_AUTHURL, API.INSTAGRAM_CLIENT_ID, API.INSTAGRAM_REDIRECT_URI])

            let urlRequest = URLRequest.init(url: URL.init(string: authURL)!)
            // Puts login page into WebView on VC
            self.webView.navigationDelegate = self
            webView.load(urlRequest)
            
            print("WEB VIEW URL: \(String(describing: webView.url))")

        }
    

	
	@IBAction func cancelButtonPressed(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicatorView.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        decisionHandler(.allow)
        let success: Bool = checkRequestForCallbackURL(request: navigationAction.request)
        if success {
            print("Sucessful login.")
        }
    }
    
    // Check callback url for instagram access token
    func checkRequestForCallbackURL(request: URLRequest) -> Bool {
        let requestURLString = (request.url?.absoluteString)! as String
        print("requestURLString= " + requestURLString)
        if requestURLString.hasPrefix(API.INSTAGRAM_REDIRECT_URI) || requestURLString.hasPrefix(API.INSTAGRAM_REDIRECT_URI2) {
            let range: Range<String.Index> = requestURLString.range(of: "code=")!
            //let range: Range<String.Index> = requestURLString.range(of: "access_token=")!
            print("Access Token : " + String(requestURLString[range.upperBound...]).replacingOccurrences(of: "#_", with: ""))
            let code = String(requestURLString[range.upperBound...]).replacingOccurrences(of: "#_", with: "")
            let params = ["client_id":API.INSTAGRAM_CLIENT_ID,"client_secret":API.INSTAGRAM_CLIENTSERCRET,"grant_type":"authorization_code","redirect_uri":API.INSTAGRAM_REDIRECT_URI,"code":code] as [String : AnyObject]
            let str = "client_id=\(API.INSTAGRAM_CLIENT_ID)&client_secret=\(API.INSTAGRAM_CLIENTSERCRET)&grant_type=authorization_code&redirect_uri=\(API.INSTAGRAM_REDIRECT_URI)&code=\(code)"
            self.webView.isHidden = true
            API.getInstagramAccessToken(params: params, appendedURI: str) { (status, accesstoken, userID) in
                //self.dismissed(success: false)
                self.handleAuth(authToken: accesstoken,userID: String(userID))
                
            }
            
            return true
        }
        return false
    }
    
    // Handle Instagram auth token from callback url and handle it with our logic
    func handleAuth(authToken: String,userID: String) {
        print("Instagram authentication token = ", authToken)
        API.INSTAGRAM_ACCESS_TOKEN = authToken
        API.getProfileInfo(userId: userID) { (businessuser: Bool) in
            
            if businessuser{
                self.showStandardAlertDialog(title: "Business User", msg: "You have verified as business user. login with facebook to fetch your business account details") { (clickAction) in
                    //self.loginAct(userIDBusiness: userID)
                    
                    API.facebookLoginAct(userIDBusiness: userID, owner: self) { (userDetail, error) in
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
                                    self.igName = username
                                }
                                NewAccount.authenticationToken = AccessToken.current!.tokenString
                                
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "toConnected", sender: self)
                                    //self.NotBusinessAccount()
                                }
                                
                            }else{
                                self.showStandardAlertDialog(title: "Alert", msg: "Something is wrong! Please try again later")
                            }
                            
                        }else{
                            self.showStandardAlertDialog(title: "Alert", msg: "Something is wrong! Please try again later")
                        }
                    }
                }
                
            }else{
                
                DispatchQueue.main.async {
                    self.NotBusinessAccount()
                }
                
            }

        }
    }
	
	var igName: String = ""
	var igKey: String = ""
	var alreadyUsedEmail: String = ""
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? InstagramConnectedVC {
			destination.delegate = self
			destination.SetName(name: igName)
		}
		if let destination = segue.destination as? AccountInUseVC {
			destination.delegate = self
			destination.SetEmail(email: alreadyUsedEmail)
		}
		if let destination = segue.destination as? NotBusinessVC {
			destination.delegate = self
		}
	}
	/*
     //                GraphRequest(graphPath: "/me/accounts", parameters: [:]).start(completionHandler: { (connection, result, error) -> Void in
     //
     //                    if let resultDict = result as? [String: AnyObject] {
     //                    let arrayKey = resultDict.keys
     //                    print(arrayKey)
     //
     //                        if let dataArray = resultDict["data"] as? NSArray{
     //
     //                            if let dataDict = dataArray.firstObject as? NSDictionary{
     //                                if let idString = dataDict["id"] as? String{
     //                                    print(idString)
     //
     //                                    GraphRequest(graphPath: idString, parameters: ["fields":"instagram_business_account"]).start(completionHandler: { (connection, businessResult, error) -> Void in
     //
     //                                        if let dicVal = businessResult as? NSDictionary {
     //
     //                                            if let businessResultDict = dicVal["instagram_business_account"] as? NSDictionary{
     //
     //                                            if let businessID = businessResultDict["id"] as? String{
     //
     //                                                print(businessID)
     //
     //                                                GraphRequest(graphPath: businessID, parameters: ["fields":"biography,id,followers_count,follows_count,media_count,name,profile_picture_url,username,website"]).start(completionHandler: { (connection, userDetail, error) -> Void in
     //
     //                                                    if let userDetailDict = userDetail as? [String: AnyObject]{
     //
     //                                                        if let id = userDetailDict["id"] as? String {
     //                                                           NewAccount.id = id
     //                                                        }
     //                                                        if let followerCount = userDetailDict["followers_count"] as? Int {
     //                                                            NewAccount.followerCount = Int64(followerCount)
     //                                                        }
     //                                                        if let name = userDetailDict["name"] as? String {
     //                                                            NewAccount.instagramName = name
     //                                                        }
     //                                                        if let pic = userDetailDict["profile_picture_url"] as? String {
     //                                                            NewAccount.profilePicture = pic
     //                                                        }
     //                                                        if let username = userDetailDict["username"] as? String {
     //                                                            NewAccount.instagramUsername = username
     //                                                            self.igName = username
     //                                                        }
     //                                                        NewAccount.authenticationToken = AccessToken.current!.tokenString
     //
     //                                                        DispatchQueue.main.async {
     //                                                            self.performSegue(withIdentifier: "toConnected", sender: self)
     //                                                            //self.NotBusinessAccount()
     //                                                        }
     //
     //                                                    }
     //
     //                                                })
     //
     //                                            }
     //                                        }
     //
     //                                        }
     //
     //                                    })
     //                                }
     //                            }
     //
     //                        }
     //
     //                    }
     //
     //                })
     */
    
    /*
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
             self.igName = username
         }
         NewAccount.authenticationToken = AccessToken.current!.tokenString
         
         DispatchQueue.main.async {
             self.performSegue(withIdentifier: "toConnected", sender: self)
             //self.NotBusinessAccount()
         }
         
     }else{
         self.showStandardAlertDialog(title: "Alert", msg: "Something is wrong! Please try again later")
     }
     
     }else{
         self.showStandardAlertDialog(title: "Alert", msg: "Something is wrong! Please try again later")
     }
     */
}
